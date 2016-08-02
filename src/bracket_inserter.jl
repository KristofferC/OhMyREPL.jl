# If a user writes an opening bracket
# automatically complete it with a closing bracket
# unless the next character is that closing bracket
type BracketInserter
    complete_brackets::Bool
end

import Base.LineEdit: edit_insert, edit_move_left, edit_move_right, buffer

const BRACKET_INSERTER = BracketInserter(true)

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
                if eof(buffer(s)) || String(buffer(s))[position(buffer(s)) + 1] != l
                    edit_insert(s, r)
                    edit_move_left(s)
                end
            end
        end
        main_mode.keymap_dict[r] = (s, data, c) -> begin
            if eof(buffer(s)) || !BRACKET_INSERTER.complete_brackets ||
                    String(buffer(s))[position(buffer(s)) + 1] != r
                edit_insert(s, r)
            else
                edit_move_right(s)
            end
        end
    end
end

if isdefined(Base, :active_repl)
    insert_into_keymap()
end
