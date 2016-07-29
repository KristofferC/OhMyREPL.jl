"""
A package that provides a new REPL that has syntax highlighting,
bracket matching and other nifty features.
"""
module PimpMyREPL

using Tokenize

include("ANSIData.jl")
include("repl_pass.jl")
include(joinpath("passes", "Passes.jl"))
include("repl.jl")

#if isdefined(Base, :active_repl)
#    Prompt.run_highlightREPL()
#end

end # module
