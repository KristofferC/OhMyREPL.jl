function input_prompt!(s::String, col = :green)
    repl = Base.active_repl
    mirepl = isdefined(repl,:mi) ? repl.mi : repl
    main_mode = mirepl.interface.modes[1]
    main_mode.prompt_prefix = get(Base.text_colors, Symbol(col), "\e[2m")
    main_mode.prompt = s * " "
    return
end

global OUTPUT_PROMPT = ""

function output_prompt!(s::String, col = :red)
    global OUTPUT_PROMPT
    OUTPUT_PROMPT = string("\e[1m", get(Base.text_colors, Symbol(col), "red"), s, "\e[0m", " ")
    return
end
