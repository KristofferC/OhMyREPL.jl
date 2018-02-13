import REPL.LineEdit

function LineEdit.refresh_line(s)
    LineEdit.refresh_multi_line(s)
    OhMyREPL.Prompt.rewrite_with_ANSI(s)
end
