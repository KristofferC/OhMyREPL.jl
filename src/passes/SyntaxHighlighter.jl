module SyntaxHighlighter

using Tokenize
using Tokenize.Tokens
import Tokenize.Tokens: Token, kind, exactkind, iskeyword, untokenize

using Crayons

import OhMyREPL: add_pass!, PASS_HANDLER, SUPPORTS_256_COLORS 

mutable struct ColorScheme
    symbol::Crayon
    comment::Crayon
    string::Crayon
    call::Crayon
    op::Crayon
    keyword::Crayon
    text::Crayon
    function_def::Crayon
    error::Crayon
    argdef::Crayon
    _macro::Crayon
    number::Crayon
end

symbol!(cs, crayon::Crayon) = cs.symbol = crayon
comment!(cs, crayon::Crayon) = cs.comment = crayon
string!(cs, crayon::Crayon) = cs.string = crayon
call!(cs, crayon::Crayon) = cs.call = crayon
op!(cs, crayon::Crayon) = cs.op = crayon
keyword!(cs, crayon::Crayon) = cs.keyword = crayon
text!(cs, crayon::Crayon) = cs.text = crayon
function_def!(cs, crayon::Crayon) = cs.function_def = crayon
error!(cs, crayon::Crayon) = cs.error = crayon
argdef!(cs, crayon::Crayon) = cs.argdef = crayon
macro!(cs, crayon::Crayon) = cs._macro = crayon
number!(cs, crayon::Crayon) = cs.number = crayon

function Base.show(io::IO, cs::ColorScheme)
    for n in fieldnames(ColorScheme)
        crayon = getfield(cs, n)
        print(io, crayon, "█ ", inv(crayon))
    end
    print(io, Crayon(foreground = :default))
end

ColorScheme() = ColorScheme([Crayon() for _ in 1:length(fieldnames(ColorScheme))]...)

include("colorschemes.jl")

mutable struct SyntaxHighlighterSettings
    active::ColorScheme
    schemes::Dict{String, ColorScheme}
end

function Base.show(io::IO, sh::SyntaxHighlighterSettings)
    first = true
    l = maximum(x->length(x), keys(sh.schemes))
    for (k, v) in sort(collect(sh.schemes), by = x -> x[1])
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

add!(SYNTAX_HIGHLIGHTER_SETTINGS, "Monokai24bit", _create_monokai_24())
add!(SYNTAX_HIGHLIGHTER_SETTINGS, "Monokai256", _create_monokai_256())
add!(SYNTAX_HIGHLIGHTER_SETTINGS, "Monokai16", _create_monokai())
add!(SYNTAX_HIGHLIGHTER_SETTINGS, "BoxyMonokai256", _create_boxymonokai_256())
add!(SYNTAX_HIGHLIGHTER_SETTINGS, "TomorrowNightBright", _create_tomorrow_night_bright())
add!(SYNTAX_HIGHLIGHTER_SETTINGS, "TomorrowNightBright24bit", _create_tomorrow_night_bright_24())
add!(SYNTAX_HIGHLIGHTER_SETTINGS, "Tomorrow24bit", _create_tomorrow_24())
add!(SYNTAX_HIGHLIGHTER_SETTINGS, "Tomorrow", _create_tomorrow_256())
add!(SYNTAX_HIGHLIGHTER_SETTINGS, "Distinguished", _create_distinguished())
add!(SYNTAX_HIGHLIGHTER_SETTINGS, "OneDark", _create_onedark())
add!(SYNTAX_HIGHLIGHTER_SETTINGS, "OneLight", _create_onelight())
add!(SYNTAX_HIGHLIGHTER_SETTINGS, "Base16MaterialDarker", _create_base16_material_darker())
add!(SYNTAX_HIGHLIGHTER_SETTINGS, "GruvboxDark", _create_gruvbox_dark())
add!(SYNTAX_HIGHLIGHTER_SETTINGS, "GitHubLight", _create_github_light())
add!(SYNTAX_HIGHLIGHTER_SETTINGS, "GitHubDark", _create_github_dark())
add!(SYNTAX_HIGHLIGHTER_SETTINGS, "GitHubDarkDimmed", _create_github_dark_dimmed())
add!(SYNTAX_HIGHLIGHTER_SETTINGS, "Dracula", _create_dracula())
# Added by default
# add!(SYNTAX_HIGHLIGHTER_SETTINGS, "JuliaDefault", _create_juliadefault())

