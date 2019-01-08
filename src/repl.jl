# How to create an extra prompt and attach it to the current REPL was learned
# by reading the source code of @Keno's CXX.jl

module Prompt

import REPL
import REPL.LineEdit
import REPL.Terminals

import REPL: respond, return_callback
import REPL.LineEdit: buffer, cmove_col, cmove_up, InputAreaState, transition,
                      terminal, buffer, on_enter, move_input_end, add_history, state, mode, edit_insert

import Tokenize.Lexers

import REPL.Terminals: raw!, width, height, cmove, getX, TerminalBuffer,
                  getY, clear_line, beep, disable_bracketed_paste, enable_bracketed_paste

using OhMyREPL
import OhMyREPL: untokenize_with_ANSI, apply_passes!, PASS_HANDLER

@nospecialize # use only declared type signatures

function rewrite_with_ANSI(s, cursormove::Bool = false)
        if isa(s, LineEdit.SearchState)
            return
        end
        # Clear input area
        p = position(buffer(s))
        if isa(s, LineEdit.PrefixSearchState)
            s = s.mi
        end
        if isa(s, LineEdit.MIState)
            mode = s.mode_state[s.current_mode]
        else
            mode = s
        end

        outbuf = IOBuffer()
        termbuf = Terminals.TerminalBuffer(outbuf)
        # Hide the cursor
        LineEdit.write(outbuf, "\e[?25l")
        LineEdit.clear_input_area(termbuf, mode)
        # Extract the cursor index in character count
        cursoridx = length(String(buffer(s).data[1:p]))



        l = textwidth(get_prompt(s))
        if !isa(s, LineEdit.SearchState)
            LineEdit.write_prompt(termbuf, mode)
            LineEdit.write(termbuf, "\e[0m") # Reset any formatting from Julia so that we start with a clean slate
        end

        # Insert colorized text from running the passes
        seekstart(buffer(s))
        tokens = collect(Lexers.Lexer(buffer(s)))
        apply_passes!(PASS_HANDLER, tokens, cursoridx, cursormove)
        untokenize_with_ANSI(outbuf, PASS_HANDLER , tokens, l)

        # Reset the buffer since the Lexer messed with it (maybe the Lexer should reset it on done)
        seek(buffer(s), p)

        # Our cursor now seems to be out of place, we run the already existing refresh_multi_line code to put it where it belongs.
        # Maybe it is possible to save the cursor and just restore it but that is probably Terminal dependent...
        mode.ias = refresh_multi_line(termbuf, terminal(s), buffer(s), mode.ias, l)
        LineEdit.write(outbuf, "\e[?25h")  # Show the cursor
        write(terminal(s), take!(outbuf))
        flush(terminal(s))
end


