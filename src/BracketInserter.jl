module BracketInserter

using OhMyREPL

# If a user writes an opening bracket
# automatically complete it with a closing bracket
# unless the next character is that closing bracket
mutable struct BracketInserterSettings
    complete_brackets::Bool
end

import REPL
import REPL.LineEdit
import REPL.LineEdit: edit_insert, edit_move_left, edit_move_right, buffer, char_move_left,
                      edit_backspace, terminal, transition, state

import REPL.Terminals.beep
import OhMyREPL.Prompt.rewrite_with_ANSI

const BRACKET_INSERTER = BracketInserterSettings(true)

function leftpeek(b::IOBuffer)
    p = position(b)
    c = char_move_left(b)
    seek(b, p)
    return c
end

function peek(b::IOBuffer)
    p = position(b)
    c = read(b, Char)
    seek(b, p)
    return c
end

# when we should not close the bracket
function no_closing_bracket(left_peek, v)
    # left_peek == v: we already have an open quote immediately before (triple quote)
    # regex is for transposing calls: issue #200
    # regex: immediately after letter/_: \w or closing array bracket \]
    left_peek == v || (v == '\'' && occursin(r"\w|\]", string(left_peek)))
end

const AUTOMATIC_BRACKET_MATCH = Ref(!Sys.iswindows())
enable_autocomplete_brackets(v::Bool) = AUTOMATIC_BRACKET_MATCH[] = v

const pkgmode = Ref{Any}()
import Pkg
function insert_into_keymap!(D::Dict)
    left_brackets = ['(', '{', '[']
    right_brackets = [')', '}', ']']
    right_brackets_ws = vcat(right_brackets, [' ', '\t'])
    left_brackets_ws = vcat(left_brackets, [' ', '\t'])
    all_brackets_ws = vcat(left_brackets, right_brackets_ws)
    for (l, r) in zip(left_brackets, right_brackets)
        # If we enter a left bracket automatically complete it if the next
        # char is a whitespace or a right bracket
        D[l] = (s, o...) -> begin
            edit_insert(buffer(s), l)
            if AUTOMATIC_BRACKET_MATCH[] && (eof(buffer(s)) || peek(buffer(s)) in right_brackets_ws)
                edit_insert(buffer(s), r)
                edit_move_left(buffer(s))
            end
            rewrite_with_ANSI(s)
        end
        # If we enter a right bracket and the next char is that right bracket just move right
        D[r] = (s, o...) -> begin
            if AUTOMATIC_BRACKET_MATCH[] && !eof(buffer(s)) && peek(buffer(s)) == r
                edit_move_right(buffer(s))
            else
                edit_insert(buffer(s), r)
            end
            rewrite_with_ANSI(s)
        end
    end

    f = D[']']
    D[']'] = (s, o...) -> begin
        if isempty(s) || position(LineEdit.buffer(s)) == 0
            if !isassigned(pkgmode)
                found_pkg = false
                for mode in Base.active_repl.interface.modes
                    if mode isa LineEdit.Prompt
                        if mode.prompt == Pkg.REPLMode.promptf
                            found_pkg = true
                            pkgmode[] = mode
                        end
                    end
                end
                if !found_pkg
                    pkgmode[] = nothing
                end
            end
            if pkgmode[] !== nothing
                buf = copy(LineEdit.buffer(s))
                transition(s, pkgmode[]) do
                    LineEdit.state(s, pkgmode[]).input_buffer = buf
                end
            else
                f(s, o...)
            end
        else
            f(s, o...)
        end
    end

    # Similar to above but with quotation marks that need to be handled a bit differently
    for v in ['\"', '\'', '\`']
        D[v] = (s, o...) -> begin
            b = buffer(s)

            if AUTOMATIC_BRACKET_MATCH[]
                # Next char is the quote symbol so just move right
                if !eof(b) && peek(b) == v
                    edit_move_right(b)
                elseif position(b) > 0 && no_closing_bracket(leftpeek(b), v)
                    edit_insert(b, v)
                else
                    edit_insert(b, v)
                    edit_insert(b, v)
                    edit_move_left(b)
                end
            else
                edit_insert(b, v)
            end
            rewrite_with_ANSI(s)
        end
    end

    # On backspace, also remove a corresponding right bracket
    # to the right if we remove a left bracket
    left_brackets2 = ['(', '{', '[', '\"', '\'', '\`']
    right_brackets2 = [')', '}', ']', '\"', '\'', '\`']
    D['\b'] = (s, data, c) -> begin
        repl = Base.active_repl
        mirepl = isdefined(repl,:mi) ? repl.mi : repl
        main_mode = mirepl.interface.modes[1]
        if isempty(s) || position(buffer(s)) == 0
            buf = copy(buffer(s))
            transition(s, main_mode) do
                state(s, main_mode).input_buffer = buf
            end
        else
            b = buffer(s)
            str = String(take!(copy(b)))
            if AUTOMATIC_BRACKET_MATCH[] && !eof(buffer(s)) && position(buffer(s)) != nothing
                i = findfirst(isequal(str[prevind(str, position(b) + 1)]), left_brackets2)
                if i != nothing && peek(b) == right_brackets2[i]
                    edit_move_right(buffer(s))
                    edit_backspace(buffer(s))
                    edit_backspace(buffer(s))
                    rewrite_with_ANSI(s)
                    return
                end
            end
            edit_backspace(buffer(s))
        end
        rewrite_with_ANSI(s)
    end
end

insert_into_keymap!(OhMyREPL.Prompt.NEW_KEYBINDINGS)
end # module
