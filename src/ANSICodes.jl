module ANSICodes

const FOREGROUNDS = Dict(
    :default => 39,
    :black => 30,
    :red => 31,
    :green => 32,
    :yellow => 33,
    :blue => 34,
    :magenta => 35,
    :cyan => 36,
    :light_gray => 37,
    :dark_gray => 90,
    :light_red => 91,
    :light_green => 92,
    :light_yellow => 93,
    :light_blue => 94,
    :light_magenta => 95,
    :light_cyan => 96,
    :white => 97
)

const BACKGROUNDS = Dict(
    :default => 49,
    :black => 40,
    :red => 41,
    :green => 42,
    :yellow => 43,
    :blue => 44,
    :magenta => 45,
    :cyan => 46,
    :light_gray => 47,
    :dark_gray => 100,
    :light_red => 101,
    :light_green => 102,
    :light_yellow => 103,
    :light_blue => 104,
    :light_magenta => 105,
    :light_cyan => 106,
    :white => 107
)

# [On, Off]

const BOLD = (1, 22)
const ITALICS = (3, 23)
const UNDERLINE = (4, 24)
const STRIKETHROUGH = (9, 29)

abstract AbstractANSI


immutable ANSIValue
    val::Int
    active::Bool
end
ANSIValue(val::Int) = ANSIValue(val, true)


val(x::ANSIValue) = x.val
activate(x::ANSIValue, v::Bool = true) = ANSIValue(x.val, v)
isactive(x::ANSIValue) = x.active
set(x::ANSIValue, val::Int) = ANSIValue(val, x.active)


# ANSIValue(layer, val) = ANSIValue(ANSIValue(), layer, val)
function ANSIValue(layer::Symbol, val::Symbol)
    if layer == :foreground
        return ANSIValue(FOREGROUNDS[val])
    elseif layer == :background
        return ANSIValue(BACKGROUNDS[val])
    else
        throw(ArgumentError("invalid layer $layer, valid layers are :background and :foregound"))
    end
end

function ANSIValue(style::Symbol, val::Bool)
    if style == :bold
        return ANSIValue(BOLD[!val + 1])
    elseif style == :italics
        return ANSIValue(ITALICS[!val + 1])
    elseif style == :underline
        return ANSIValue(UNDERLINE[!val + 1])
    elseif style == :strikethrough
        return ANSIValue(STRIKETHROUGH[!val + 1])
    else
        throw(ArgumentError("invalid style $style, valid styles are :bold, :italics, strikethrough, :underline"))
    end
end

# make immutable?
type ANSIToken
    foreground::ANSIValue
    background::ANSIValue
    bold::ANSIValue
    italics::ANSIValue
    underline::ANSIValue
    strikethrough::ANSIValue
end

function update!(a::ANSIToken, b::ANSIToken)
    isactive(b.foreground) && (a.foreground = b.foreground)
    isactive(b.background) && (a.background = b.background)
    isactive(b.bold) && (a.bold = b.bold)
    isactive(b.italics) && (a.italics = b.italics)
    isactive(b.underline) && (a.underline = b.underline)
    isactive(b.strikethrough) && (a.strikethrough = b.strikethrough)
end

# Some defaults, everything deactive
function _ANSIToken()
    ANSIToken(ANSIValue(39, false),
              ANSIValue(49, false),
              ANSIValue(1, false),
              ANSIValue(3, false),
              ANSIValue(4, false),
              ANSIValue(9, false))
end


function ANSIToken(;foreground::Symbol = :nothing, background::Symbol = :nothing,
                    bold = :nothing, italics = :nothing, underline = :nothing, strikethrough = :nothing)
    x = _ANSIToken()
    foreground != :nothing && (x.foreground = ANSIValue(FOREGROUNDS[foreground]))
    background != :nothing && (x.background = ANSIValue(BACKGROUNDS[background]))
    bold != :nothing && (x.bold = ANSIValue(BOLD[!bold + 1]))
    italics != :nothing && (x.italics = ANSIValue(ITALICS[!italics + 1]))
    underline != :nothing && (x.underline = ANSIValue(UNDERLINE[!underline + 1]))
    strikethrough != :nothing && (x.strikethrough = ANSIValue(STRIKETHROUGH[!strikethrough + 1]))
    return x
end

function maybe_print(io::IO, isfirst::Bool, token::ANSIValue)
    if isactive(token)
        !isfirst && print(io, ";")
        isfirst = false
        print(io, val(token))
    end
    return isfirst
end

function _print(io::IO, t::ANSIToken, escape = false)
    one_active = false
    isfirst = true
    if isactive(t.foreground) || isactive(t.background) ||
            isactive(t.bold) || isactive(t.italics)  ||
            isactive(t.underline) || isactive(t.strikethrough)
        one_active = true
        escape ? print(io, "\\e[") : print(io, "\e[")
    end
    !one_active && return
    isfirst = maybe_print(io, isfirst, t.foreground)
    isfirst = maybe_print(io, isfirst, t.background)
    isfirst = maybe_print(io, isfirst, t.bold)
    isfirst = maybe_print(io, isfirst, t.italics)
    isfirst = maybe_print(io, isfirst, t.underline)
    isfirst = maybe_print(io, isfirst, t.strikethrough)
    print(io, "m")
    return nothing
end

function Base.print(io::IO, t::ANSIToken)
    _print(io, t, false)
end

function Base.show(io::IO, t::ANSIToken)
    _print(io, t, false)
    _print(io, t, true)
    print(io, "\e[0m", Base.input_color())
end


function test_ANSI(io::IO = STDOUT)
    for col in keys(FOREGROUNDS)
        tok = ANSIToken(foreground = col)
        print(io, tok, "Foreground color: $col, ANSI code: ")
        show(io, tok)
        println(io, "\e[0m")
    end
    for col in keys(BACKGROUNDS)
        tok = ANSIToken(background = col)
        print(io, tok, "Background color: $col, ANSI code: ")
        show(io, tok)
        println(io, "\e[0m")
    end
    tok = ANSIToken(bold = true)
    print(io, tok, "Bold text, ANSI code: ")
    _print(io, tok, true)
    println(io, "\e[0m")

    tok = ANSIToken(underline = true)
    print(io, tok, "Underlined text, ANSI code: ")
    _print(io, tok, true)
    println(io, "\e[0m")

    tok = ANSIToken(italics = true)
    print(io, tok, "Italic text, ANSI code: ")
    _print(io, tok, true)
    println(io, "\e[0m", Base.input_color())


    tok = ANSIToken(strikethrough = true)
    print(io, tok, "Strikethrough text, ANSI code: ")
    _print(io, tok, true)
    println(io, "\e[0m")
end

# test_ANSI()

end # module
