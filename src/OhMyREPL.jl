"""
A package that makes the Julia REPL nicer.

As of Julia 1.13, syntax highlighting, matching bracket highlighting, rainbow
brackets and automatic insertion of closing brackets are built into the REPL
itself. OhMyREPL is a thin layer on top of this that provides:

- Named colorschemes for the built-in syntax highlighting, applied as
  StyledStrings faces (see [`colorscheme!`](@ref) and [`colorschemes`](@ref)).
- Customizable input and output prompts.
"""
module OhMyREPL

import REPL
import REPL.LineEdit
using StyledStrings: StyledStrings, Face
import JuliaSyntaxHighlighting

export colorscheme!, colorschemes, enable_autocomplete_brackets, enable_highlight_markdown,
       enable_fzf, test_colorscheme

include("colorschemes.jl")
include("prompt.jl")

_active_repl() = isdefined(Base, :active_repl) ? Base.active_repl : nothing

"""
    enable_fzf(enable::Bool)

Compatibility no-op. The fzf based history search was removed from OhMyREPL;
use the REPL's built-in `^R` history search.
"""
function enable_fzf(v::Bool)
    @warn "The fzf based history search was removed from OhMyREPL in favor of the built-in `^R` history search; `enable_fzf` is a no-op." maxlog = 1
    return
end

# REPL options cannot always be applied immediately since the REPL may not
# have been created yet (e.g. when OhMyREPL is loaded from startup.jl).
# They are stashed here and applied from `_setup_repl`.
const AUTO_BRACKETS = Ref{Union{Nothing, Bool}}(nothing)
const STYLE_INPUT = Ref{Union{Nothing, Bool}}(nothing)
const BRACKET_HIGHLIGHT = Ref{Union{Nothing, Bool}}(nothing)

"""
    enable_autocomplete_brackets(enable::Bool)

Toggle automatic insertion of closing brackets and quotes. This simply sets
the REPL's native `auto_insert_closing_bracket` option.
"""
function enable_autocomplete_brackets(v::Bool)
    AUTO_BRACKETS[] = v
    _apply_options()
    return
end

"""
    enable_highlight_markdown(enable::Bool)

Compatibility no-op. Markdown code blocks in docstrings are highlighted
natively on Julia 1.13+.
"""
function enable_highlight_markdown(v::Bool = true)
    @warn "Markdown code blocks are highlighted natively on Julia 1.13+; `enable_highlight_markdown` is a no-op." maxlog = 1
    return
end

"""
    enable_pass!(name::String, enabled::Bool)

Compatibility shim for the old customizable pass pipeline, which was removed
in favor of the native REPL highlighting in Julia 1.13. The passes that map
onto native functionality still work:

- `"SyntaxHighlighter"` toggles the REPL's `style_input` option.
- `"RainbowBrackets"` toggles `JuliaSyntaxHighlighting.RAINBOW_DELIMITERS_ENABLED`.
- `"BracketHighlighter"` toggles the REPL's `EnclosingParenHighlightPass`.

Any other pass name is ignored with a warning.
"""
function enable_pass!(name::String, enabled::Bool)
    if name == "SyntaxHighlighter"
        STYLE_INPUT[] = enabled
        _apply_options()
    elseif name == "RainbowBrackets"
        JuliaSyntaxHighlighting.RAINBOW_DELIMITERS_ENABLED[] = enabled
    elseif name == "BracketHighlighter"
        BRACKET_HIGHLIGHT[] = enabled
        _apply_options()
    else
        @warn "The custom pass pipeline was removed from OhMyREPL in favor of the native REPL highlighting in Julia 1.13; `enable_pass!(\"$name\", ...)` is ignored." maxlog = 1
    end
    return
end

function _apply_options(repl = _active_repl())
    repl isa REPL.LineEditREPL || return
    if AUTO_BRACKETS[] !== nothing
        repl.options.auto_insert_closing_bracket = AUTO_BRACKETS[]::Bool
    end
    if STYLE_INPUT[] !== nothing
        repl.options.style_input = STYLE_INPUT[]::Bool
    end
    if BRACKET_HIGHLIGHT[] !== nothing && isdefined(repl, :interface)
        for mode in repl.interface.modes
            mode isa LineEdit.Prompt || continue
            passes = mode.styling_passes
            filter!(p -> !(p isa REPL.StylingPasses.EnclosingParenHighlightPass), passes)
            if BRACKET_HIGHLIGHT[]::Bool
                push!(passes, REPL.StylingPasses.EnclosingParenHighlightPass())
            end
        end
    end
    return
end

function _setup_repl(repl)
    repl isa REPL.LineEditREPL || return
    try
        if !isdefined(repl, :interface)
            repl.interface = REPL.setup_interface(repl)
        end
        _apply_options(repl)
        update_interface(repl.interface)
    catch e
        @warn "OhMyREPL failed to hook into the REPL" exception = (e, catch_backtrace())
    end
    return
end

function __init__()
    ccall(:jl_generating_output, Cint, ()) == 1 && return
    options = Base.JLOptions()
    # command-line
    if (options.isinteractive != 1) && options.commands != C_NULL
        return
    end

    colorscheme!(DEFAULT_COLORSCHEME)

    repl = _active_repl()
    if repl !== nothing
        _setup_repl(repl)
    else
        atreplinit(_setup_repl)
    end
end

end # module
