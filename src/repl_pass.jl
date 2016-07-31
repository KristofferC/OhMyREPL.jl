using .ANSICodes

import .ANSICodes.ANSIToken
import Tokenize.Tokens.Token
import Tokenize.Lexers

using Logging
@Logging.configure(level=DEBUG)

type Pass
	f!
	enabled::Bool
	update_on_cursormovement::Bool
end

immutable ReplPassCollector
	ansitokens::Vector{ANSIToken}
	passes::Vector{Tuple{String, Pass}}
end

ReplPassCollector() = ReplPassCollector(ANSIToken[], Tuple{String, Pass}[])


function test_pass(io::IO, f, str::Union{String, IO}, cursorpos::Int = 1, cursormovement::Bool = false)
	rpc = ReplPassCollector()
	add_pass!(rpc, "TestPass", f)
	tokens = collect(Lexers.Lexer(str))
	apply_passes!(rpc, tokens, cursorpos, cursormovement)
	untokenize_with_ANSI(io, rpc.ansitokens, tokens)
end
test_pass(f, str::Union{String, IOBuffer}, cursorpos::Int = 1, cursormovement::Bool = false) =
		test_pass(STDOUT, f, str, cursorpos, cursormovement)


function test_passes(io::IO, rpc::ReplPassCollector, str::Union{String, IOBuffer}, cursorpos::Int = 1, cursormovement::Bool = false)
	b = IOBuffer()
	tokens = collect(Lexers.Lexer(str))
	apply_passes!(rpc, tokens, cursorpos, cursormovement)
	untokenize_with_ANSI(io, rpc.ansitokens, tokens)
end
test_passes(io::IO, str::Union{String, IO}, cursorpos::Int = 1, cursormovement::Bool = false) =
		test_passes(io, REPL_PASSES, str, cursorpos, cursormovement)
test_passes(str::Union{String, IO}, cursorpos::Int = 1, cursormovement::Bool = false) =
		test_passes(STDOUT, REPL_PASSES, str, cursorpos, cursormovement)



function untokenize_with_ANSI(io::IO, ansitokens::Vector{ANSIToken}, tokens::Vector{Token})
	@assert length(tokens) == length(ansitokens)
	print("\e[0m]")
	for (token, ansitoken) in zip(tokens, ansitokens)
		print(io, ansitoken, token)
		print(io, "\e[0m") # TODO Provide a user definable postfix?
	end
end
untokenize_with_ANSI(ansitokens::Vector{ANSIToken}, tokens::Vector{Token}) =
	untokenize_with_ANSI(STDOUT, ansitokens, tokens)


const REPL_PASSES = ReplPassCollector(ANSIToken[], Tuple{String, Pass}[])

function apply_passes!(rpc::ReplPassCollector, tokens::Vector{Token}, cursorpos::Int = 1, cursormovement::Bool = false)
	resize!(rpc.ansitokens, length(tokens))
	for i in 1:length(rpc.ansitokens)
		rpc.ansitokens[i] = ANSIToken()
	end

	for i in 1:length(rpc.passes)
		pass = rpc.passes[i][2]
		print(pass)
		if pass.enabled
			if cursormovement && !pass.update_on_cursormovement
				continue
			end
			# This is an enabled pass that should be run, so run it!
			print(pass)
			pass.f!(rpc.ansitokens, tokens, cursorpos)
		end
	end
end

apply_passes!(tokens::Vector{Token}, cursormovement::Bool) =
	apply_passes!(REPL_PASSES, tokens, cursormovement)


function write_results!(buff::IO, ansitokens::Vector{ANSIToken}, tokens::Vector{Token})
	for (ansitoken, token) in zip(ansitoken, tokens)
		ANSICodes.print_with_ANSI(buff, anistoken, string(tokens))
	end
	return buff
end

write_results!(buff::IO, tokens::Vector{Token}) = write_results(buff, REPL_PASSES, tokens)

write_results!(buff::IO, rpc::ReplPassCollector, tokens::Vector{Token}) =
	write_results(buff, rpc.ansitokens, tokens)


# Returns -1 if not found else index of where the pass is
function _find_pass(name::String)
	for i in 1:length(REPL_PASSES.passes)
		if REPL_PASSES.passes[i][1] == name
			return i
		end
	end
	return -1
end

function _check_pass_name(name::String, shouldexist::Bool)
	idx = _find_pass(name)
	if idx == -1 && shouldexist
		throw(ArgumentError("pass $name could not be found"))
	elseif idx != -1 && !shouldexist
		throw(ArgumentError("pass $name already exists"))
	end
	return idx
end


function add_pass!(rpc::ReplPassCollector, name::String, f, update_on_cursormovement::Bool = true)
	idx = _check_pass_name(name, false)
	push!(rpc.passes, (name, Pass(f, true, update_on_cursormovement)))
end
add_pass!(name::String, f, update_on_cursormovement::Bool = true) =
	add_pass!(REPL_PASSES, name, f, update_on_cursormovement)


function enable_pass!(rpc::ReplPassCollector, name::String, enabled::Bool)
	idx = _check_pass_name(name, true)
	rpc.passes[idx][2].enabled = enabled
end
enable_pass!(name::String, enabled::Bool) = enable_pass!(REPL_PASSES, name, enabled)


function set_prescedence!(name::String, presc::Int)
	error("TODO")
	pass_idx = _check_pass_name(name, true)
	if pass_idx == -1
	end
	presc = clamp(presc, 1, length(passes))
end




#=
function Base.show(io::IO, rpc::ReplPassCollector)

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