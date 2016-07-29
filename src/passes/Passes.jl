module Passes

using ..Tokenize
import ..Tokenize: Tokens
import ..Tokenize.Tokens: Kind, Token, kind, iskeyword, untokenize

"""
A type to indicate which parameters for an ANSIToken are active .
"""
type ANSITokenActivations
	foreground::Bool
	background::Bool
	bold::Bool
	underline::Bool
	strikethrough::Bool
	italics::Bool
end

function enable!(x::ANSITokenActivations, ansitype::Symbol, enable::Bool)
	if !(ansitype in fieldnames(x))
		throw(ArgumentError("invalid type $ansitype, valid ones are ", fieldnames()))
	else
		x.ansitype = enable
	return x
end


"""
A type that represents contains both an ANSIToken and an ANSITokenActivations
type. This type can be useful to have in the settings to a repl pass because we
need to know both if we should write something to the ANSIToken and what we should
write.
"""
type ANSITokenSettings
	ansitoken::ANSIToken
	activations::ANSITokenActivations
end

enable!(x::ANSITokenSettings, ansitype::Symbol, enable::Bool) = enable!(x.activations, ansitype, enable)

include("SyntaxHighlighter.jl")
include("BracketMatcher.jl")

end # module