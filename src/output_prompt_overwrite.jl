import REPL
function REPL.display(d::REPL.REPLDisplay, mime::MIME"text/plain", x)
    io = REPL.outstream(d.repl)
    output_prompt = OUTPUT_PROMPT isa String ? OUTPUT_PROMPT : OUTPUT_PROMPT()
    write(io, OUTPUT_PROMPT_PREFIX)
    write(io, output_prompt, "\e[0m")
    Base.have_color && write(io, REPL.answer_color(d.repl))
    limited_io = IOContext(io, :limit => true)

    if fallback_to_default_show(io, x)
        pprint(limited_io, x)
    else
        show(limited_io, mime, x)
    end
    println(io)
end

function fallback_to_default_show(io::IO, x)
    # NOTE: Base.show(::IO, ::MIME"text/plain", ::Any) forwards to
    # Base.show(::IO, ::Any)

    # check if we are gonna call Base.show(::IO, ::MIME"text/plain", ::Any)
    mt = methods(Base.show, (typeof(io), MIME"text/plain", typeof(x)))
    length(mt.ms) == 1 && any(mt.ms) do method
        method.sig == Tuple{typeof(Base.show), IO, MIME"text/plain", Any}
    end || return false

    # check if we are gonna call Base.show(::IO, ::Any)
    mt = methods(Base.show, (typeof(io), typeof(x)))
    length(mt.ms) == 1 && return any(mt.ms) do method
        method.sig == Tuple{typeof(Base.show), IO, Any}
    end
end
