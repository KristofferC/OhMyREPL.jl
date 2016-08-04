module SyntaxHighlighter

using Compat

using Tokenize
using Tokenize.Tokens
import Tokenize.Tokens: Token, kind, exactkind, iskeyword

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
    argdef::ANSIToken
    _macro::ANSIToken
    number::ANSIToken
end

ColorScheme() = ColorScheme([ANSIToken() for _ in 1:length(fieldnames(ColorScheme))]...)

type SyntaxHighlighterSettings
    colorscheme::ColorScheme
end
SyntaxHighlighterSettings() = SyntaxHighlighterSettings(ColorScheme())

SYNTAX_HIGHLIGHTER_SETTINGS = SyntaxHighlighterSettings()

# Try to represent the Monokai colorscheme.
function _create_monokai()
    monokai = ColorScheme()
    monokai.symbol = ANSIToken(foreground = :magenta)
    monokai.comment = ANSIToken(foreground = :dark_gray)
    monokai.string = ANSIToken(foreground = :light_blue)
    monokai.call = ANSIToken(foreground = :cyan)
    monokai.op = ANSIToken(foreground = :light_red)
    monokai.keyword = ANSIToken(foreground = :light_magenta)
    monokai.text = ANSIToken(foreground = :default)
    monokai._macro = ANSIToken(foreground = :yellow)
    monokai.function_def = ANSIToken(foreground = :green)
    monokai.error = ANSIToken(foreground = :default)
    monokai.argdef = ANSIToken(foreground = :light_blue)
    monokai.number = ANSIToken(foreground = :light_blue)
    return monokai
end

# Try to represent the Flatland colorscheme.
function _create_flatland_dark()
    flatland = ColorScheme()
    flatland.symbol = ANSIToken(foreground = :green)
    flatland.comment = ANSIToken(foreground = :dark_gray)
    flatland.string = ANSIToken(foreground = :light_cyan)
    flatland.call = ANSIToken(foreground = :light_cyan)
    flatland.op = ANSIToken(foreground = :yellow)
    flatland.keyword = ANSIToken(foreground = :yellow)
    flatland.text = ANSIToken(foreground = :default)
    flatland._macro = ANSIToken(foreground = :yellow)
    flatland.function_def = ANSIToken(foreground = :green)
    flatland.error = ANSIToken(foreground = :default)
    flatland.argdef = ANSIToken(foreground = :cyan)
    flatland.number = ANSIToken(foreground = :green)
    return flatland
end

MONOKAI = _create_monokai()
FLATLAND = _create_flatland_dark()
SYNTAX_HIGHLIGHTER_SETTINGS.colorscheme = MONOKAI
#SYNTAX_HIGHLIGHTER_SETTINGS.colorscheme = FLATLAND
add_pass!(PASS_HANDLER, "SyntaxHighlighter", SYNTAX_HIGHLIGHTER_SETTINGS, false)

@compat function (highlighter::SyntaxHighlighterSettings)(ansitokens::Vector{ANSIToken}, tokens::Vector{Token}, ::Int)
    cscheme = highlighter.colorscheme
    prev_t = Tokens.Token()
    for (i, t) in enumerate(tokens)
        if exactkind(prev_t) == Tokens.DECLARATION
            update!(ansitokens[i-1], cscheme.argdef)
            update!(ansitokens[i], cscheme.argdef)
        elseif kind(t) == Tokens.IDENTIFIER && exactkind(prev_t) == Tokens.COLON
            update!(ansitokens[i-1], cscheme.symbol)
            update!(ansitokens[i], cscheme.symbol)
        elseif iskeyword(kind(t))
            if kind(t) == Tokens.TRUE || kind(t) == Tokens.FALSE
                update!(ansitokens[i], cscheme.symbol)
            else
                update!(ansitokens[i], cscheme.keyword)
            end
        elseif kind(t) == Tokens.STRING || kind(t) == Tokens.TRIPLE_STRING || kind(t) == Tokens.CHAR
            update!(ansitokens[i], cscheme.string)
        elseif Tokens.isoperator(kind(t))
            update!(ansitokens[i], cscheme.op)
        elseif kind(t) == Tokens.COMMENT
            update!(ansitokens[i], cscheme.comment)
        elseif kind(t) == Tokens.LPAREN && kind(prev_t) == Tokens.IDENTIFIER
            update!(ansitokens[i-1], cscheme.call)
        elseif kind(t) == Tokens.IDENTIFIER && exactkind(prev_t) == Tokens.AT_SIGN
            update!(ansitokens[i-1], cscheme._macro)
            update!(ansitokens[i], cscheme._macro)
        elseif kind(t) == Tokens.INTEGER || kind(t) == Tokens.FLOAT
            update!(ansitokens[i], cscheme.number)
        else
            update!(ansitokens[i], cscheme.text)
        end
        prev_t = t
    end
    return
end

end