function create_keybindings()

    D = Dict{Any, Any}()
    D['\b']   = (s, data, c) -> if LineEdit.edit_backspace(buffer(s))
        rewrite_with_ANSI(s)
    else
        beep(terminal(s))
    end
    D["*"]    = (s, data, c) ->  (LineEdit.edit_insert(buffer(s), c); rewrite_with_ANSI(s))
    D["^B"]   = (s, data, c) -> (LineEdit.edit_move_left(buffer(s)) ;rewrite_with_ANSI(s))
    D["^F"]   = (s, data, c) -> (LineEdit.edit_move_right(buffer(s)) ;rewrite_with_ANSI(s))
    # Meta B
    D["\eb"]  = (s, data, c) -> (LineEdit.edit_move_word_left(s) ; rewrite_with_ANSI(s))
    # Meta F
     D["\ef"]  = (s, data, c) -> (LineEdit.edit_move_word_right(s); rewrite_with_ANSI(s))
    # Meta Enter
    D["\e\r"] = (s, data, c) -> (LineEdit.edit_insert(buffer(s), '\n'); rewrite_with_ANSI(s))
    D["^A"]   = (s, data, c) -> (LineEdit.move_line_start(s); rewrite_with_ANSI(s))
    D["^E"]   = (s, data, c) -> (LineEdit.move_line_end(s); rewrite_with_ANSI(s))
    D["\e[H"] = (s, data, c) -> (LineEdit.move_input_start(s); rewrite_with_ANSI(s))
    D["\e[F"] = (s, data, c) -> (LineEdit.move_input_end(buffer(s)); rewrite_with_ANSI(s))
    D["^L"]   = (s, data, c) -> (Terminals.clear(terminal(s)); rewrite_with_ANSI(s))
    D["^W"]   = (s, data, c) -> LineEdit.edit_werase(s)
    # Right Arrow
    D["\e[C"] = (s, data, c)->(LineEdit.edit_move_right(buffer(s)); rewrite_with_ANSI(s))
    # Left Arrow
    D["\e[D"] = (s, data, c)->(LineEdit.edit_move_left(buffer(s)); rewrite_with_ANSI(s))
    # Up Arrow
    # Delete
    D["\e[3~"] = (s, data, c)->(LineEdit.edit_delete(buffer(s)); rewrite_with_ANSI(s))
    D["^T"] = (s, data, c)->(LineEdit.edit_transpose(buffer(s)); rewrite_with_ANSI(s))
    D["\ed"] = (s, data, c)->(LineEdit.edit_delete_next_word(buffer(s)); rewrite_with_ANSI(s))
    D["\e\b"] = (s, data, c)->(LineEdit.edit_delete_prev_word(buffer(s)); rewrite_with_ANSI(s))
    D["^N"]  = (s,data,c)->(LineEdit.history_next(s, mode(s).hist); rewrite_with_ANSI(s))
    D["^P"]  = (s,data,c)->(LineEdit.history_prev(s, mode(s).hist); rewrite_with_ANSI(s))
    D["^D"] = (s, data, c)->begin
        if buffer(s).size > 0
            LineEdit.edit_delete(buffer(s)); rewrite_with_ANSI(s)
        else
            println(terminal(s))
            return :abort
        end
    end


    # Hack around a bit to make enter not remove syntax highlighting above
    D["\r"] = (s, data, c) -> begin
        if on_enter(s) || (eof(buffer(s)) && s.key_repeats > 1)
            # Disable bracket highlighting before entering
            brackidx = OhMyREPL._find_pass(OhMyREPL.PASS_HANDLER, "BracketHighlighter")
            brackstatus = false
            if brackidx != -1
                brackstatus = OhMyREPL.PASS_HANDLER.passes[brackidx][2].enabled
                OhMyREPL.enable_pass!(PASS_HANDLER, "BracketHighlighter", false)
            end
            _commit_line(s, data, c)
            if brackidx != -1 && brackstatus == true
                OhMyREPL.enable_pass!(PASS_HANDLER, "BracketHighlighter", true)
            end
            return :done
        else
            edit_insert(buffer(s), '\n')
            rewrite_with_ANSI(s)
        end
    end

    # Hack around a bit to make Ctrl + C work
    D["^C"] = (s, data, c) -> begin
        try # raise the debugger if present
            ccall(:jl_raise_debugger, Int, ())
        catch
        end
        move_input_end(s)
        rewrite_with_ANSI(s)
        print(terminal(s), "^C\n\n")
        transition(s, :reset)
        rewrite_with_ANSI(s)
    end


    # Fixup bracket paste a bit
     D["\e[200~"] = (s, data, c) ->begin
        input = LineEdit.bracketed_paste(s) # read directly from s until reaching the end-bracketed-paste marker
        sbuffer = LineEdit.buffer(s)
        curspos = position(sbuffer)
        seek(sbuffer, 0)
        shouldeval = (bytesavailable(sbuffer) == curspos && !occursin(UInt8('\n'), sbuffer))
        seek(sbuffer, curspos)
        if curspos == 0
            # if pasting at the beginning, strip leading whitespace
            input = lstrip(input)
        end
        if !shouldeval
            # when pasting in the middle of input, just paste in place
            # don't try to execute all the WIP, since that's rather confusing
            # and is often ill-defined how it should behave
            edit_insert(s, input)
            rewrite_with_ANSI(s)
            return
        end
        LineEdit.push_undo(s)
        edit_insert(sbuffer, input)
        input = String(take!(sbuffer))
        oldpos = firstindex(input)
        firstline = true
        isprompt_paste = false
        prompt = get_prompt(s)
        while oldpos <= lastindex(input) # loop until all lines have been executed
            # Check if the next statement starts with "julia> ", in that case
            # skip it. But first skip whitespace
            while input[oldpos] in ('\n', ' ', '\t')
                oldpos = nextind(input, oldpos)
                oldpos >= sizeof(input) && return
            end
            # Skip over prompt prefix if statement starts with it
            jl_prompt_len = textwidth(prompt)
            jl_default_len = textwidth("julia> ")
            match_default = oldpos + jl_default_len <= sizeof(input) && input[oldpos:oldpos+jl_default_len-1] == "julia> "
            match_prompt =  oldpos + jl_prompt_len  <= sizeof(input) && input[oldpos:oldpos+jl_prompt_len-1] == prompt
            if (firstline || isprompt_paste) && (match_default || match_prompt)
                isprompt_paste = true
                match_prompt ? (oldpos += jl_prompt_len) : (oldpos += jl_default_len)
            # If we are prompt pasting and current statement does not begin with julia> , skip to next line
            elseif isprompt_paste
                while input[oldpos] != '\n'
                    oldpos = nextind(input, oldpos)
                    oldpos >= sizeof(input) && return
                end
                continue
            end
            ast, pos = Meta.parse(input, oldpos, raise=false, depwarn=false)
            if (isa(ast, Expr) && (ast.head == :error || ast.head == :continue || ast.head == :incomplete)) ||
                    (pos > ncodeunits(input) && !endswith(input, '\n'))
                # remaining text is incomplete (an error, or parser ran to the end but didn't stop with a newline):
                # Insert all the remaining text as one line (might be empty)
                tail = input[oldpos:end]
                if !firstline
                    # strip leading whitespace, but only if it was the result of executing something
                    # (avoids modifying the user's current leading wip line)
                    tail = lstrip(tail)
                end
                if isprompt_paste # remove indentation spaces corresponding to the prompt
                    tail = replace(tail, r"^ {7}"m => "") # 7: jl_prompt_len
                end
                LineEdit.replace_line(s, tail, true)
                rewrite_with_ANSI(s)
                break
            end
            # get the line and strip leading and trailing whitespace
            line = strip(input[oldpos:prevind(input, pos)])
            if !isempty(line)
                if isprompt_paste # remove indentation spaces corresponding to the prompt
                    line = replace(line, r"^ {7}"m => "") # 7: jl_prompt_len
                end
                # put the line on the screen and history
                LineEdit.replace_line(s, line)
                _commit_line(s, data, c)
                # execute the statement
                terminal = LineEdit.terminal(s) # This is slightly ugly but ok for now
                raw!(terminal, false) && disable_bracketed_paste(terminal)
                LineEdit.mode(s).on_done(s, LineEdit.buffer(s), true)
                raw!(terminal, true) && enable_bracketed_paste(terminal)
                LineEdit.push_undo(s) # when the last line is incomplete
            end
            oldpos = pos
            firstline = false
        end
    end

    # Tab
    D['\t'] = (s, data, c) -> begin
        buf = buffer(s)
        # Yes, we are ignoring the possiblity
        # the we could be in the middle of a multi-byte
        # sequence, here but that's ok, since any
        # whitespace we're interested in is only one byte
        i = position(buf)
        if i != 0
            c = buf.data[i]
            if c == UInt8('\n') || c == UInt8('\t') ||
               # hack to allow path completion in cmds
               # after a space, e.g., `cd <tab>`, while still
               # allowing multiple indent levels
               (c == UInt8(' ') && i > 3 && buf.data[i-1] == UInt8(' '))
                edit_insert(s, " "^4)
                return
            end
        end
        LineEdit.complete_line(s)
        rewrite_with_ANSI(s)
    end

    return D
