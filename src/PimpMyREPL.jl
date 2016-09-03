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

export colorscheme!

export enable_autocomplete_brackets

function __init__()
    if isdefined(Base, :active_repl)
        Prompt.insert_keybindings()
    end

    ORIGINAL_STDERR = STDERR
    err_rd, err_wr = redirect_stderr()
    Base.LineEdit.refresh_line(s) = (Base.LineEdit.refresh_multi_line(s); PimpMyREPL.Prompt.rewrite_with_ANSI(s))
    if VERSION > v"0.5-"
       include(joinpath(dirname(@__FILE__), "ErrorMessages.jl"))
    end
    REDIRECTED_STDERR = STDERR
    err_stream = redirect_stderr(ORIGINAL_STDERR)
end



end # module
