using .ANSICodes

import .ANSICodes.ANSIToken
import Tokenize.Tokens
import Tokenize.Tokens: Token, kind, untokenize
import Tokenize.Lexers

#using Logging
#@Logging.configure(level=DEBUG)

macro debug(ex)
    return :()
end

type Pass
    f!
    enabled::Bool
    update_on_cursormovement::Bool
end

immutable PassHandler
    ansitokens::Vector{ANSIToken}
    passes::Vector{Tuple{Compat.UTF8String, Pass}}
end

PassHandler() = PassHandler(ANSIToken[], Tuple{String, Pass}[])
const PASS_HANDLER = PassHandler(ANSIToken[], Tuple{String, Pass}[])


function test_pass(io::IO, f, str::Union{String, IO}, cursorpos::Int = 1, cursormovement::Bool = false)
    rpc = PassHandler()
    add_pass!(rpc, "TestPass", f)
    tokens = collect(Lexers.Lexer(str))
    apply_passes!(rpc, tokens, cursorpos, cursormovement)
    untokenize_with_ANSI(io, rpc.ansitokens, tokens)
end
test_pass(f, str::Union{String, IOBuffer}, cursorpos::Int = 1, cursormovement::Bool = false) =
        test_pass(STDOUT, f, str, cursorpos, cursormovement)


function test_passes(io::IO, rpc::PassHandler, str::Union{String, IOBuffer}, cursorpos::Int = 1, cursormovement::Bool = false)
    b = IOBuffer()
    tokens = collect(Lexers.Lexer(str))
    apply_passes!(rpc, tokens, cursorpos, cursormovement)
    untokenize_with_ANSI(io, rpc.ansitokens, tokens)
end
test_passes(rpc::PassHandler, str::Union{String, IOBuffer}, cursorpos::Int = 1, cursormovement::Bool = false) =
    test_passes(STDOUT, rpc, str, cursorpos, cursormovement)

# We need to pass in the buffer here so we know when to indent for a new line
function untokenize_with_ANSI(io::IO, ansitokens::Vector{ANSIToken}, tokens::Vector{Token})
    @assert length(tokens) == length(ansitokens)
    print("\e[0m")
    z = 1
    for (token, ansitoken) in zip(tokens, ansitokens)
        print(io, ansitoken)
        for c in untokenize(token)
            print(io, c)
            c == '\n' && print(io, " "^7)
        end
        print(io, "\e[0m") # TODO Provide a user definable postfix?
    end
end
untokenize_with_ANSI(io::IO, rpc::PassHandler, tokens::Vector{Token}) = untokenize_with_ANSI(io, rpc.ansitokens, tokens)
untokenize_with_ANSI(ansitokens::Vector{ANSIToken}, tokens::Vector{Token}) =
    untokenize_with_ANSI(STDOUT, ansitokens, tokens)


function apply_passes!(rpc::PassHandler, tokens::Vector{Token}, cursorpos::Int = 1, cursormovement::Bool = false)
    resize!(rpc.ansitokens, length(tokens))
    for i in 1:length(rpc.ansitokens)
        rpc.ansitokens[i] = ANSIToken()
    end

    for i in 1:length(rpc.passes)
        pass = rpc.passes[i][2]
        if pass.enabled
            if cursormovement && !pass.update_on_cursormovement
                continue
            end
            # This is an enabled pass that should be run, so run it!
            pass.f!(rpc.ansitokens, tokens, cursorpos)
        end
    end
end

write_results!(buff::IO, rpc::PassHandler, tokens::Vector{Token}) =
    write_results(buff, rpc.ansitokens, tokens)

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


function add_pass!(rpc::PassHandler, name::String, f, update_on_cursormovement::Bool = true)
    idx = _check_pass_name(rpc, name, false)
    push!(rpc.passes, (name, Pass(f, true, update_on_cursormovement)))
end


function enable_pass!(rpc::PassHandler, name::String, enabled::Bool)
    idx = _check_pass_name(rpc, name, true)
    rpc.passes[idx][2].enabled = enabled
end


function set_prescedence!(rpc::PassHandler, name::String, presc::Int)
    error("TODO")
    pass_idx = _check_pass_name(name, true)
    if pass_idx == -1
    end
    presc = clamp(presc, 1, length(passes))
end


#=
function Base.show(io::IO, rpc::PassHandler)

    print(io, "+-----------------------+----------+")
    print(io, "| Pass name             | Enabled  |")
    print(io, "+-----------------------+----------+")
    for pass in rpc.passes
        name = pass[1]
        if length(name) >
    print(io, "| ", @sprintf(pass[1], )
    for pass in
end
=#
