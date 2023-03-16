import JuliaSyntax
using JuliaSyntax: kind, @K_str, Token, tokenize, untokenize
using Printf

const RESET = Crayon(reset = true)

mutable struct Pass
    f!
    enabled::Bool
    update_on_cursormovement::Bool
end

struct PassHandler
    accum_crayons::Vector{Crayon}
    crayons::Vector{Crayon}
    passes::Vector{Tuple{String, Pass}} # This is a stupid type and I should feel stupid
end

PassHandler() = PassHandler(Crayon[], Crayon[], Tuple{String, Pass}[])
const PASS_HANDLER = PassHandler()

function test_pass(io::IO, f, str::Union{String, IO}, cursorpos::Int = 1, cursormovement::Bool = false)
    rpc = PassHandler()
    add_pass!(rpc, "TestPass", f)
    tokens = tokenize(str)
    apply_passes!(rpc, tokens, str, cursorpos, cursormovement)
    untokenize_with_ANSI(io, rpc.accum_crayons, tokens, str)
end

test_pass(f, str::Union{String, IOBuffer}, cursorpos::Int = 1, cursormovement::Bool = false) =
        test_pass(stdout, f, str, cursorpos, cursormovement)

function test_passes(io::IO, rpc::PassHandler, str::Union{String, IOBuffer}, cursorpos::Int = 1, cursormovement::Bool = false)
    b = IOBuffer()
    tokens = tokenize(str)
    apply_passes!(rpc, tokens, str, cursorpos, cursormovement)
    untokenize_with_ANSI(io, rpc.accum_crayons, tokens, str)
end

test_passes(rpc::PassHandler, str::Union{String, IOBuffer}, cursorpos::Int = 1, cursormovement::Bool = false) =
    test_passes(stdout, rpc, str, cursorpos, cursormovement)

function untokenize_with_ANSI(io::IO, crayons::Vector{Crayon}, tokens::Vector{Token}, str, indent = 7)
    @assert length(tokens) == length(crayons)
    print(io, RESET)
    z = 1
    for (token, crayon) in zip(tokens, crayons)
        print(io, crayon)
        for c in untokenize(token, str)
            print(io, c)
            c == '\n' && print(io, " "^indent)
        end
        print(io, RESET)
    end
end
untokenize_with_ANSI(io::IO, rpc::PassHandler, tokens::Vector{Token}, str::AbstractString, indent = 7) = untokenize_with_ANSI(io, rpc.accum_crayons, tokens, str, indent)
untokenize_with_ANSI(crayons::Vector{Crayon}, tokens::Vector{Token}, str::AbstractString, indent = 7) =
    untokenize_with_ANSI(stdout, crayons, tokens, str, indent)

function merge!(t1::Vector{Crayon}, t2::Vector{Crayon})
    @assert length(t1) == length(t2)
    for i in eachindex(t1)
        t1[i] = merge(t1[i], t2[i])
    end
    return t1
end

function apply_passes!(rpc::PassHandler, tokens::Vector{Token}, str::AbstractString, cursorpos::Int = 1, cursormovement::Bool = false)
    resize!(rpc.crayons, length(tokens))
    resize!(rpc.accum_crayons, length(tokens))
    fill!(rpc.accum_crayons, Crayon())
    for i in reverse(1:length(rpc.passes))
        fill!(rpc.crayons, Crayon())
        pass = rpc.passes[i][2]
        if pass.enabled
            if cursormovement && !pass.update_on_cursormovement
                continue
            end
            # This is an enabled pass that should be run, so run it!
            pass.f!(rpc.crayons, tokens, cursorpos, str)
            merge!(rpc.accum_crayons, rpc.crayons)
        end
    end
end

write_results!(buff::IO, rpc::PassHandler, tokens::Vector{Token}) =
    write_results(buff, rpc.accum_crayons, tokens)

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
    return rpc
end
add_pass!(name::String, f, update_on_cursormovement::Bool = true) = add_pass!(PASS_HANDLER, name, f, update_on_cursormovement)

function enable_pass!(rpc::PassHandler, name::String, enabled::Bool)
    idx = _check_pass_name(rpc, name, true)
    rpc.passes[idx][2].enabled = enabled
    return rpc
end
enable_pass!(name::String, enabled::Bool) = enable_pass!(PASS_HANDLER, name, enabled)

function Base.show(io::IO, rpc::PassHandler)
    println(io, Crayon(bold = true),
                "──────────────────────────────────", RESET)
    println(io, " #   Pass name             Enabled  ")
    println(io, "──────────────────────────────────")
    for (i, pass) in enumerate(rpc.passes)
        name = pass[1]
        if length(name) >= 21
            name = name[1:21-3] * "..."
        end
        println(io, " $i   ", @sprintf("%-21s %-8s ", name, pass[2].enabled))
    end
    print(io, Crayon(bold = true),
                "──────────────────────────────────", RESET)
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
