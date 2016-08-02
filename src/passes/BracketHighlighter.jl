module BracketHighlighter

using Compat

using Tokenize
using Tokenize.Tokens
import Tokenize.Tokens: Token, kind, startpos, endpos, untokenize

using ...ANSICodes
import ...ANSICodes: ANSIToken, ANSIValue, update!

import PimpMyREPL: add_pass!, PASS_HANDLER

type BracketHighlighterSettings
    token::ANSIToken
end

const BRACKETMATCHER_SETTINGS =
 BracketHighlighterSettings(ANSIToken(bold = :true, underline = :true))

@compat function (matcher::BracketHighlighterSettings)(ansitokens::Vector{ANSIToken}, tokens::Vector{Token}, cursorpos::Int)
    left_bracket_match, right_bracket_match, matched = bracket_match(tokens, cursorpos)
    !matched && return
    update!(ansitokens[left_bracket_match], matcher.token)
    update!(ansitokens[right_bracket_match], matcher.token)
    return
end

add_pass!(PASS_HANDLER, "BracketHighlighter", BRACKETMATCHER_SETTINGS, true)

# Takes a string and a cursor index.
# Returns index of left matching bracket, right matching bracket
# and if there was a match at all as a 3 tuple.
const LEFT_DELIMS = [Tokens.LPAREN, Tokens.LSQURE, Tokens.LBRACE]
const RIGHT_DELIMS = [Tokens.RPAREN, Tokens.RSQUARE, Tokens.RBRACE]
function bracket_match(tokens::Vector{Token}, cursoridx::Int)
    enclosing_token_idx = -1
    char_counter = 0
    # find which token we are currently inside
    for (i, token) in enumerate(tokens)
        char_counter += length(untokenize(token))
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
        (i = findfirst(RIGHT_DELIMS, kind(token))) != 0 && (counts[i] -= 1)

        if (i = findfirst(LEFT_DELIMS, kind(token))) != 0
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
