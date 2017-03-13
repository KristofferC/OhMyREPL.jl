module RainbowBrackets

using Compat

using Tokenize
using Tokenize.Tokens
import Tokenize.Tokens: Token, kind, startpos, endpos, untokenize

using ...ANSICodes
import ...ANSICodes: ANSIToken, ANSIValue, merge!

import OhMyREPL: add_pass!, PASS_HANDLER

type RainBowTokens
    parenthesis_tokens::Vector{ANSIToken}
    brackets_tokens::Vector{ANSIToken}
    curly_tokens::Vector{ANSIToken}
    error_token::ANSIToken
end

type RainbowBracketsSettings
    tokens_256::RainBowTokens
    tokens_16::RainBowTokens
    active::RainBowTokens
end

function get_color(rainbow::RainbowBracketsSettings, k::Tokens.Kind, i)
    @assert i >= 0
    toks = rainbow.active
    i == 0 && return toks.error_token
    if k == Tokens.LPAREN || k == Tokens.RPAREN
        return toks.parenthesis_tokens[mod1(i, length(toks.parenthesis_tokens))]
    elseif k == Tokens.LSQUARE || k == Tokens.RSQUARE
        return toks.brackets_tokens[mod1(i, length(toks.brackets_tokens))]
    else
        return toks.curly_tokens[mod1(i, length(toks.curly_tokens))]
    end
end

activate_16colors() = RAINBOWBRACKETS_SETTINGS.active = RAINBOWBRACKETS_SETTINGS.tokens_16
activate_256colors() = RAINBOWBRACKETS_SETTINGS.active = RAINBOWBRACKETS_SETTINGS.tokens_256


const RAINBOW_TOKENS_16 =
 RainBowTokens([ANSIToken(foreground = :yellow), ANSIToken(foreground = :green)],
                         [ANSIToken(foreground = :cyan), ANSIToken(foreground = :magenta)],
                         [ANSIToken(foreground = :light_gray), ANSIToken(foreground = :default)],
                          ANSIToken(foreground = :light_red))

const RAINBOW_TOKENS_256 =
 RainBowTokens([ANSIToken(foreground = 178), ANSIToken(foreground = 161), ANSIToken(foreground =  034), ANSIToken(foreground = 200)],
                         [ANSIToken(foreground = 045), ANSIToken(foreground = 099), ANSIToken(foreground = 033)],
                         [ANSIToken(foreground = 223), ANSIToken(foreground = 130), ANSIToken(foreground = 202)],
                          ANSIToken(foreground = 196, bold = true))

const RAINBOWBRACKETS_SETTINGS = RainbowBracketsSettings(RAINBOW_TOKENS_256, RAINBOW_TOKENS_16, is_windows() ? RAINBOW_TOKENS_16 : RAINBOW_TOKENS_256)


@compat function (rainbow::RainbowBracketsSettings)(ansitokens::Vector{ANSIToken}, tokens::Vector{Token}, cursorpos::Int)
    p, s, b = 0, 0, 0
    for (i, t) in enumerate(tokens)
        k = kind(t)
        if k == Tokens.LPAREN
            p += 1
            ansitokens[i] = get_color(rainbow, k, p)
        elseif k == Tokens.RPAREN
            ansitokens[i] = get_color(rainbow, k, p)
            p = max(0, p - 1)
        elseif k == Tokens.LSQUARE
            s += 1
            ansitokens[i] = get_color(rainbow, k, s)
        elseif k == Tokens.RSQUARE
            ansitokens[i] = get_color(rainbow, k, s)
            s = max(0, s - 1)
        elseif k == Tokens.LBRACE
            b += 1            
            ansitokens[i] = get_color(rainbow, k, b)
        elseif k == Tokens.RBRACE
            ansitokens[i] = get_color(rainbow, k, b)
            b = max(0, b - 1)
        end
    end
    return
end

add_pass!(PASS_HANDLER, "RainbowBrackets", RAINBOWBRACKETS_SETTINGS, false)

end