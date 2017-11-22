function Base.REPL.display(d::Base.REPL.REPLDisplay, mime::MIME"text/plain", x)
    io = Base.REPL.outstream(d.repl)
    write(io, OUTPUT_PROMPT)
    Base.have_color && write(io, Base.REPL.answer_color(d.repl))
    show(IOContext(io, :limit => true), mime, x)
    println(io)
end
