global INPUT_PROMPT = "julia> "
global INPUT_PROMPT_PREFIX = Base.text_colors[:green]

function update_interface(interface)
    main_mode = interface.modes[1]
    main_mode.prompt_prefix = INPUT_PROMPT_PREFIX
    main_mode.prompt = INPUT_PROMPT
end

function input_prompt!(s::String, col = :green)
    global INPUT_PROMPT_PREFIX = get(Base.text_colors, Symbol(col), "\e[2m")
    global INPUT_PROMPT = isa(s, String) ? s * " " : s
    isdefined(Base, :active_repl) && isdefined(Base.active_repl, :interface) && update_interface(Base.active_repl.interface)
    return
end

global OUTPUT_PROMPT = ""

function output_prompt!(s::String, col = :red)
    global OUTPUT_PROMPT
    OUTPUT_PROMPT = string("\e[1m", get(Base.text_colors, Symbol(col), "red"), s, "\e[0m", " ")
    return
end