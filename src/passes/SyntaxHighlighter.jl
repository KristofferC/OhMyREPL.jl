module SyntaxHighlighter

using Compat

using Tokenize
using Tokenize.Tokens
import Tokenize.Tokens: Token, kind, iskeyword

using ...ANSICodes
import ...ANSICodes: ANSIToken, ANSIValue, update!

import PimpMyREPL: add_pass!, PASS_HANDLER

type ColorScheme
    symbol::ANSIToken
    comment::ANSIToken
    string::ANSIToken
    call::ANSIToken
    op::ANSIToken
    keyword::ANSIToken
    text::ANSIToken
    function_def::ANSIToken
    error::ANSIToken
end

ColorScheme() = ColorScheme([ANSIToken() for i in 1:length(fieldnames(ColorScheme))]...)

type SyntaxHighlighterSettings
    colorscheme::ColorScheme
end
SyntaxHighlighterSettings() = SyntaxHighlighterSettings(ColorScheme())

SYNTAX_HIGHLIGHTER_SETTINGS = SyntaxHighlighterSettings()

# Try to represent the Monokai colorscheme.
function _create_monokai()
    monokai = ColorScheme()
    monokai.symbol = ANSIToken(foreground = :light_blue)
    monokai.comment = ANSIToken(foreground = :dark_gray)
    monokai.string = ANSIToken(foreground = :light_yellow)
    monokai.call = ANSIToken(foreground = :blue)
    monokai.op = ANSIToken(foreground = :light_red)
    monokai.keyword = ANSIToken(foreground = :red)
    monokai.text = ANSIToken(foreground = :default)
    monokai.function_def = ANSIToken(foreground = :green)
    monokai.error = ANSIToken(foreground = :default)
    return monokai
end

MONOKAI = _create_monokai()
SYNTAX_HIGHLIGHTER_SETTINGS.colorscheme = MONOKAI

add_pass!(PASS_HANDLER, "SyntaxHighlighter", SYNTAX_HIGHLIGHTER_SETTINGS, false)


@compat function (highlighter::SyntaxHighlighterSettings)(ansitokens::Vector{ANSIToken}, tokens::Vector{Token}, cursorpos::Int)
    cscheme = highlighter.colorscheme
    for (i, t) in enumerate(tokens)
        if kind(t) == Tokens.t_symbol
            update!(ansitokens[i], cscheme.symbol)
        elseif iskeyword(kind(t))
            if kind(t) == Tokens.kw_true || kind(t) == Tokens.kw_false
                update!(ansitokens[i], cscheme.symbol)
            else
                update!(ansitokens[i], cscheme.keyword)
            end
        elseif kind(t) == Tokens.t_string || kind(t) == Tokens.t_string_triple
            update!(ansitokens[i], cscheme.string)
        elseif Tokens.isoperator(kind(t))
            update!(ansitokens[i], cscheme.op)
        elseif kind(t) == Tokens.Comment
            update!(ansitokens[i], cscheme.comment)
        else
            update!(ansitokens[i], cscheme.text)
        end
    end
    return
end

end
