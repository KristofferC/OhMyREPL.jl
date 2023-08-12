module CustomPassTest

using Test
using OhMyREPL
using JuliaSyntax
import JuliaSyntax: kind, untokenize, @K_str
using Crayons

function foobar_bluify(crayons, tokens, ::Int, str::AbstractString)
    for (i, (crayon, tok)) in enumerate(zip(crayons, tokens))
        println(tok)
        if (kind(tok) == K"Identifier" && untokenize(tok, str) == "foobar")
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
