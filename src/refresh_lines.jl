import REPL.LineEdit

function LineEdit.refresh_line(s::REPL.LineEdit.BufferLike)
    LineEdit.refresh_multi_line(s)
    OhMyREPL.Prompt.rewrite_with_ANSI(s)
end
