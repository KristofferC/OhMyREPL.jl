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

const SUPPORTS_256_COLORS = !(Sys.iswindows() && VERSION < v"1.5.3")

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

const ENABLE_FZF = Ref(true)
enable_fzf(v::Bool) = ENABLE_FZF[] = v

using Pkg
function reinsert_after_pkg()
    repl = Base.active_repl
    mirepl = isdefined(repl,:mi) ? repl.mi : repl
    main_mode = mirepl.interface.modes[1]
    m = first(methods(main_mode.keymap_dict[']']))
    if m.module == Pkg.REPLMode
        Prompt.insert_keybindings()
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
        Prompt.insert_keybindings()
        @async begin
            sleep(0.25)
            reinsert_after_pkg()
        end
    else
        atreplinit() do repl
            if !isdefined(repl, :interface)
                repl.interface = REPL.setup_interface(repl)
            end
            Prompt.insert_keybindings()
            @async begin
                sleep(0.25)
                reinsert_after_pkg()
            end
            update_interface(repl.interface)
        end
    end

    if ccall(:jl_generating_output, Cint, ()) == 0
        include(joinpath(@__DIR__, "refresh_lines.jl"))
        include(joinpath(@__DIR__, "output_prompt_overwrite.jl"))
        include(joinpath(@__DIR__, "MarkdownHighlighter.jl"))
    end
end

if !(ccall(:jl_generating_output, Cint, ()) == 1)
    using TerminalRegressionTests
else

let
tracecompile_file = tempname()

content = """
const OhMyREPL = Base.require(Base.PkgId(Base.UUID("5fb14364-9ced-5910-84b2-373655c76a03"), "OhMyREPL"))
using OhMyREPL.REPL
OhMyREPL.TerminalRegressionTests.create_automated_test(
    tempname(),
    [c for c in "function foo(a = b())\nend\n\x4"],
    aggressive_yield=true) do emuterm
    repl = REPL.LineEditREPL(emuterm, false)
    repl.specialdisplay = REPL.REPLDisplay(repl)
    repl.interface = REPL.setup_interface(repl)
    OhMyREPL.Prompt.insert_keybindings(repl)
    REPL.run_repl(repl)
end
"""

p = run(pipeline(ignorestatus(`$(Base.julia_cmd()) --project=$(Base.active_project()) --trace-compile=$tracecompile_file --compiled-modules=no -e $content`); stderr=devnull))
if p.exitcode != 0
    # There seems to be some finalizer problem from VT100...
    # @warn "OhMyREPL internal precompilation failed"
end

num_prec = 0
for line in eachline(tracecompile_file)
    try
        eval(Meta.parse(line))
        num_prec += 1
    catch e
        # @warn line
    end
end

rm(tracecompile_file; force=true)

# @show num_prec ~251
end

end # end precompile block

end # module
