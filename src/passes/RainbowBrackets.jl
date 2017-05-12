module RainbowBrackets

using Compat
using Crayons

using Tokenize
using Tokenize.Tokens
import Tokenize.Tokens: Token, kind, startpos, endpos, untokenize

import OhMyREPL: add_pass!, PASS_HANDLER

type RainBowTokens
    parenthesis_tokens::Vector{Crayon}
    brackets_tokens::Vector{Crayon}
    curly_tokens::Vector{Crayon}
    error_token::Crayon
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
 RainBowTokens([Crayon(foreground = :yellow), Crayon(foreground = :green)],
                         [Crayon(foreground = :cyan), Crayon(foreground = :magenta)],
                         [Crayon(foreground = :light_gray), Crayon(foreground = :default)],
                          Crayon(foreground = :light_red))

const RAINBOW_TOKENS_256 =
 RainBowTokens([Crayon(foreground = 178), Crayon(foreground = 161), Crayon(foreground =  034), Crayon(foreground = 200)],
                         [Crayon(foreground = 045), Crayon(foreground = 099), Crayon(foreground = 033)],
                         [Crayon(foreground = 223), Crayon(foreground = 130), Crayon(foreground = 202)],
                          Crayon(foreground = 196, bold = true))

const RAINBOWBRACKETS_SETTINGS = RainbowBracketsSettings(RAINBOW_TOKENS_256, RAINBOW_TOKENS_16, is_windows() ? RAINBOW_TOKENS_16 : RAINBOW_TOKENS_256)


@compat function (rainbow::RainbowBracketsSettings)(ansitokens::Vector{Crayon}, tokens::Vector{Token}, cursorpos::Int)
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
