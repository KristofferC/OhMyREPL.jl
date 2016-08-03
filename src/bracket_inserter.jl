# If a user writes an opening bracket
# automatically complete it with a closing bracket
# unless the next character is that closing bracket
type BracketInserter
    complete_brackets::Bool
end

import Base.LineEdit: edit_insert, edit_move_left, edit_move_right, buffer, char_move_left,
                      edit_backspace, terminal

import Base.Terminals.beep

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

function insert_into_keymap()
    left_brackets = ['(', '{', '[']
    right_brackets = [')', '}', ']']
    repl = Base.active_repl
    mirepl = isdefined(repl,:mi) ? repl.mi : repl
    main_mode = mirepl.interface.modes[1]
    for (l, r) in zip(left_brackets, right_brackets)
        main_mode.keymap_dict[l] = (s, data, c) -> begin
            edit_insert(s, l)
            if BRACKET_INSERTER.complete_brackets
                if eof(buffer(s)) || peek(buffer(s)) != l
                    edit_insert(s, r)
                    edit_move_left(s)
                end
            end
        end
        main_mode.keymap_dict[r] = (s, data, c) -> begin
            if eof(buffer(s)) || !BRACKET_INSERTER.complete_brackets || peek(buffer(s)) != r
                edit_insert(s, r)
            else
                edit_move_right(s)
            end
        end
    end

    for v in ['\"', '\'']
        main_mode.keymap_dict[v] = (s, data, c) -> begin
            b = buffer(s)
            if !eof(b) && peek(b) == v
                edit_move_right(s)
            elseif position(b) > 0 && leftpeek(b) == v
                edit_insert(s, v)
            else
                edit_insert(s, v)
                edit_insert(s, v)
                edit_move_left(s)
            end
        end
    end

    # Remove a right bracket if we delete a left bracket
    # and there is a corresponding right bracket to the right
    left_brackets2 = ['(', '{', '[', '\"', '\'']
    right_brackets2 = [')', '}', ']', '\"', '\'']
    main_mode.keymap_dict['\b'] = (s, data, c) -> begin
        b = buffer(s)
        if position(b) <= 0
            beep(terminal(s))
            return
        end
        str = String(b)
        i = findfirst(left_brackets2, str[prevind(str, position(b) + 1)])
        if !eof(buffer(s)) && i != 0 && str[nextind(str, position(b))] == right_brackets2[i]
            edit_move_right(s)
            edit_backspace(s)
            edit_backspace(s)
            return
        else
            edit_backspace(s)
        end
    end
end

if isdefined(Base, :active_repl)
    insert_into_keymap()
end

