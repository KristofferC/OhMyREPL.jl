module BracketHighlighter

using JuliaSyntax: kind, Token, untokenize

using Crayons

import JuliaSyntax.@K_str

import OhMyREPL: add_pass!, PASS_HANDLER

mutable struct BracketHighlighterSettings
    crayon::Crayon
end

const BRACKETMATCHER_SETTINGS =
 BracketHighlighterSettings(Crayon(bold = :true, underline = :true))

function (matcher::BracketHighlighterSettings)(crayons::Vector{Crayon}, tokens::Vector{Token}, cursorpos::Int, str::AbstractString)
    left_bracket_match, right_bracket_match, matched = bracket_match(tokens, cursorpos, str)
    !matched && return
    crayons[left_bracket_match] = matcher.crayon
    crayons[right_bracket_match] = matcher.crayon
    return
end

setcrayon!(crayon::Crayon) = BRACKETMATCHER_SETTINGS.crayon = crayon
set_token!(crayon::Crayon) = setcrayon!(crayon)

add_pass!(PASS_HANDLER, "BracketHighlighter", BRACKETMATCHER_SETTINGS, true)

# Takes a string and a cursor index.
# Returns index of left matching bracket, right matching bracket
# and if there was a match at all as a 3 tuple.
const LEFT_DELIMS = [K"(", K"[", K"{"]
const RIGHT_DELIMS = [K")", K"]", K"}"]
function bracket_match(tokens::Vector{Token}, cursoridx::Int, str)
    enclosing_token_idx = -1
    char_counter = 0
    # find which token we are currently inside
    for (i, token) in enumerate(tokens)
        char_counter += length(untokenize(token, str))
        if char_counter >= cursoridx
            enclosing_token_idx = i
            break
        end
    end

    if enclosing_token_idx == -1
        return 0, 0, false
    end
    counts = zeros(Int, length(LEFT_DELIMS))

    left_match, left_idx, right_idx = 0, 0, 0
    # Search to the left
    for idx in enclosing_token_idx:-1:0
        idx == 0 && return 0, 0, false
        token = tokens[idx]
        (i = findfirst(isequal(kind(token)), RIGHT_DELIMS)) !== nothing && (counts[i] -= 1)

        if (i = findfirst(isequal(kind(token)), LEFT_DELIMS)) !== nothing
            if counts[i] == 0
                left_match = i
                left_idx = idx
                break
            else
                counts[i] += 1
            end
        end
        idx -= 1
    end

    # Search to the right
    for idx in enclosing_token_idx+1:length(tokens) + 1
        idx == length(tokens) + 1 && return 0, 0, false
        token = tokens[idx]
        LEFT_DELIMS[left_match] == kind(token) && (counts[left_match] -= 1)
        if RIGHT_DELIMS[left_match] == kind(token)
            if counts[left_match] == 0
                return left_idx, idx, true
            else
                counts[left_match] += 1
            end
        end
    end
    return 0, 0 , false
end


end # module
