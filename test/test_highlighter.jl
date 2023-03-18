module TestSyntaxHighlighter

using Test

using OhMyREPL
import  OhMyREPL.Passes.SyntaxHighlighter.SYNTAX_HIGHLIGHTER_SETTINGS

OhMyREPL.colorscheme!("Monokai16")

b = IOBuffer()
str = "function :foobar, foobar # foobar"
OhMyREPL.test_pass(b, SYNTAX_HIGHLIGHTER_SETTINGS, str)


println("Original string: ", str)
println("Highlighted string: ", String(take!(b)))

println()

str = "(function :foobar, foobar @foobar())# foobar"
OhMyREPL.test_passes(b, OhMyREPL.PASS_HANDLER, str, 3)

println("Original string: ", str)
println("Highlighted string: ", String(take!(b)))
println()

end
