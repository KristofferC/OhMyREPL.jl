module BracketMatcher



type BracketMatcherSettings

end


const LEFT_DELIMS = [Tokens.lparen, Tokens.lsquare, Tokens.lbrace]

const RIGHT_DELIMS = [Tokens.rparen, Tokens.rsquare, Tokens.rbrace]

const JL_BRACKETMATCHER = JuliaBracketMatcher()


function (matcher::JuliaBracketMatcher)(rpc::ReplPassCollector, tokens::Vector{Token}, cursorpos::Int)
	left_bracket_match, right_bracket_match, matched = bracket_match(tokens, cursorpos)
	!matched && return
	set_underline!(rpc, left_bracket_match)
	set_underline!(rpc, right_bracket_match)
	return
end


set_active!()


add_pass!("BracketMatcher", JL_BRACKETMATCHER, true)



# Takes a string and a position in bytes of the cursor position
# Returns index of left matching bracket, right matching bracket
# and if there was a match at all as a 3 tuple.
function bracket_match(tokens::Vector{Token}, cursorpos::Int)
	if cursospos > sizeof(str)
		return 0, 0, false
	end

	# Find the index where the cursor currently is
	cursoridx = 0
	while cursoridx <= cursorpos
		cursoridx = nextind(str, cursoridx)
		if cursoridx >= sizeof(str)
			return 0, 0, false
		end
	end

	counts = zeros(Int, length(LEFT_DELIMS))
	idx = cursoridx

	left_match, left_idx, right_idx = 0, 0, 0

	while true
		idx = prevind(str, idx)
		idx <= 0 && return 0, 0, false

		(i = findfirst(RIGHT_DELIMS, str[idx])) != 0 && (counts[i] -= 1)
		if (i = findfirst(LEFT_DELIMS, str[idx])) != 0
			if counts[i] == 0
				left_match = i
				left_idx = idx
				break
			else
				counts[i] += 1
			end
		end
	end

	idx = cursoridx
	while true
		idx = nextind(str, idx)
		idx > length(str) && return 0, 0, false
		LEFT_DELIMS[left_match] == str[idx] && (counts[i] -= 1)
		if RIGHT_DELIMS[left_match] == str[idx]
			if counts[i] == 0
				return left_idx, idx, true
			else
				counts[i] += 1
			end
		end
	end
	return 0, 0 , false
end

end # module