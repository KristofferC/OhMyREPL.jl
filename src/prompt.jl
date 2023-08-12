INPUT_PROMPT = nothing
INPUT_PROMPT_PREFIX = nothing

OUTPUT_PROMPT = nothing
OUTPUT_PROMPT_PREFIX = nothing

function update_interface(interface)
    main_mode = interface.modes[1]
    if INPUT_PROMPT_PREFIX !== nothing
        main_mode.prompt_prefix = INPUT_PROMPT_PREFIX
    end
    if INPUT_PROMPT !== nothing
        main_mode.prompt = INPUT_PROMPT
    end
    if isdefined(REPL, :IPython)
        if OUTPUT_PROMPT_PREFIX !== nothing
            main_mode.output_prefix_prefix = OUTPUT_PROMPT_PREFIX
        end
        if OUTPUT_PROMPT !== nothing
            main_mode.output_prefix = OUTPUT_PROMPT
        end
    end
end

function input_prompt!(s::Union{String, Function}, col = :green)
    global INPUT_PROMPT_PREFIX = get(Base.text_colors, col isa Int64 ? col : Symbol(col), "\e[2m")
    global INPUT_PROMPT = s
    isdefined(Base, :active_repl) && isdefined(Base.active_repl, :interface) && update_interface(Base.active_repl.interface)
    return
end

function output_prompt!(s::Union{String, Function}, col = :red)
    global OUTPUT_PROMPT_PREFIX = string("\e[1m", get(Base.text_colors, col isa Int64 ? col : Symbol(col), Base.text_colors[:red]))
    global OUTPUT_PROMPT = s
    if isdefined(REPL, :IPython)
        isdefined(Base, :active_repl) && isdefined(Base.active_repl, :interface) && update_interface(Base.active_repl.interface)
    end
    return
end
