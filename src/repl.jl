# How to create an extra prompt and attach it to the current REPL was learned
# by reading the source code of @Keno's CXX.jl

module Prompt

import Base: LineEdit, REPL

import Base.LineEdit: buffer, cmove_col, cmove_up, InputAreaState
import Base.REPL: respond, LatexCompletions, return_callback, repl_filename

import ..Passes
import Tokenize.Lexers

import Base.Terminals: raw!, width, height, cmove, getX,
                       getY, clear_line, beep


using PimpMyREPL
import PimpMyREPL: untokenize_with_ANSI, apply_passes!

# Pasted from LineEdit.jl but the writes to the Terminal have been removed.
function refresh_multi_line(termbuf::Base.Terminals.TerminalBuffer, terminal::LineEdit.Terminals.UnixTerminal, buf, state::LineEdit.InputAreaState)

    cols = width(terminal)
    curs_row = -1 # relative to prompt (1-based)
    curs_pos = -1 # 1-based column position of the cursor
    cur_row = 0   # count of the number of rows
    buf_pos = position(buf)
    line_pos = buf_pos

    # Count the '\n' at the end of the line if the terminal emulator does (specific to DOS cmd prompt)
    miscountnl = @static is_windows() ? (isa(Terminals.pipe_reader(terminal), Base.TTY) && !Base.ispty(Terminals.pipe_reader(terminal))) : false
      lindent = 7
    indent = 0
    # Now go through the buffer line by line
    seek(buf, 0)
    moreinput = true # add a blank line if there is a trailing newline on the last line
    while moreinput
        l = readline(buf)
        moreinput = endswith(l, "\n")
        # We need to deal with on-screen characters, so use strwidth to compute occupied columns
        llength = strwidth(l)
        slength = sizeof(l)
        cur_row += 1
        cmove_col(termbuf, lindent + 1)
        # We expect to be line after the last valid output line (due to
        # the '\n' at the end of the previous line)
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


function find_cursoridx(buffer)
    p = position(buffer)
    seek(p, 0)
    n = 1
    byte = 0
    while byte < p
        n += 1
        byte += nextind(p, byte)
    end
    return n
end

function rewrite_with_ANSI(s, data, c, main_mode, cursormove::Bool)
        # Clear input area
        p = position(LineEdit.buffer(s))
        LineEdit.clear_input_area(LineEdit.terminal(s), s.mode_state[s.current_mode])

        # Insert colorized text from running the passes
        b = IOBuffer()
        tokens = collect(Lexers.Lexer(LineEdit.buffer(s)))
        apply_passes!(tokens,  ,cursormove)
        untokenize_with_ANSI(b, tokens)
        LineEdit.write_prompt(LineEdit.terminal(s), main_mode)
        LineEdit.write(LineEdit.terminal(s), "\e[0m") # Reset any formatting from Julia so that we start with a clean slate
        write(LineEdit.terminal(s), takebuf_string(b))

        # Reset the buffer since the Lexer messed with it (maybe the Lexer should reset it on done)
        seek(LineEdit.buffer(s), p)

        # Our cursor now seems to be out of place, we run the already existing refresh_multi_line code to put it where it belongs.
        # Maybe it is possible to save the cursor and just restore it but that is probably Terminal dependent...
        obuff = IOBuffer()
        q = Base.Terminals.TerminalBuffer(obuff)
        s.mode_state[s.current_mode].ias = refresh_multi_line(q, LineEdit.terminal(s), LineEdit.buffer(s), s.mode_state[s.current_mode].ias)
        write(LineEdit.terminal(s), takebuf_array(obuff))
        flush(LineEdit.terminal(s))
end

function hijack_REPL()
    repl = Base.active_repl
    mirepl = isdefined(repl,:mi) ? repl.mi : repl
    main_mode = mirepl.interface.modes[1]



    D = Dict{Any,Any}(
        "\e[C" => (s,data, c)-> (LineEdit.edit_move_right(s); rewrite_with_ANSI(s, data, c, main_mode)),
    # Left Arrow
         "\e[D" => (s,data, c)-> (LineEdit.edit_move_left(s); #= rewrite_with_ANSI(s, data, c, main_mode) =#),
        "*" => (s,data, c)-> (LineEdit.edit_insert(s, c); rewrite_with_ANSI(s, data, c, main_mode)))


    main_mode.keymap_dict = LineEdit.keymap([D, main_mode.keymap_dict])


    println("injecting")
    #main_mode.keymap_dict['\0'] = q
    #main_mode.keymap_dict['E'] = E
    nothing
end

end # module
