module TestBracketMatcher


using Base.Test

using PimpMyREPL
import PimpMyREPL.ANSICodes: ANSIToken, ANSIValue

using Tokenize



b = IOBuffer()
str = "(function :foobar, foobar )# foobar"
idx = 3 #  ^
PimpMyREPL.test_pass(b, PimpMyREPL.Passes.BracketMatcher.BRACKETMATCHER_SETTINGS,
    str, idx)

println("Original string: ", str)
println("BracketMatched string: ", takebuf_string(b))

end