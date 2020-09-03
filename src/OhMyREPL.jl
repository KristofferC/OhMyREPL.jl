__precompile__()
"""
A package that provides a new REPL that has syntax highlighting,
bracket matching and other nifty features.
"""
module OhMyREPL

using Tokenize
using Crayons
if VERSION > v"1.3"
import JLFzf
end

import REPL

export colorscheme!, colorschemes, enable_autocomplete_brackets, enable_highlight_markdown, enable_fzf, test_colorscheme

include("repl_pass.jl")
include("repl.jl")
include("passes/Passes.jl")

include("BracketInserter.jl")
include("prompt.jl")

import .BracketInserter.enable_autocomplete_brackets

function colorscheme!(name::String)
    Passes.SyntaxHighlighter.activate!(Passes.SyntaxHighlighter.SYNTAX_HIGHLIGHTER_SETTINGS,
                                       name)
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

const ENABLE_FZF = Ref(!Sys.iswindows())
enable_fzf(v::Bool) = ENABLE_FZF[] = v

# Isssue 166: wait for pkg to load
function wait_pkgrepl()
    retry_n = 10 # retry for up to 10 times
    pkgid = Base.PkgId(Base.UUID("44cfe95a-1eb2-52ea-b672-e2afdf69b78f"), "Pkg")
    @async for i = 1:retry_n
        if  haskey(Base.loaded_modules, pkgid) # pkg loaded
            # @info "pkg loaded"
            Prompt.insert_keybindings()
            break
        end
        # @info "waiting for pkg..."
        sleep(.1)
        i == retry_n && Prompt.insert_keybindings() # last try, insert anyways
    end
end

function __init__()
    options = Base.JLOptions()
    # command-line
    if (options.isinteractive != 1) && options.commands != C_NULL
        return
    end

    if isdefined(Base, :active_repl)
        if !isdefined(Base.active_repl, :interface)
            Base.active_repl.interface = REPL.setup_interface(Base.active_repl)
        end
        wait_pkgrepl()
    else
        atreplinit() do repl
            if !isdefined(repl, :interface)
                repl.interface = REPL.setup_interface(repl)
            end
            wait_pkgrepl()
            update_interface(repl.interface)
            main_mode = repl.interface.modes[1]
            p = repl.interface.modes[5]
            # These are inserted here because we only want to insert them for the Julia mode
            d = Dict(
            # Up Arrow
            "\e[A" => (s,o...)-> begin
                REPL.LineEdit.edit_move_up(s) || LineEdit.enter_prefix_search(s, p, true)
                Prompt.rewrite_with_ANSI(s)
            end,
            # Down Arrow
            "\e[B" => (s,o...)-> begin
                 REPL.LineEdit.edit_move_down(s) || LineEdit.enter_prefix_search(s, p, false)
                 Prompt.rewrite_with_ANSI(s)
            end
            )
            main_mode.keymap_dict = LineEdit.keymap([d, main_mode.keymap_dict])
        end
    end

    if ccall(:jl_generating_output, Cint, ()) == 0
        include(joinpath(@__DIR__, "refresh_lines.jl"))
        include(joinpath(@__DIR__, "output_prompt_overwrite.jl"))
        include(joinpath(@__DIR__, "MarkdownHighlighter.jl"))
    end
end

end # module
