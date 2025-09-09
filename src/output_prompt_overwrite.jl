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
        if ENABLE_SEMANTIC_PROMPTS[]
            write(io, OSC_133_COMMAND_START)
        end
        custom_prompts = CUSTOM_PROMPTS[]
        if custom_prompts !== nothing
            if custom_prompts.output_prompt_prefix !== nothing
                write(io, maybe_call(custom_prompts.output_prompt_prefix))
            end
            if custom_prompts.output_prompt !== nothing
                write(io, maybe_call(custom_prompts.output_prompt), "\e[0m")
            end
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
