module TestBracketHighlighter

using Test
using OhMyREPL

b = IOBuffer()
str = "(function :foobar, foobar )# foobar"
idx = 3 #  ^
OhMyREPL.test_pass(b, OhMyREPL.Passes.BracketHighlighter.BRACKETMATCHER_SETTINGS,
    str, idx)

println("Original string: ", str)
println("BracketMatched string: ", String(take!(b)))
println()

end
