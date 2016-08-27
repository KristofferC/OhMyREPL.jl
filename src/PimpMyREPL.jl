"""
A package that provides a new REPL that has syntax highlighting,
bracket matching and other nifty features.
"""
module PimpMyREPL

using Tokenize

using Compat
import Compat: UTF8String, String

# http://stackoverflow.com/a/39174202
if VERSION > v"0.5-"
    ORIGINAL_STDERR = STDERR
    err_rd, err_wr = redirect_stderr()
    include("ErrorMessages.jl")
    REDIRECTED_STDERR = STDERR
    err_stream = redirect_stderr(ORIGINAL_STDERR)
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
