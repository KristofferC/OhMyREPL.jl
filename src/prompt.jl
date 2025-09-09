const PromptSetting = Union{String,Function}

struct CustomPromptSettings
    input_prompt::Union{PromptSetting, Nothing}
    input_prompt_prefix::Union{PromptSetting, Nothing}
    output_prompt::Union{PromptSetting, Nothing}
    output_prompt_prefix::Union{PromptSetting, Nothing}
end

CustomPromptSettings() = CustomPromptSettings(nothing, nothing, nothing, nothing)

const CUSTOM_PROMPTS = Ref(CustomPromptSettings())

struct PromptRecord
    prompt::PromptSetting
    prompt_prefix::PromptSetting
    prompt_suffix::PromptSetting
    output_prefix::PromptSetting
    output_prefix_prefix::PromptSetting
    output_prefix_suffix::PromptSetting
end

PromptRecord(prompt::REPL.LineEdit.Prompt) = PromptRecord((getfield(prompt, field) for field in fieldnames(PromptRecord))...)

mutable struct PromptCache
    theirs::PromptRecord
    ours::PromptRecord
end

const PROMPT_CACHE = IdDict{REPL.LineEdit.Prompt, PromptCache}()
const ENABLE_SEMANTIC_PROMPTS = Ref(true)

const OSC_133_PROMPT_START = "\033]133;A\007"
const OSC_133_PROMPT_END = "\033]133;B\007"
const OSC_133_COMMAND_START = "\033]133;C\007"

maybe_call(a::String) = a
maybe_call(a) = a()
concat_maybe_func(a::String, b::String) = a * b
concat_maybe_func(a, b) = () -> maybe_call(a) * maybe_call(b)

const LAST_PROMPT_SETTINGS = Ref{Union{Nothing, Tuple{Bool, CustomPromptSettings}}}(nothing)

function update_input_prompts(originals, semantic_prompts, input_prompt_prefix, input_prompt; updates = [])
    if input_prompt_prefix !== nothing || semantic_prompts
        before_prompt_tag = semantic_prompts ? OSC_133_PROMPT_START : ""
        input_prefix = isnothing(input_prompt_prefix) ? originals.prompt_prefix : input_prompt_prefix
        push!(updates, (:prompt_prefix, concat_maybe_func(before_prompt_tag, input_prefix)))
    end
    if input_prompt !== nothing
        push!(updates, (:prompt, input_prompt))
    end
    if semantic_prompts
        push!(updates, (:prompt_suffix, concat_maybe_func(originals.prompt_suffix, OSC_133_PROMPT_END)))
    end
    return updates
end

function update_output_prompts(originals, semantic_prompts, output_prompt_prefix, output_prompt; updates=[])
    if output_prompt_prefix !== nothing || semantic_prompts
        input_to_ouput_tag = semantic_prompts ? OSC_133_COMMAND_START : ""
        output_prompt_prefix = isnothing(output_prompt_prefix) ? originals.output_prefix_prefix : output_prompt_prefix
        push!(updates, (:output_prefix_prefix, concat_maybe_func(input_to_ouput_tag, output_prompt_prefix)))
    end
    if output_prompt !== nothing
        push!(updates, (:output_prefix, output_prompt))
    end
    return updates
end

function apply_updates!(mode, updates)
    for (field, value) in updates
        setfield!(mode, field, value)
    end
end

function get_originals(mode)
    current = PromptRecord(mode)
    if !(mode in keys(PROMPT_CACHE))
        return current
    end
    cached = PROMPT_CACHE[mode]
    merged = CustomPromptSettings[]
    for field in fieldnames(PromptRecord)
        if getfield(cached.ours, field) === getfield(current, field)
            # We were the last to set this field, revert to the original
            push!(merged, getfield(cached.theirs, field))
        else
            # This has been overwritten, so just accept the current value
            push!(merged, getfield(current, field))
        end
    end
    return PromptRecord(merged...)
end

function prompt_is_dirty(mode, uses_custom_prompts)
    return (
        !(mode in keys(PROMPT_CACHE)) ||
        isnothing(LAST_PROMPT_SETTINGS[]) ||
        (LAST_PROMPT_SETTINGS[][1] != ENABLE_SEMANTIC_PROMPTS[]) ||
        (!uses_custom_prompts && LAST_PROMPT_SETTINGS[][2] != CUSTOM_PROMPTS[])
    )
end

function update_interface(interface)
    semantic_prompts = ENABLE_SEMANTIC_PROMPTS[]
    main_mode = interface.modes[1]
    @assert main_mode isa REPL.LineEdit.Prompt
    custom_prompts = CUSTOM_PROMPTS[]
    if prompt_is_dirty(main_mode, true)
        originals = get_originals(main_mode)
        updates = Tuple{Symbol, PromptSetting}[]
        update_input_prompts(originals, semantic_prompts, custom_prompts.input_prompt_prefix, custom_prompts.input_prompt; updates)
        if isdefined(REPL, :IPython)
            update_output_prompts(originals, semantic_prompts, custom_prompts.output_prompt_prefix, custom_prompts.output_prompt; updates)
        end
        apply_updates!(main_mode, updates)
        PROMPT_CACHE[main_mode] = PromptCache(originals, setproperties(originals; updates...))
    end
    for mode in interface.modes[2:end]
        if !(mode isa REPL.LineEdit.Prompt) || !prompt_is_dirty(mode, false)
            continue
        end
        originals = get_originals(mode)
        updates = Tuple{Symbol, PromptSetting}[]
        update_input_prompts(originals, semantic_prompts, nothing, nothing; updates)
        update_output_prompts(originals, semantic_prompts, nothing, nothing; updates)
        apply_updates!(mode, updates)
        PROMPT_CACHE[mode] = PromptCache(originals, setproperties(originals; updates...))
    end
    LAST_PROMPT_SETTINGS[] = (ENABLE_SEMANTIC_PROMPTS[], custom_prompts)
end

function update_interface()
    isdefined(Base, :active_repl) && isdefined(Base.active_repl, :interface) && update_interface(Base.active_repl.interface)
end

function input_prompt!(s::Union{String, Function}, col = :green)
    CUSTOM_PROMPTS[] = setproperties(
        CUSTOM_PROMPTS[];
        input_prompt_prefix = get(Base.text_colors, col isa Int64 ? col : Symbol(col), "\e[2m"),
        input_prompt = s
    )
    update_interface()
    return
end

function output_prompt!(s::Union{String, Function}, col = :red)
    CUSTOM_PROMPTS[] = setproperties(
        CUSTOM_PROMPTS[];
        output_prompt_prefix = string("\e[1m", get(Base.text_colors, col isa Int64 ? col : Symbol(col), Base.text_colors[:red])),
        output_prompt = s
    )
    if isdefined(REPL, :IPython)
        update_interface()
    end
    return
end

function enable_semantic_prompts(v::Bool)
    ENABLE_SEMANTIC_PROMPTS[] = v
    update_interface()
end
