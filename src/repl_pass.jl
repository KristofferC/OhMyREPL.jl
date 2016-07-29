using .ANSICodes

import ANSICodes.ANSIToken
import Tokenize.Tokens.Token
import Tokenize.Lexers


type Pass
	f
	enabled::Bool
	update_on_cursormovement::Bool
end

immutable ReplPassCollector
	ansitokens::Vector{ANSIToken}
	passes::Vector{Tuple{String, Pass}}
end

ReplPassCollector() = ReplPassCollector(ANSIToken[], Tuple{String, Pass}[])

function testpass(f, str::String, cursorpos::Int)
	rpc = ReplPassCollector()
	add_pass!(rpc)
	tokens = collect(Lexers.Lexer(b))
	apply_passes(rpc, collect())
end

function testpasses(str::String, cursorpos::Int = 1)
	b = IOBuffer()
	apply_passes(collect(Lexers.Lexer(b)))
	write_results!(buff, )
end

const REPL_PASSES = ReplPassCollector(ANSIToken[], Tuple{String, Pass}[])

function apply_passes!(rpc::ReplPassCollector, tokens::Vector{Token}, cursormovement::Bool = false)
	resize!(rpc.ansitokens, length(tokens))
	for i in 1:length(tokens)
		rpc.ansitokens[i] = ANSIToken()
	end
	for i in 1:length(rpc.passes)
		pass = rpc.passes[i][2]
		if pass.enabled
			if cursormovement && !pass.update_on_cursormovement
				continue
			end
			# This is an enabled pass that should be run, so run it!
			pass.f!(rpc.ansitokens, tokens)
		end
	end
end

apply_passes!(tokens::Vector{Token}, cursormovement::Bool) =
	apply_passes!(REPL_PASSES, tokens, cursormovement)


function write_results!(buff::IO, ansitokens::Vector{ANSITokens}, tokens::Vector{Token})
	for ansitoken, token in zip(ansitoken, tokens)
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
	push!(REPL_PASSES.passes, (name, Pass(f, true, update_on_cursormovement)))
end
add_pass!(name::String, f, update_on_cursormovement::Bool = true) =
	add_pass!(REPL_PASSES, name, f, update_on_cursormovement)


function enable_pass!(rpc::ReplPassCollector, name::String, enabled::Bool)
	idx = _check_pass_name(name, true)
	REPL_PASSES.passes[idx][2].enabled = enabled
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