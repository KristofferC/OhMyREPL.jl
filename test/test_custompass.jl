module CustomPassTest

using Base.Test

using OhMyREPL
using Tokenize
using Crayons


function foobar_bluify(crayons, tokens, ::Int)
    for (i, (crayon, tok)) in enumerate(zip(crayons, tokens))
        println(tok)
        if (Tokenize.Tokens.kind(tok) == Tokenize.Tokens.IDENTIFIER
               && Tokenize.Tokens.untokenize(tok) == "foobar")
            crayons[i] = Crayon(foreground = :blue)
        end
    end
end

b = IOBuffer()

str = "function :foobar, foobar # foobar"
OhMyREPL.test_pass(b, foobar_bluify, str)

println("Original string: ", str)
println("Bluified string: ", String(take!(b)))
println()

end
