module TestBracketMatcher


using Base.Test

using PimpMyREPL
import PimpMyREPL.ANSICodes: ANSIToken, ANSIValue

using Tokenize


str = "()(  foo  )"
idx = 3 #  ^
PimpMyREPL.test_pass(PimpMyREPL.Passes.BracketMatcher.BRACKETMATCHER_SETTINGS,
    str, idx)


end