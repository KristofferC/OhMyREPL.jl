module SyntaxHighlighter

using Compat
import Compat.String

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

function Base.show(io::IO, cs::ColorScheme)
    for n in fieldnames(cs)
        tok = getfield(cs, n)
        print(io, tok, "█ ")
    end
    print(io, ANSIToken(foreground = :default))
end

ColorScheme() = ColorScheme([ANSIToken() for _ in 1:length(fieldnames(ColorScheme))]...)

function _create_juliadefault()
    def = ColorScheme()
    def.symbol = ANSIToken(bold = true)
    def.comment = ANSIToken(bold = true)
    def.string = ANSIToken(bold = true)
    def.call = ANSIToken(bold = true)
    def.op = ANSIToken(bold = true)
    def.keyword = ANSIToken(bold = true)
    def.text = ANSIToken(bold = true)
    def._macro = ANSIToken(bold = true)
    def.function_def = ANSIToken(bold = true)
    def.error = ANSIToken(bold = true)
    def.argdef = ANSIToken(bold = true)
    def.number = ANSIToken(bold = true)
    return def
end


# Try to represent the Monokai colorscheme.
function _create_monokai()
    monokai = ColorScheme()
    monokai.symbol = ANSIToken(foreground = :magenta)
    monokai.comment = ANSIToken(foreground = :dark_gray)
    monokai.string = ANSIToken(foreground = :yellow)
    monokai.call = ANSIToken(foreground = :cyan)
    monokai.op = ANSIToken(foreground = :light_red)
    monokai.keyword = ANSIToken(foreground = :light_red)
    monokai.text = ANSIToken(foreground = :default)
    monokai._macro = ANSIToken(foreground = :cyan)
    monokai.function_def = ANSIToken(foreground = :green)
    monokai.error = ANSIToken(foreground = :default)
    monokai.argdef = ANSIToken(foreground = :cyan)
    monokai.number = ANSIToken(foreground = :magenta)
    return monokai
end

function _create_monokai_256()
    monokai = ColorScheme()
    monokai.symbol = ANSIToken(foreground = 141) # purpleish
    monokai.comment = ANSIToken(foreground = 60) # greyish
    monokai.string = ANSIToken(foreground = 208) # beigish
    monokai.call = ANSIToken(foreground = 81) # cyanish
    monokai.op = ANSIToken(foreground = 197) # redish
    monokai.keyword = ANSIToken(foreground = 197) # redish
    monokai.text = ANSIToken(foreground = :default)
    monokai._macro = ANSIToken(foreground = 208) # cyanish
    monokai.function_def = ANSIToken(foreground = 148)
    monokai.error = ANSIToken(foreground = :default)
    monokai.argdef = ANSIToken(foreground = 81)  # cyanish
    monokai.number = ANSIToken(foreground = 141) # purpleish
    return monokai
end


function _create_boxymonokai_256()
    boxymonokai = ColorScheme()
    boxymonokai.symbol = ANSIToken(foreground = 148)
    boxymonokai.comment = ANSIToken(foreground = 95)
    boxymonokai.string = ANSIToken(foreground = 148)
    boxymonokai.call = ANSIToken(foreground = 81)
    boxymonokai.op = ANSIToken(foreground = 158)
    boxymonokai.keyword = ANSIToken(foreground = 141)
    boxymonokai.text = ANSIToken(foreground = :default)
    boxymonokai._macro = ANSIToken(foreground = 81)
    boxymonokai.function_def = ANSIToken(foreground = 81)
    boxymonokai.error = ANSIToken(foreground = :default)
    boxymonokai.argdef = ANSIToken(foreground = 186)
    boxymonokai.number = ANSIToken(foreground = 208)
    return boxymonokai
end

type SyntaxHighlighterSettings
    active::ColorScheme
    schemes::Dict{String, ColorScheme}
end


function Base.show(io::IO, sh::SyntaxHighlighterSettings)
    first = true
    l = maximum(x->length(x), keys(sh.schemes))
    for (k, v) in sh.schemes
        if !first
            print(io, "\n\n")
        end
        first = false
        print(io, rpad(k, l+1, " "))
        print(io, v)
    end
end

function SyntaxHighlighterSettings()
    def = _create_juliadefault()
    d = Dict("JuliaDefault" => def)
    SyntaxHighlighterSettings(def, d)
end

SYNTAX_HIGHLIGHTER_SETTINGS = SyntaxHighlighterSettings()

add!(sh::SyntaxHighlighterSettings, name::String, scheme::ColorScheme) = sh.schemes[name] = scheme
activate!(sh::SyntaxHighlighterSettings, name::String) = sh.active = sh.schemes[name]

add!(SYNTAX_HIGHLIGHTER_SETTINGS, "Monokai256", _create_monokai_256())
add!(SYNTAX_HIGHLIGHTER_SETTINGS, "Monokai16", _create_monokai())
add!(SYNTAX_HIGHLIGHTER_SETTINGS, "BoxyMonokai256", _create_boxymonokai_256())
# Added by default
# add!(SYNTAX_HIGHLIGHTER_SETTINGS, "JuliaDefault", _create_juliadefault())

if !is_windows()
    activate!(SYNTAX_HIGHLIGHTER_SETTINGS, "Monokai256")
else
    activate!(SYNTAX_HIGHLIGHTER_SETTINGS, "Monokai16")
end
add_pass!(PASS_HANDLER, "SyntaxHighlighter", SYNTAX_HIGHLIGHTER_SETTINGS, false)


@compat function (highlighter::SyntaxHighlighterSettings)(ansitokens::Vector{ANSIToken}, tokens::Vector{Token}, ::Int)
    cscheme = highlighter.active
    prev_t = Tokens.Token()
    for (i, t) in enumerate(tokens)
        # a::x
        if exactkind(prev_t) == Tokens.DECLARATION
            update!(ansitokens[i-1], cscheme.argdef)
            update!(ansitokens[i], cscheme.argdef)
        # :foo
        elseif kind(t) == Tokens.IDENTIFIER && exactkind(prev_t) == Tokens.COLON
            update!(ansitokens[i-1], cscheme.symbol)
            update!(ansitokens[i], cscheme.symbol)
        # function
        elseif iskeyword(kind(t))
            if kind(t) == Tokens.TRUE || kind(t) == Tokens.FALSE
                update!(ansitokens[i], cscheme.symbol)
            else
                update!(ansitokens[i], cscheme.keyword)
            end
        # "foo"
        elseif kind(t) == Tokens.STRING || kind(t) == Tokens.TRIPLE_STRING || kind(t) == Tokens.CHAR
            update!(ansitokens[i], cscheme.string)
        # * -
        elseif Tokens.isoperator(kind(t))
            update!(ansitokens[i], cscheme.op)
        # #= foo =#
        elseif kind(t) == Tokens.COMMENT
            update!(ansitokens[i], cscheme.comment)
        # function f(...)
        elseif kind(t) == Tokens.LPAREN && kind(prev_t) == Tokens.IDENTIFIER
            update!(ansitokens[i-1], cscheme.call)
             # function f(...)
            if i > 3 && kind(tokens[i-2]) == Tokens.WHITESPACE && exactkind(tokens[i-3]) == Tokens.FUNCTION
                update!(ansitokens[i-1], cscheme.function_def)
            end
        # @fdsafds
        elseif kind(t) == Tokens.IDENTIFIER && exactkind(prev_t) == Tokens.AT_SIGN
            update!(ansitokens[i-1], cscheme._macro)
            update!(ansitokens[i], cscheme._macro)
        # 2, 32.32
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


