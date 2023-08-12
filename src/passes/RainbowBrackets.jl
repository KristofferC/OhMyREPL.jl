module RainbowBrackets

using Crayons
import JuliaSyntax: kind, Kind, @K_str, Token

import OhMyREPL: add_pass!, PASS_HANDLER, SUPPORTS_256_COLORS

using ..SyntaxHighlighter

mutable struct RainBowTokens
    parenthesis_tokens::Vector{Crayon}
    brackets_tokens::Vector{Crayon}
    curly_tokens::Vector{Crayon}
    error_token::Crayon
end

mutable struct RainbowBracketsSettings
    tokens_256::RainBowTokens
    tokens_16::RainBowTokens
    active::RainBowTokens
end

function get_color(rainbow::RainbowBracketsSettings, k::Kind, i)
    @assert i >= 0
    toks = rainbow.active
    i == 0 && return toks.error_token
    if k == K"(" || k == K")"
        return toks.parenthesis_tokens[mod1(i, length(toks.parenthesis_tokens))]
    elseif k == K"[" || k == K"]"
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

const RAINBOWBRACKETS_SETTINGS = RainbowBracketsSettings(RAINBOW_TOKENS_256, RAINBOW_TOKENS_16,
        SUPPORTS_256_COLORS ? RAINBOW_TOKENS_256 : RAINBOW_TOKENS_16)

function updatebracketcolors!(cs::SyntaxHighlighter.ColorScheme)
    RAINBOWBRACKETS_SETTINGS.active.parenthesis_tokens =
        [cs.argdef, cs.keyword, cs.string]
    RAINBOWBRACKETS_SETTINGS.active.brackets_tokens =
        [cs.call, cs.op]
    RAINBOWBRACKETS_SETTINGS.active.curly_tokens =
        [cs.argdef, cs.number]
    RAINBOWBRACKETS_SETTINGS.active.error_token = cs.error
end

function (rainbow::RainbowBracketsSettings)(ansitokens::Vector{Crayon}, tokens::Vector{Token}, cursorpos::Int, str::AbstractString)
    p, s, b = 0, 0, 0
    for (i, t) in enumerate(tokens)
        k = kind(t)
        if k == K"("
            p += 1
            ansitokens[i] = get_color(rainbow, k, p)
        elseif k == K")"
            ansitokens[i] = get_color(rainbow, k, p)
            p = max(0, p - 1)
        elseif k == K"["
            s += 1
            ansitokens[i] = get_color(rainbow, k, s)
        elseif k == K"]"
            ansitokens[i] = get_color(rainbow, k, s)
            s = max(0, s - 1)
        elseif k == K"{"
            b += 1
            ansitokens[i] = get_color(rainbow, k, b)
        elseif k == K"}"
            ansitokens[i] = get_color(rainbow, k, b)
            b = max(0, b - 1)
        end
    end
    return
end

add_pass!(PASS_HANDLER, "RainbowBrackets", RAINBOWBRACKETS_SETTINGS, false)

end
