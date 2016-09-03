# If a user writes an opening bracket
# automatically complete it with a closing bracket
# unless the next character is that closing bracket
type BracketInserter
    complete_brackets::Bool
end

import Base.LineEdit: edit_insert, edit_move_left, edit_move_right, buffer, char_move_left,
                      edit_backspace, terminal

import Base.Terminals.beep
import PimpMyREPL.Prompt.rewrite_with_ANSI

const BRACKET_INSERTER = BracketInserter(true)

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

AUTOMATIC_BRACKET_MATCH = Ref(true)
enable_autocomplete_brackets(v::Bool) = AUTOMATIC_BRACKET_MATCH[] = v

function insert_into_keymap!(D::Dict)
    left_brackets = ['(', '{', '[']
    right_brackets = [')', '}', ']']
    right_brackets_ws = [')', '}', ']', ' ', '\t']
    all_brackets_ws = vcat(left_brackets, right_brackets_ws)
    for (l, r) in zip(left_brackets, right_brackets)
        # If we enter a left bracket automatically complete it if the next
        # char is a whitespace or a right bracket
        D[l] = (s, o...) -> begin
            edit_insert(s, l)
            if AUTOMATIC_BRACKET_MATCH[] && (eof(buffer(s)) || peek(buffer(s)) in right_brackets_ws)
                edit_insert(s, r)
                edit_move_left(s)
            end
            rewrite_with_ANSI(s)
        end
        # If we enter a right bracket and the next char is that right bracket just move right
        D[r] = (s, o...) -> begin
            if AUTOMATIC_BRACKET_MATCH[] && !eof(buffer(s)) && peek(buffer(s)) == r
                edit_move_right(s)
            else
                edit_insert(s, r)
            end
            rewrite_with_ANSI(s)
        end
    end

    # Similar to above but with quotation marks that need to be handled a bit differently
    for v in ['\"', '\'']
        D[v] = (s, o...) -> begin
            b = buffer(s)
            # Next char is the quote symbol so just move right
            if AUTOMATIC_BRACKET_MATCH[] && !eof(b) && peek(b) == v
                edit_move_right(s)
            # Prev char or next char is not whitespace
            elseif AUTOMATIC_BRACKET_MATCH[] &&
                    ((position(b) > 0 && leftpeek(b) in all_brackets_ws) ||
                     (!eof(b) && peek(b) in right_brackets_ws) ||
                     b.size == 0)
                edit_insert(s, v)
                edit_insert(s, v)
                edit_move_left(s)
            else
                edit_insert(s, v)
            end
            rewrite_with_ANSI(s)
        end
    end

    # On backspace, also remove a corresponding right bracket
    # to the right if we remove a left bracket
    left_brackets2 = ['(', '{', '[', '\"', '\'']
    right_brackets2 = [')', '}', ']', '\"', '\'']
    D['\b'] = (s, data, c) -> begin
        b = buffer(s)
        str = String(b)
        if AUTOMATIC_BRACKET_MATCH[] && !eof(buffer(s)) && position(buffer(s)) != 0
            i = findfirst(left_brackets2, str[prevind(str, position(b) + 1)])
            if i != 0 && peek(b) == right_brackets2[i]
                edit_move_right(s)
                edit_backspace(s)
                edit_backspace(s)
                return
            end
        end
        edit_backspace(s)
        rewrite_with_ANSI(s)
    end
end

insert_into_keymap!(PimpMyREPL.Prompt.NEW_KEYBINDINGS)
