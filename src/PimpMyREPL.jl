"""
A package that provides a new REPL that has syntax highlighting,
bracket matching and other nifty features.
"""
module PimpMyREPL

using Tokenize

using Compat
import Compat: UTF8String, String

if VERSION > v"0.5-"
    prev_stdout = STDERR
    redirect_stderr()
    include("ErrorMessages.jl")
    redirect_stderr(prev_stdout)
end

include("ANSICodes.jl")
include("repl_pass.jl")
include(joinpath("passes", "Passes.jl"))
include("repl.jl")
include("bracket_inserter.jl")

using .ANSICodes
export ANSICodes


function colorscheme!(name::String)
    Passes.SyntaxHighlighter.activate!(Passes.SyntaxHighlighter.SYNTAX_HIGHLIGHTER_SETTINGS,
                                       name)
end

export colorscheme!

export enable_autocomplete_brackets

if isdefined(Base, :active_repl)
    Prompt.hijack_REPL()
end

end # module
