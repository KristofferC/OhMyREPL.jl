module Cursor
    # note that  \u1b  is in decimal 033, which is an escape code
    const ERASE_TO_EOL = "\u1b[K"
    const UP1 = "\u1b[A"
    up(n) = "\u1b[$(n)A"
    const MOVE_TO_SOL = "\r" #Carriage Return
end

function move_cursor_up_while_clearing_lines(io, numlinesup)
    for _ in 1:numlinesup
        print(io, Cursor.MOVE_TO_SOL * Cursor.ERASE_TO_EOL * Cursor.UP1)
    end
    print(io, Cursor.MOVE_TO_SOL * Cursor.ERASE_TO_EOL * Cursor.MOVE_TO_SOL)
end

