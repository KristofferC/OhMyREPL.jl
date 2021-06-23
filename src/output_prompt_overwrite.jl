import REPL
function REPL.display(d::REPL.REPLDisplay, mime::MIME"text/plain", x)
    io = REPL.outstream(d.repl)
    output_prompt = OUTPUT_PROMPT isa String ? OUTPUT_PROMPT : OUTPUT_PROMPT()
    write(io, OUTPUT_PROMPT_PREFIX)
    write(io, output_prompt, "\e[0m")
    Base.have_color && write(io, REPL.answer_color(d.repl))
    show(IOContext(io, :limit => true), mime, x)
    println(io)
end
