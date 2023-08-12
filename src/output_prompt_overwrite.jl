import REPL

if !isdefined(REPL, :IPython)
function REPL.display(d::REPL.REPLDisplay, mime::MIME"text/plain", x)
    x = Ref{Any}(x)
    REPL.with_repl_linfo(d.repl) do io
        if isdefined(REPL, :active_module)
            mod = REPL.active_module(d)::Module
        else
            mod = Main
        end
        io = IOContext(io, :limit => true, :module => mod)
        if OUTPUT_PROMPT !== nothing
            output_prompt = OUTPUT_PROMPT isa String ? OUTPUT_PROMPT : OUTPUT_PROMPT()
            write(io, OUTPUT_PROMPT_PREFIX)
            write(io, output_prompt, "\e[0m")
        end
        get(io, :color, false) && write(io, REPL.answer_color(d.repl))
        if isdefined(d.repl, :options) && isdefined(d.repl.options, :iocontext)
            # this can override the :limit property set initially
            io = foldl(IOContext, d.repl.options.iocontext, init=io)
        end
        show(io, mime, x[])
        println(io)
    end
    return nothing
end
end
