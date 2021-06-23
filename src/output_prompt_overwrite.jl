import REPL
function REPL.display(d::REPL.REPLDisplay, mime::MIME"text/plain", x)
    io = REPL.outstream(d.repl)
    output_prompt = OUTPUT_PROMPT isa String ? OUTPUT_PROMPT : OUTPUT_PROMPT()
    write(io, OUTPUT_PROMPT_PREFIX)
    write(io, output_prompt, "\e[0m")
    Base.have_color && write(io, REPL.answer_color(d.repl))
    limited_io = IOContext(io, :limit => true)
    if hasmethod(Base.show, Tuple{typeof(limited_io), MIME"text/plain", typeof(x)})
        show(limited_io, mime, x)
    else
        pprint(limited_io, mime, x)
    end
    println(io)
end
