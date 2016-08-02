# How to create an extra prompt and attach it to the current REPL was learned
# by reading the source code of @Keno's CXX.jl

module Prompt

import Base: LineEdit, REPL

import Base.LineEdit: buffer, cmove_col, cmove_up, InputAreaState, transition,
                      terminal, buffer, on_enter, move_input_end, add_history, state, mode, edit_insert
import Base.REPL: respond, LatexCompletions, return_callback, repl_filename

import ..Passes
import Tokenize.Lexers

import Base.Terminals: raw!, width, height, cmove, getX,
                       getY, clear_line, beep


using PimpMyREPL
import PimpMyREPL: untokenize_with_ANSI, apply_passes!, PASS_HANDLER

function rewrite_with_ANSI(s, data, c, main_mode, cursormove::Bool = false)
        # Clear input area
        p = position(buffer(s))
        LineEdit.clear_input_area(terminal(s), s.mode_state[s.current_mode])

        # Extract the cursor index in character count
        cursoridx = length(String(buffer(s).data[1:p]))

        # Insert colorized text from running the passes
        b = IOBuffer()
        tokens = collect(Lexers.Lexer(buffer(s)))
        apply_passes!(PASS_HANDLER, tokens, cursoridx, cursormove)
        untokenize_with_ANSI(b, PASS_HANDLER , tokens)
        LineEdit.write_prompt(terminal(s), main_mode)
        LineEdit.write(terminal(s), "\e[0m") # Reset any formatting from Julia so that we start with a clean slate
        write(terminal(s), takebuf_string(b))

        # Reset the buffer since the Lexer messed with it (maybe the Lexer should reset it on done)
        seek(buffer(s), p)

        # Our cursor now seems to be out of place, we run the already existing refresh_multi_line code to put it where it belongs.
        # Maybe it is possible to save the cursor and just restore it but that is probably Terminal dependent...
        obuff = IOBuffer()
        q = Base.Terminals.TerminalBuffer(obuff)
        s.mode_state[s.current_mode].ias = refresh_multi_line(q, terminal(s), buffer(s), s.mode_state[s.current_mode].ias)
        write(terminal(s), takebuf_array(obuff))
        flush(terminal(s))
end


loaded = false

function hijack_REPL()
    # This flag is so we dont add the keys again on reloading the package because that
    # will cause a stack overflow
    global loaded

    repl = Base.active_repl
    mirepl = isdefined(repl,:mi) ? repl.mi : repl
    main_mode = mirepl.interface.modes[1]

    if !loaded
        D = Dict{Any, Any}()
        # This needs work...
        hijacked_keys = ["\e[C", "\e[D", "*", "\b", "\e[A", "\e[B", "\e[3~", "^T",
                     "\e[H", "\e[F", "\e[1;5D", "\eOd", "\e[1;5C", "\eOc",
                     "^B", "^F", "\eb", "\ef", "\t", "(", ")", "}", "{", "]", "["]
        @assert length(unique(hijacked_keys)) == length(hijacked_keys)
        for key in hijacked_keys
            f = match_input(main_mode.keymap_dict, key, 1)
            D[key] = (s, data, c) -> (f(s, data, c); rewrite_with_ANSI(s, data, c, main_mode))
        end

        # Hack around a bit to make enter not remove syntax highlighting above
        D["\r"] = (s, data, c) -> begin
            if on_enter(s) || (eof(buffer(s)) && s.key_repeats > 1)
                move_input_end(s)
                println(terminal(s))
                add_history(s)
                state(s, mode(s)).ias = InputAreaState(0, 0)
                return :done
            else
                edit_insert(s, '\n')
                rewrite_with_ANSI(s, data, c, main_mode)
            end
        end

        # Hack around a bit to make Ctrl + C work
        D["^C"] = (s, data, c) -> begin
            try # raise the debugger if present
                ccall(:jl_raise_debugger, Int, ())
            end
            move_input_end(s)
            rewrite_with_ANSI(s, data, c, main_mode)
            print(terminal(s), "^C\n\n")
            transition(s, :reset)
            rewrite_with_ANSI(s, data, c, main_mode)
        end

        main_mode.keymap_dict = LineEdit.keymap([D, main_mode.keymap_dict])
        loaded = true
    end

    nothing
end

match_input(f::Function, str::String, i) = f
function match_input(k::Dict, str::String, i=1)
    key = haskey(k, str[i]) ? str[i] : '\0'
    # if we don't match on the key, look for a default action then fallback on 'nothing' to ignore
    return match_input(get(k, key, nothing), str, nextind(str, i))
end

# Pasted from LineEdit.jl but the writes to the Terminal have been removed.
function refresh_multi_line(termbuf, terminal, buf, state)
    cols = width(terminal)
    curs_row = -1 # relative to prompt (1-based)
    curs_pos = -1 # 1-based column position of the cursor
    cur_row = 0   # count of the number of rows
    buf_pos = position(buf)
    line_pos = buf_pos

    # Count the '\n' at the end of the line if the terminal emulator does (specific to DOS cmd prompt)
    miscountnl = @static is_windows() ? (isa(Terminals.pipe_reader(terminal), Base.TTY) && !Base.ispty(Terminals.pipe_reader(terminal))) : false
    lindent = 7
    indent = 0 # TODO this gets the cursor right but not the text
    # Now go through the buffer line by line
    seek(buf, 0)
    moreinput = true # add a blank line if there is a trailing newline on the last line
    while moreinput
        prev_pos = position(buf)
        l = readline(buf)
        moreinput = endswith(l, "\n")
        # We need to deal with on-screen characters, so use strwidth to compute occupied columns
        llength = strwidth(l)
        slength = sizeof(l)
        cur_row += 1
        cmove_col(termbuf, lindent + 1)
        # We expect to be line after the last valid output line (due to
        # the '\n' at the end of the previous line)
        if curs_row != -1
            seek(buf, prev_pos)
            write(buf, " "^indent)
            write(buf, "balle")
            write(buf, l)
        end
        if curs_row == -1
            # in this case, we haven't yet written the cursor position
            line_pos -= slength # '\n' gets an extra pos
            if line_pos < 0 || !moreinput
                num_chars = (line_pos >= 0 ? llength : strwidth(l[1:(line_pos + slength)]))
                curs_row, curs_pos = divrem(lindent + num_chars - 1, cols)
                curs_row += cur_row
                curs_pos += 1
                # There's an issue if the cursor is after the very right end of the screen. In that case we need to
                # move the cursor to the next line, and emit a newline if needed
                if curs_pos == cols
                    # only emit the newline if the cursor is at the end of the line we're writing
                    if line_pos == 0
                        write(termbuf, "\n")
                        cur_row += 1
                    end
                    curs_row += 1
                    curs_pos = 0
                    cmove_col(termbuf, 1)
                end
            end
        end
        cur_row += div(max(lindent + llength + miscountnl - 1, 0), cols)
        lindent = indent
    end
    seek(buf, buf_pos)

    # Let's move the cursor to the right position
    # The line first
    n = cur_row - curs_row
    if n > 0
        cmove_up(termbuf, n)
    end

    #columns are 1 based
    cmove_col(termbuf, curs_pos + 1)

    # Updated cur_row,curs_row
    return InputAreaState(cur_row, curs_row)
end


end # module
