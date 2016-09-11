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

const BG_256 = 48
const FG_256 = 38
# [On, Off]

const BOLD = (1, 22)
const ITALICS = (3, 23)
const UNDERLINE = (4, 24)
const STRIKETHROUGH = (9, 29)

immutable ResetToken
end

Base.show(io::IO, ::ResetToken) = print(io, "\e[0m\\e[0m")
Base.print(io::IO, ::ResetToken) = print(io, "\e[0m")

immutable ANSIValue
    val::Int
    active::Bool
end

val(x::ANSIValue) = x.val
activate(x::ANSIValue, v::Bool = true) = ANSIValue(x.val, v)
isactive(x::ANSIValue) = x.active
set(x::ANSIValue, val::Int) = ANSIValue(val, x.active)

function ANSIValue(layer::Symbol, val::Symbol)
    if layer == :foreground
        return ANSIValue(FOREGROUNDS[val])
    elseif layer == :background
        return ANSIValue(BACKGROUNDS[val])
    else
        throw(ArgumentError("invalid layer $layer, valid layers are :background and :foregound"))
    end
end

function ANSIValue(val::Int)
    !(0 <= val <= 256) && throw(ArgumentError("Only colors between 0 and 256 supported"))
    return ANSIValue(val, true)
end

DeactivatedANSI() = ANSIValue(-1, false)


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

immutable ANSIToken
    foreground256colors::Bool
    background256colors::Bool
    foreground::ANSIValue
    background::ANSIValue
    bold::ANSIValue
    italics::ANSIValue
    underline::ANSIValue
    strikethrough::ANSIValue
end

function merge(a::ANSIToken, b::ANSIToken)
    fg = isactive(b.foreground) ? b.foreground : a.foreground
    isfg256 = isactive(b.foreground) ? b.foreground256colors : a.foreground256colors
    bg = isactive(b.background) ? b.background : a.background
    isbg256 = isactive(b.background) ? b.background256colors : a.background256colors
    bold = isactive(b.bold) ? b.bold : a.bold
    italics = isactive(b.italics) ? b.italics : a.italics
    underline = isactive(b.underline) ? b.underline : a.underline
    strikethrough = isactive(b.strikethrough) ? b.strikethrough : a.strikethrough
    return ANSIToken(isfg256, isbg256, fg, bg, bold, italics, underline, strikethrough)
end

function merge(toks::ANSIToken...)
    if length(toks) == 0
        return ANSIToken()
    end
    tok = toks[1]
    for i in 2:length(toks)
        tok = merge(tok, toks[i])
    end
    return tok
end

function ANSIToken(;foreground::Union{Int, Symbol} = :nothing, background::Union{Int, Symbol} = :nothing,
                    bold = :nothing, italics = :nothing, underline = :nothing, strikethrough = :nothing)
    if foreground != :nothing
        if isa(foreground, Symbol)
            tok_fg256colors = false
            tok_fg = ANSIValue(FOREGROUNDS[foreground])
        else
            tok_fg = ANSIValue(foreground)
            tok_fg256colors = true
        end
    else
        tok_fg256colors = false
        tok_fg = DeactivatedANSI()
    end

    if background != :nothing
        if isa(background, Symbol)
            tok_bg = ANSIValue(BACKGROUNDS[background])
            tok_bg256colors = false
        else
            tok_bg = ANSIValue(background)
            tok_bg256colors = true
        end
    else
        tok_bg256colors = false
        tok_bg = DeactivatedANSI()
    end
    tok_bold = (bold != :nothing) ? ANSIValue(BOLD[!bold + 1]) : DeactivatedANSI()
    tok_italics = (italics != :nothing) ? ANSIValue(ITALICS[!italics + 1]) : DeactivatedANSI()
    tok_underline =  (underline != :nothing) ? ANSIValue(UNDERLINE[!underline + 1]) : DeactivatedANSI()
    tok_strikethrough = (strikethrough != :nothing) ? ANSIValue(STRIKETHROUGH[!strikethrough + 1]) : DeactivatedANSI()
    return ANSIToken(tok_fg256colors, tok_bg256colors, tok_fg, tok_bg, tok_bold, tok_italics, tok_underline, tok_strikethrough)
end

function merge!(t1::Vector{ANSIToken}, t2::Vector{ANSIToken})
    @assert length(t1) == length(t2)
    for i in eachindex(t1)
        t1[i] = merge(t1[i], t2[i])
    end
    return t1
end

# for 256 colors: <Esc>[38;5;ColorNumberm”
function maybe_print(io::IO, isfirst::Bool, token::ANSIValue, is256colors::Bool, isforeground::Bool)
    if isactive(token)
        !isfirst && print(io, ";")
        is256colors && isforeground && print(io, "38;5;")
        is256colors && !isforeground && print(io, "48;5;")
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

    isfirst = maybe_print(io, isfirst, t.foreground, t.foreground256colors, true)
    isfirst = maybe_print(io, isfirst, t.background, t.background256colors, false)
    isfirst = maybe_print(io, isfirst, t.bold, false, false)
    isfirst = maybe_print(io, isfirst, t.italics, false, false)
    isfirst = maybe_print(io, isfirst, t.underline, false, false)
    isfirst = maybe_print(io, isfirst, t.strikethrough, false, false)
    print(io, "m")
    return nothing
end

function Base.print(io::IO, t::ANSIToken)
    _print(io, t, false)
end

function Base.show(io::IO, t::ANSIToken)
    print(io, ResetToken())
    _print(io, t, false)
    _print(io, t, true)
    print(io, ResetToken(), Base.input_color())
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

function test_ANSI_256(io::IO = STDOUT)
    function pad(io, c)
         if c < 10
            print(io, "    ")
        elseif c < 100
            print(io, "   ")
        else
            print(io, "  ")
        end
    end

    for c in 0:256
        if c > 0 && c % 10 == 0
            println(io)
        end
        print(io, ANSIToken(foreground = c), c)
        print(io, ResetToken())
        pad(io, c)
    end

    println(io)
    for c in 0:256
        if c > 0 && c % 10 == 0
            println(io)
        end
        print(io, ANSIToken(background = c), c)
        print(io, ResetToken())
        pad(io, c)
    end
end

# test_ANSI()

end # module