if SUPPORTS_256_COLORS
    activate!(SYNTAX_HIGHLIGHTER_SETTINGS, "Monokai256")
else
    activate!(SYNTAX_HIGHLIGHTER_SETTINGS, "Monokai16")
end
add_pass!(PASS_HANDLER, "SyntaxHighlighter", SYNTAX_HIGHLIGHTER_SETTINGS, false)


function (highlighter::SyntaxHighlighterSettings)(crayons::Vector{Crayon}, tokens::Vector{Token}, ::Int)
    cscheme = highlighter.active
    prev_t = Tokens.Token()
    pprev_t = Tokens.Token()
    for (i, t) in enumerate(tokens)
        # a::x
        if exactkind(prev_t) == Tokens.DECLARATION
            crayons[i-1] = cscheme.argdef
            crayons[i] = cscheme.argdef
        # :foo
        elseif kind(t) == Tokens.IDENTIFIER && exactkind(prev_t) == Tokens.COLON &&
               kind(pprev_t) ∉ (Tokens.INTEGER, Tokens.FLOAT, Tokens.IDENTIFIER, Tokens.RPAREN)
            crayons[i-1] = cscheme.symbol
            crayons[i] = cscheme.symbol
        # function
        elseif iskeyword(kind(t))
            if kind(t) == Tokens.TRUE || kind(t) == Tokens.FALSE
                crayons[i] = cscheme.symbol
            else
                crayons[i] = cscheme.keyword
            end
        # "foo"
        elseif kind(t) == Tokens.STRING || kind(t) == Tokens.TRIPLE_STRING || kind(t) == Tokens.CHAR || kind(t) == Tokens.CMD || kind(t) == Tokens.TRIPLE_CMD
            crayons[i] = cscheme.string
        # * -
        elseif Tokens.isoperator(kind(t)) || exactkind(t) == Tokens.TRUE || exactkind(t) == Tokens.FALSE
            crayons[i] = cscheme.op
        # #= foo =#
        elseif kind(t) == Tokens.COMMENT
            crayons[i] = cscheme.comment
        # f(...)
        elseif kind(t) == Tokens.LPAREN
            if kind(prev_t) == Tokens.IDENTIFIER && !(i > 2 && exactkind(tokens[i-2]) == Tokens.AT_SIGN)
                crayons[i-1] = cscheme.call
            elseif exactkind(prev_t) == Tokens.DOT && kind(pprev_t) == Tokens.IDENTIFIER
                crayons[i-1] = cscheme.call
                crayons[i-2] = cscheme.call
            end
             # function f(...)
            if i > 3 && kind(tokens[i-2]) == Tokens.WHITESPACE && exactkind(tokens[i-3]) == Tokens.FUNCTION
                crayons[i-1] = cscheme.function_def
            end
        # @fdsafds
        elseif kind(t) == Tokens.IDENTIFIER && exactkind(prev_t) == Tokens.AT_SIGN
            crayons[i-1] = cscheme._macro
            crayons[i] = cscheme._macro
        # 2] = 32.32
        elseif kind(t) ∈ (Tokens.INTEGER, Tokens.BIN_INT, Tokens.OCT_INT, Tokens.HEX_INT, Tokens.FLOAT) || (kind(t) == Tokens.IDENTIFIER && untokenize(t) == "NaN")
            crayons[i] = cscheme.number
        elseif kind(t) == Tokens.WHITESPACE
            crayons[i] = Crayon()
        else
            crayons[i] = cscheme.text
        end
        pprev_t = prev_t
        prev_t = t
    end
    return
end

end
