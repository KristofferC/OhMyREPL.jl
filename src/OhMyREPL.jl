__precompile__()
"""
A package that provides a new REPL that has syntax highlighting,
bracket matching and other nifty features.
"""
module OhMyREPL

import JuliaSyntax
using Crayons
if VERSION > v"1.3"
import JLFzf
end

import REPL

export colorscheme!, colorschemes, enable_autocomplete_brackets, enable_highlight_markdown, enable_fzf, test_colorscheme

const SUPPORTS_256_COLORS = !(Sys.iswindows() && VERSION < v"1.5.3")

# Wrap the function `f` so that it's always invoked in the given `world_age`
function fix_world_age(f, world_age)
    if world_age == typemax(UInt)
        function (args...; kws...)
            Base.invokelatest(f, args...; kws...)
        end
    else
        function (args...; kws...)
            Base.invoke_in_world(world_age, f, args...; kws...)
        end
    end
end

include("repl_pass.jl")
include("repl.jl")
include("passes/Passes.jl")

include("BracketInserter.jl")
include("prompt.jl")
include("hooks.jl")

import .BracketInserter.enable_autocomplete_brackets

function colorscheme!(name::String)
    Passes.SyntaxHighlighter.activate!(
        Passes.SyntaxHighlighter.SYNTAX_HIGHLIGHTER_SETTINGS, name)
    Passes.RainbowBrackets.updatebracketcolors!(
        Passes.SyntaxHighlighter.SYNTAX_HIGHLIGHTER_SETTINGS.active)
    return Passes.SyntaxHighlighter.SYNTAX_HIGHLIGHTER_SETTINGS.active
end

function colorschemes()
    show(Passes.SyntaxHighlighter.SYNTAX_HIGHLIGHTER_SETTINGS)
end

const TEST_STR = """

function funcdef(x::Float64, y::Int64)
    y = 100_000
    x = :foo
    s = "I am a happy string"
    c = `mycmd`
    @time 1+1
    #= Comments look like this =#
    z = funccall(x, y)
    5 * 3 + 2 - 1
end
"""

function test_colorscheme(name::String, str::String = TEST_STR)
    syntaxpass = get_pass(PASS_HANDLER, "SyntaxHighlighter")
    active = syntaxpass.active
    try
        colorscheme!(name)
        test_pass(syntaxpass, str)
    finally
        syntaxpass.active = active
    end
    return
end


function test_colorscheme(cs::Passes.SyntaxHighlighter.ColorScheme, str::String = TEST_STR)
    syntaxpass = get_pass(PASS_HANDLER, "SyntaxHighlighter")
    active = syntaxpass.active
    name = "plzdontnameyourcolorschemethis"
    try
        Passes.SyntaxHighlighter.add!(syntaxpass, name, cs)
        colorscheme!(name)
        test_pass(syntaxpass, str)
    finally
        syntaxpass.active = active
        if haskey(syntaxpass.schemes, name)
            delete!(syntaxpass.schemes, name)
        end
    end
    return
end

showpasses(io::IO = stdout) = Base.show(io, PASS_HANDLER)

const HIGHLIGHT_MARKDOWN = Ref(true)
enable_highlight_markdown(v::Bool) = HIGHLIGHT_MARKDOWN[] = v

const ENABLE_FZF = Ref(true)
enable_fzf(v::Bool) = ENABLE_FZF[] = v

using Pkg
function reinsert_after_pkg(repl, world_age)
    mirepl = isdefined(repl,:mi) ? repl.mi : repl
    main_mode = mirepl.interface.modes[1]
    m = first(methods(main_mode.keymap_dict[']']))
    if m.module == Pkg.REPLMode
        Prompt.insert_keybindings(repl, world_age)
    end
end

function setup_repl(repl, world_age)
    if !isdefined(repl, :interface)
        repl.interface = REPL.setup_interface(repl)
    end
    Prompt.insert_keybindings(repl, world_age)
    @async begin
        sleep(0.25)
        reinsert_after_pkg(repl, world_age)
    end
    update_interface(repl.interface)

    global _refresh_line_hook = fix_world_age(_refresh_line, world_age)
end

function __init__()
    options = Base.JLOptions()
    world_age = Base.get_world_counter()
    # command-line
    if (options.isinteractive != 1) && options.commands != C_NULL
        return
    end

    if isdefined(Base, :active_repl)
        setup_repl(Base.active_repl, world_age)
    else
        atreplinit() do repl
            setup_repl(Base.active_repl, world_age)
        end
    end

    if ccall(:jl_generating_output, Cint, ()) == 0
        activate_hooks()
    end
end

include("precompile.jl")

end # module