end
NEW_KEYBINDINGS = create_keybindings()

import Pkg
function insert_keybindings(repl = Base.active_repl)
    mirepl = isdefined(repl,:mi) ? repl.mi : repl
    main_mode = mirepl.interface.modes[1]
    p = mirepl.interface.modes[5]

    NEW_KEYBINDINGS["\e[A"] = (s,o...)-> begin
        LineEdit.edit_move_up(buffer(s)) || LineEdit.enter_prefix_search(s, p, true)
        Prompt.rewrite_with_ANSI(s)
    end
    # Down Arrow
    NEW_KEYBINDINGS["\e[B"] = (s,o...)-> begin
        LineEdit.edit_move_down(buffer(s)) || LineEdit.enter_prefix_search(s, p, false)
        Prompt.rewrite_with_ANSI(s)
    end



    main_mode.keymap_dict = LineEdit.keymap([NEW_KEYBINDINGS, main_mode.keymap_dict])
end

function _commit_line(s, data, c)
    move_input_end(s)
    rewrite_with_ANSI(s)
    println(terminal(s))
    add_history(s)
    state(s, mode(s)).ias = InputAreaState(0, 0)
end

function get_prompt(s)
    if isa(s, LineEdit.PromptState)
        prompt = s.p.prompt
    elseif isa(s, LineEdit.MIState)
        mode = s.current_mode
        if isa(mode, LineEdit.PrefixHistoryPrompt)
            prompt = mode.parent_prompt.prompt
        else
            prompt = mode.prompt
        end
    else
        error("Bug: $(typeof(s)) not accounted for")
    end
    isa(prompt, String) ? (return prompt) : (return prompt())
