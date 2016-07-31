module CustomPassTest

using Base.Test

using PimpMyREPL
import PimpMyREPL.ANSICodes: ANSIToken, ANSIValue

using Tokenize


# untokenize_with_ansi
#=
ansitokens = [ANSIToken(foreground = :magenta),
              ANSIToken(background = :blue),
              ANSIToken(background = :blue),
              ANSIToken(background = :red)]

# Two tokens
tokens = collect(tokenize("function foo"))
b = IOBuffer()
PimpMyREPL.untokenize_with_ANSI(b, tokens, ansitokens)
print(takebuf_string(b))
=#



function foobar_bluify(ansitokens, tokens, ::Int)
    for (ansitok, tok) in zip(ansitokens, tokens)
        println(tok)
        if (Tokenize.Tokens.kind(tok) == Tokenize.Tokens.Identifier
               && untokenize(tok) == "foobar")
            ansitok.foreground = ANSIValue(:foreground, :blue)
        end
    end
end

b = IOBuffer()

PimpMyREPL.test_pass(b, foobar_bluify, "function :foobar, foobar # foobar")

show(takebuf_string(b))
end