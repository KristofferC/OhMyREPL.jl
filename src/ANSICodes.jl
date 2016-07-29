module ANSIData

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
const bold = 1
const italics = 3
const underline = 4
const strikethrough = 9

type ANSIToken
	foreground::Int
	background::Int
	bold::Bool
	underline::Bool
	strikethrough::Bool
	italics::Bool
end

function Base.string(t::ANSIToken)
	b = IOBuffer()
	write(b, '\\')
	show(b, t)
	return takebuf_string(b)
end

function Base.show(io::IO, t::ANSIToken)
	print(io, "\e[")
	t.bold && print(io, bold, ";")
	t.underline && print(io, underline, ";")
	t.strikethrough && print(io, strikethrough, ";")
	t.italics && print(io, italics, ";")
	print(io, t.foreground, ";", t.background, "m"
end

function ANSIToken(;foreground::Symbol = :default, background::Symbol = :default,
	                bold::Bool = false, underline::Bool = false, strikethrough::Bool = false,
	                italics::Bool = false)
	return ANSIToken(FOREGROUNDS[foreground], BACKGROUNDS[background],
		             bold, underline, strikethrough, italics)
end

const DEFAULT_TOKEN = ANSIToken()



function print_with_ANSI(io::IO, t::ANSIToken, str::String)
	, str, "\e[0m")
end

print_with_ANSI(t::ANSIToken, str::String) = print_with_ANSI(STDOUT, t, str)

function test_ANSI(io::IO = STDOUT)
	for col in keys(FOREGROUNDS)
		print_with_ANSI(io, ANSIToken(foreground = col), "Foreground color: $col")
		println()
	end
	for col in keys(BACKGROUNDS)
		print_with_ANSI(io, ANSIToken(background = col), "Background color: $col")
		println()
	end
	print_with_ANSI(io, ANSIToken(bold = true), "Bold text")
	println()
	print_with_ANSI(io, ANSIToken(underline = true), "Underlined text")
	println()
	print_with_ANSI(io, ANSIToken(strikethrough = true), "Strikethrough text")
	println()
	print_with_ANSI(io, ANSIToken(italics = true), "Italic text")
	println()
end

end # module