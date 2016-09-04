__precompile__()
"""
A package that provides a new REPL that has syntax highlighting,
bracket matching and other nifty features.
"""
module PimpMyREPL

using Tokenize

using Compat
import Compat: UTF8String, String

# http://stackoverflow.com/a/39174202

export colorscheme!, colorschemes, enable_autocomplete_brackets, test_colorscheme

include("ANSICodes.jl")
include("repl_pass.jl")
include("repl.jl")
include(joinpath("passes", "Passes.jl"))

include("bracket_inserter.jl")

using .ANSICodes
export ANSICodes


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
    @time 1+1
    #= Comments look like this =#
    z = funccall(x, y)
    5 * 3 + 2 - 1
end
"""

function test_colorscheme(name::String, str::String = TEST_STR)
    syntaxpass = get_pass(PASS_HANDLER, "SyntaxHighlighter")
    active = syntaxpass.active
    colorscheme!(name)
    test_pass(Passes.SyntaxHighlighter.SYNTAX_HIGHLIGHTER_SETTINGS, str)
    syntaxpass.active = active
    return
end


function __init__()
    if isdefined(Base, :active_repl)
        Prompt.insert_keybindings()
    end

    ORIGINAL_STDERR = STDERR
    err_rd, err_wr = redirect_stderr()
    reader = @async readstring(err_rd)
    Base.LineEdit.refresh_line(s) = (Base.LineEdit.refresh_multi_line(s); PimpMyREPL.Prompt.rewrite_with_ANSI(s))
    if VERSION > v"0.5-"
        include(joinpath(dirname(@__FILE__), "ErrorMessages.jl"))
    end
    wait(reader)
    REDIRECTED_STDERR = STDERR
    err_stream = redirect_stderr(ORIGINAL_STDERR)
end

end # module
