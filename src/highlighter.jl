
const COLOR_TABLE = Dict(
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
:white => 97)

function _print_with_color(io::IO, col::Symbol, str::String)
	print(io, "\e[1;", COLOR_TABLE[col], "m", str)
	#print(io, Base.text_colors[col], str)
end
_print_with_color(col::Symbol, str::String) = _print_with_color(STDOUT, col, str)




for (k, v) in COLOR_TABLE
	_print_with_color(k, "HELLO I AM $k \n")
end

type JuliaColorScheme
	symbol::Symbol
	comment::Symbol
	string::Symbol
	call::Symbol
	op::Symbol
	text::Symbol
	function_def::Symbol
end

JuliaColorScheme() = JuliaColorScheme(:magenta, :dark_gray, :light_yellow, :light_blue, :red, :default, :green)

const DEFAULT_COLORSCHEME = JuliaColorScheme()

using LLVMIRTools
using LLVMIRTools.Tokens

import LLVMIRTools.Tokens: Kind, Token, kind, iskeyword
import LLVMIRTools.Lexers: extract_tokenstring, next_token


function colorize_code(a::String, scheme::JuliaColorScheme = DEFAULT_COLORSCHEME)
	lexer = LLVMIRTools.Lexers.Lexer(a)
	b = IOBuffer()
	prev_t = Token(Tokens.Error, 0, 0)
	prev_nonws_t = Token(Tokens.Error, 0, 0)
	while true
		t = next_token(lexer)
		str = extract_tokenstring(lexer, t)
		print(str)
		if kind(t) == Tokens.Eof
			break
		elseif kind(t) == Tokens.t_symbol
			_print_with_color(b, scheme.symbol, str)
		elseif iskeyword(kind(t))
			_print_with_color(b, scheme.op, str)
		else
			print(b, str)
		end
		prev_t = t
		if kind(t) != Tokens.Whitespace
			prev_nonws_t = t
		end
	end
	return takebuf_string(b)
end


print(colorize_code("hej        :hoo, :bro, #go
	doo function begin end"))