end

# Pasted from LineEdit.jl but the writes to the Terminal have been removed.
function refresh_multi_line(termbuf, terminal, buf, state, promptlength)
    cols = width(terminal)
    curs_row = -1 # relative to prompt (1-based)
    curs_pos = -1 # 1-based column position of the cursor
    cur_row = 0   # count of the number of rows
    buf_pos = position(buf)
    line_pos = buf_pos

    # Count the '\n' at the end of the line if the terminal emulator does (specific to DOS cmd prompt)
    miscountnl = @static Sys.iswindows() ? (isa(Terminals.pipe_reader(terminal), Base.TTY) && !Base.ispty(Terminals.pipe_reader(terminal))) : false
    lindent = promptlength
    indent = promptlength # TODO this gets the cursor right but not the text
    # Now go through the buffer line by line
    seek(buf, 0)
    moreinput = true # add a blank line if there is a trailing newline on the last line
    while moreinput
        l = readline(buf, keep=true)
        moreinput = endswith(l, "\n")
        # We need to deal with on-screen characters, so use textwidth to compute occupied columns
        llength = textwidth(l)
        slength = sizeof(l)
        cur_row += 1
        cmove_col(termbuf, lindent + 1)
        # We expect to be line after the last valid output line (due to
        # the '\n' at the end of the previous line)
        if curs_row == -1
            # in this case, we haven't yet written the cursor position
            line_pos -= slength # '\n' gets an extra pos
            if line_pos < 0 || !moreinput
                num_chars = (line_pos >= 0 ? llength : textwidth(l[1:prevind(l, line_pos + slength + 1)]))
                curs_row, curs_pos = divrem(lindent + num_chars - 1, cols)
                curs_row += cur_row
                curs_pos += 1
                # There's an issue if the cursor is after the very right end of the screen. In that case we need to
                # move the cursor to the next line, and emit a newline if needed
                if curs_pos == cols
                    # only emit the newline if the cursor is at the end of the line we're writing
                    if line_pos == 0
                        write(termbuf, '\n')
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
