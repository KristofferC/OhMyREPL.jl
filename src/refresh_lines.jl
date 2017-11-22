import Base.LineEdit: refresh_line

function Base.LineEdit.refresh_line(s)
    Base.LineEdit.refresh_multi_line(s)
    OhMyREPL.Prompt.rewrite_with_ANSI(s)
end
