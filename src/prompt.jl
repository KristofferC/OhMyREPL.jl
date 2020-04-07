global INPUT_PROMPT = "julia> "
global INPUT_PROMPT_PREFIX = Base.text_colors[:green]

function update_interface(interface)
    main_mode = interface.modes[1]
    main_mode.prompt_prefix = INPUT_PROMPT_PREFIX
    main_mode.prompt = INPUT_PROMPT
end

function input_prompt!(s::Union{String, Function}, col = :green)
    global INPUT_PROMPT_PREFIX = get(Base.text_colors, Symbol(col), "\e[2m")
    global INPUT_PROMPT = isa(s, String) ? s * " " : () -> string(s(), " ")
    isdefined(Base, :active_repl) && isdefined(Base.active_repl, :interface) && update_interface(Base.active_repl.interface)
    return
end

global OUTPUT_PROMPT = ""
global OUTPUT_PROMPT_PREFIX = ""

function output_prompt!(s::Union{String, Function}, col = :red)
    global OUTPUT_PROMPT_PREFIX = string("\e[1m", get(Base.text_colors, Symbol(col), Base.text_colors[:red]))
    global OUTPUT_PROMPT = s
    return
end
