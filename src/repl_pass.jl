using .ANSICodes

import .ANSICodes: ANSIToken, ResetToken, merge!
import Tokenize.Tokens
import Tokenize.Tokens: Token, kind, untokenize
import Tokenize.Lexers

type Pass
    f!
    enabled::Bool
    update_on_cursormovement::Bool
end

immutable PassHandler
    accum_ansitokens::Vector{ANSIToken}
    ansitokens::Vector{ANSIToken}
    passes::Vector{Tuple{Compat.UTF8String, Pass}} # This is a stupid type and I should feel stupid
end

PassHandler() = PassHandler(ANSIToken[], ANSIToken[], Tuple{String, Pass}[])
const PASS_HANDLER = PassHandler()

function test_pass(io::IO, f, str::Union{String, IO}, cursorpos::Int = 1, cursormovement::Bool = false)
    rpc = PassHandler()
    add_pass!(rpc, "TestPass", f)
    tokens = collect(Lexers.Lexer(str))
    apply_passes!(rpc, tokens, cursorpos, cursormovement)
    untokenize_with_ANSI(io, rpc.accum_ansitokens, tokens)
end

test_pass(f, str::Union{String, IOBuffer}, cursorpos::Int = 1, cursormovement::Bool = false) =
        test_pass(STDOUT, f, str, cursorpos, cursormovement)

function test_passes(io::IO, rpc::PassHandler, str::Union{String, IOBuffer}, cursorpos::Int = 1, cursormovement::Bool = false)
    b = IOBuffer()
    tokens = collect(Lexers.Lexer(str))
    apply_passes!(rpc, tokens, cursorpos, cursormovement)
    untokenize_with_ANSI(io, rpc.accum_ansitokens, tokens)
end

test_passes(rpc::PassHandler, str::Union{String, IOBuffer}, cursorpos::Int = 1, cursormovement::Bool = false) =
    test_passes(STDOUT, rpc, str, cursorpos, cursormovement)

function untokenize_with_ANSI(io::IO, ansitokens::Vector{ANSIToken}, tokens::Vector{Token})
    @assert length(tokens) == length(ansitokens)
    print(io, ResetToken())
    z = 1
    for (token, ansitoken) in zip(tokens, ansitokens)
        print(io, ansitoken)
        for c in untokenize(token)
            print(io, c)
            c == '\n' && print(io, " "^7)
        end
        print(io, ResetToken())
    end
end
untokenize_with_ANSI(io::IO, rpc::PassHandler, tokens::Vector{Token}) = untokenize_with_ANSI(io, rpc.accum_ansitokens, tokens)
untokenize_with_ANSI(ansitokens::Vector{ANSIToken}, tokens::Vector{Token}) =
    untokenize_with_ANSI(STDOUT, ansitokens, tokens)

function apply_passes!(rpc::PassHandler, tokens::Vector{Token}, cursorpos::Int = 1, cursormovement::Bool = false)
    resize!(rpc.ansitokens, length(tokens))
    resize!(rpc.accum_ansitokens, length(tokens))
    fill!(rpc.accum_ansitokens, ANSIToken())
    for i in reverse(1:length(rpc.passes))
        fill!(rpc.ansitokens, ANSIToken())
        pass = rpc.passes[i][2]
        if pass.enabled
            if cursormovement && !pass.update_on_cursormovement
                continue
            end
            # This is an enabled pass that should be run, so run it!
            pass.f!(rpc.ansitokens, tokens, cursorpos)
            merge!(rpc.accum_ansitokens, rpc.ansitokens)
        end
    end
end

write_results!(buff::IO, rpc::PassHandler, tokens::Vector{Token}) =
    write_results(buff, rpc.accum_ansitokens, tokens)

# Returns -1 if not found else index of where the pass is
function _find_pass(rpc::PassHandler, name::String)
    for i in 1:length(rpc.passes)
        if rpc.passes[i][1] == name
            return i
        end
    end
    return -1
end

function _check_pass_name(rpc::PassHandler, name::String, shouldexist::Bool)
    idx = _find_pass(rpc, name)
    if idx == -1 && shouldexist
        throw(ArgumentError("pass $name could not be found"))
    elseif idx != -1 && !shouldexist
        throw(ArgumentError("pass $name already exists"))
    end
    return idx
end

function get_pass(rpc::PassHandler, name::String)
    idx = idx = _check_pass_name(rpc, name, true)
    return rpc.passes[idx][2].f!
end

function add_pass!(rpc::PassHandler, name::String, f, update_on_cursormovement::Bool = true)
    idx = _check_pass_name(rpc, name, false)
    insert!(rpc.passes, 1, (name, Pass(f, true, update_on_cursormovement)))
end
add_pass!(name::String, f, update_on_cursormovement::Bool = true) = add_pass!(PASS_HANDLER, name, f, update_on_cursormovement)

function enable_pass!(rpc::PassHandler, name::String, enabled::Bool)
    idx = _check_pass_name(rpc, name, true)
    rpc.passes[idx][2].enabled = enabled
end
enable_pass!(name::String, enabled::Bool) = enable_pass!(PASS_HANDLER, name, enabled)

function Base.show(io::IO, rpc::PassHandler)
    println(io, ANSIToken(bold = true),
                "----------------------------------", ResetToken())
    println(io, " #   Pass name             Enabled  ")
    println(io, "----------------------------------")
    for (i, pass) in enumerate(rpc.passes)
        name = pass[1]
        if length(name) >= 21
            name = name[1:21-3] * "..."
        end
        println(io, " $i   ", @sprintf("%-21s %-8s ", name, pass[2].enabled))
    end
    print(io, ANSIToken(bold = true),
                "----------------------------------", ResetToken())
end

prescedence!(rpc::PassHandler, name::String, presc::Int) = prescedence!(rpc, _check_pass_name(rpc, name, true), presc)
prescedence!(name::String, presc::Int) = prescedence!(PASS_HANDLER, name, presc)

function prescedence!(rpc::PassHandler, pass_idx::Int, presc::Int)
    pass = rpc.passes[pass_idx]
    presc = clamp(presc, 1, length(rpc.passes))
    deleteat!(rpc.passes, pass_idx)
    insert!(rpc.passes, presc, pass)
    return rpc
end
prescedence!(pass_idx::Int, presc::Int) = prescedence!(PASS_HANDLER, pass_idx, presc)


