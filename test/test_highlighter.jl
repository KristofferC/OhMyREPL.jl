module TestSyntaxHighlighter


using Base.Test

using PimpMyREPL
import PimpMyREPL.ANSICodes: ANSIToken, ANSIValue
import  PimpMyREPL.Passes.SyntaxHighlighter.SYNTAX_HIGHLIGHTER_SETTINGS

using Tokenize

b = IOBuffer()
str = "function :foobar, foobar # foobar"
PimpMyREPL.test_pass(b, SYNTAX_HIGHLIGHTER_SETTINGS, str)


println("Original string: ", str)
println("Highlighted string: ", takebuf_string(b))

println()

str = "(function :foobar, foobar )# foobar"
PimpMyREPL.test_passes(b, PimpMyREPL.PASS_HANDLER, str, 3)

println("Original string: ", str)
println("Highlighted string: ", takebuf_string(b))
println()

end
