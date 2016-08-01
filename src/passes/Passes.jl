module Passes

#using Tokenize
#import Tokenize.Tokens: Kind, Token, kind, iskeyword, untokenize

using ..ANSICodes
import ..ANSICodes.ANSIToken

include("SyntaxHighlighter.jl")
include("BracketMatcher.jl")

end # module