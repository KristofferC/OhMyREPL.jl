module SyntaxHighlighter

using Compat
import Compat.String

using Tokenize
using Tokenize.Tokens
import Tokenize.Tokens: Token, kind, exactkind, iskeyword

using ...ANSICodes
import ...ANSICodes: ANSIToken, ANSIValue, ResetToken, merge!

import OhMyREPL: add_pass!, PASS_HANDLER

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

symbol!(cs, token::ANSIToken) = cs.symbol = token
comment!(cs, token::ANSIToken) = cs.comment = token
string!(cs, token::ANSIToken) = cs.string = token
call!(cs, token::ANSIToken) = cs.call = token
op!(cs, token::ANSIToken) = cs.op = token
keyword!(cs, token::ANSIToken) = cs.keyword = token
text!(cs, token::ANSIToken) = cs.text = token
function_def!(cs, token::ANSIToken) = cs.function_def = token
error!(cs, token::ANSIToken) = cs.error = token
argdef!(cs, token::ANSIToken) = cs.argdef = token
macro!(cs, token::ANSIToken) = cs._macro = token
number!(cs, token::ANSIToken) = cs.number = token

function Base.show(io::IO, cs::ColorScheme)
    for n in fieldnames(cs)
        tok = getfield(cs, n)
        print(io, tok, "█ ", ResetToken())
    end
    print(io, ANSIToken(foreground = :default))
end

ColorScheme() = ColorScheme([ANSIToken() for _ in 1:length(fieldnames(ColorScheme))]...)

function _create_juliadefault()
    cs = ColorScheme()
    symbol!(cs, ANSIToken(bold = true))
    comment!(cs, ANSIToken(bold = true))
    string!(cs, ANSIToken(bold = true))
    call!(cs, ANSIToken(bold = true))
    op!(cs, ANSIToken(bold = true))
    keyword!(cs, ANSIToken(bold = true))
    text!(cs, ANSIToken(bold = true))
    macro!(cs, ANSIToken(bold = true))
    function_def!(cs, ANSIToken(bold = true))
    error!(cs, ANSIToken(bold = true))
    argdef!(cs, ANSIToken(bold = true))
    number!(cs, ANSIToken(bold = true))
    return cs
end


# Try to represent the Monokai colorscheme.
function _create_monokai()
    cs = ColorScheme()
    symbol!(cs, ANSIToken(foreground = :magenta))
    comment!(cs, ANSIToken(foreground = :dark_gray))
    string!(cs, ANSIToken(foreground = :yellow))
    call!(cs, ANSIToken(foreground = :cyan))
    op!(cs, ANSIToken(foreground = :light_red))
    keyword!(cs, ANSIToken(foreground = :light_red))
    text!(cs, ANSIToken(foreground = :default))
    macro!(cs, ANSIToken(foreground = :cyan))
    function_def!(cs, ANSIToken(foreground = :green))
    error!(cs, ANSIToken(foreground = :default))
    argdef!(cs, ANSIToken(foreground = :cyan))
    number!(cs, ANSIToken(foreground = :magenta))
    return cs
end

function _create_monokai_256()
    cs = ColorScheme()
    symbol!(cs, ANSIToken(foreground = 141)) # purpleish
    comment!(cs, ANSIToken(foreground = 60)) # greyish
    string!(cs, ANSIToken(foreground = 208)) # beigish
    call!(cs, ANSIToken(foreground = 81)) # cyanish
    op!(cs, ANSIToken(foreground = 197)) # redish
    keyword!(cs, ANSIToken(foreground = 197)) # redish
    text!(cs, ANSIToken(foreground = :default))
    macro!(cs, ANSIToken(foreground = 208)) # cyanish
    function_def!(cs, ANSIToken(foreground = 148))
    error!(cs, ANSIToken(foreground = :default))
    argdef!(cs, ANSIToken(foreground = 81))  # cyanish
    number!(cs, ANSIToken(foreground = 141)) # purpleish
    return cs
end


function _create_boxymonokai_256()
    cs = ColorScheme()
    symbol!(cs, ANSIToken(foreground = 148))
    comment!(cs, ANSIToken(foreground = 95))
    string!(cs, ANSIToken(foreground = 148))
    call!(cs, ANSIToken(foreground = 81))
    op!(cs, ANSIToken(foreground = 158))
    keyword!(cs, ANSIToken(foreground = 141))
    text!(cs, ANSIToken(foreground = :default))
    macro!(cs, ANSIToken(foreground = 81))
    function_def!(cs, ANSIToken(foreground = 81))
    error!(cs, ANSIToken(foreground = :default))
    argdef!(cs, ANSIToken(foreground = 186))
    number!(cs, ANSIToken(foreground = 208))
    return cs
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
    println(io)
end

function SyntaxHighlighterSettings()
    def = _create_juliadefault()
    d = Dict("JuliaDefault" => def)
    SyntaxHighlighterSettings(def, d)
end

SYNTAX_HIGHLIGHTER_SETTINGS = SyntaxHighlighterSettings()

add!(sh::SyntaxHighlighterSettings, name::String, scheme::ColorScheme) = sh.schemes[name] = scheme
add!(name::String, scheme::ColorScheme) = add!(SYNTAX_HIGHLIGHTER_SETTINGS, name, scheme)
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
            ansitokens[i-1] = cscheme.argdef
            ansitokens[i] = cscheme.argdef
        # :foo
        elseif kind(t) == Tokens.IDENTIFIER && exactkind(prev_t) == Tokens.COLON
            ansitokens[i-1] = cscheme.symbol
            ansitokens[i] = cscheme.symbol
        # function
        elseif iskeyword(kind(t))
            if kind(t) == Tokens.TRUE || kind(t) == Tokens.FALSE
                ansitokens[i] = cscheme.symbol
            else
                ansitokens[i] = cscheme.keyword
            end
        # "foo"
        elseif kind(t) == Tokens.STRING || kind(t) == Tokens.TRIPLE_STRING || kind(t) == Tokens.CHAR
            ansitokens[i] = cscheme.string
        # * -
        elseif Tokens.isoperator(kind(t))
            ansitokens[i] = cscheme.op
        # #= foo =#
        elseif kind(t) == Tokens.COMMENT
            ansitokens[i] = cscheme.comment
        # function f(...)
        elseif kind(t) == Tokens.LPAREN && kind(prev_t) == Tokens.IDENTIFIER
            (i > 2 && exactkind(tokens[i-2]) == Tokens.AT_SIGN) || (ansitokens[i-1] = cscheme.call)
             # function f(...)
            if i > 3 && kind(tokens[i-2]) == Tokens.WHITESPACE && exactkind(tokens[i-3]) == Tokens.FUNCTION
                ansitokens[i-1] = cscheme.function_def
            end
        # @fdsafds
        elseif kind(t) == Tokens.IDENTIFIER && exactkind(prev_t) == Tokens.AT_SIGN
            ansitokens[i-1] = cscheme._macro
            ansitokens[i] = cscheme._macro
        # 2] = 32.32
        elseif kind(t) == Tokens.INTEGER || kind(t) == Tokens.FLOAT
            ansitokens[i] = cscheme.number
        elseif kind(t) == Tokens.WHITESPACE
            ansitokens[i] = ANSIToken()
        else
            ansitokens[i] = cscheme.text
        end
        prev_t = t
    end
    return
end

end


