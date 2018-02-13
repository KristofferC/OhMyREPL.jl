import REPL
function REPL.display(d::REPL.REPLDisplay, mime::MIME"text/plain", x)
    io = REPL.outstream(d.repl)
    write(io, OUTPUT_PROMPT)
    Base.have_color && write(io, REPL.answer_color(d.repl))
    show(IOContext(io, :limit => true), mime, x)
    println(io)
end
