module SyntaxHighlighter

using Tokenize
using Tokenize.Tokens
import Tokenize.Tokens: Token, kind, startpos, endpos

using ...ANSICodes
import ...ANSICodes: ANSIToken, ANSIValue, update!

import ..Passes: ANSITokenSettings

type ColorScheme
	symbol::ANSIToken
	comment::ANSIToken
	string::ANSIToken
	call::ANSIToken
	op::ANSIToken
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

function _create_monokai()
	monokai = ColorScheme()
	monokai.symbol = ANSIToken(:foreground, :magenta)
	monokai.comment = ANSIToken(:foreground, :dark_gray)
	monokai.string = ANSIToken(:foreground, :light_yellow)
	monokai.call = ANSIToken(:foreground, :light_blue)
	monokai.op = ANSIToken(:foreground, :red)
	monokai.text = ANSIToken(:foreground, :default)
	monokai.function_def = ANSIToken(:foreground, :light_blue)
	monokai.error, :error, :default)
end

#MONOKAI = _create_monokai()
#SYNTAX_HIGHLIGHTER_SETTINGS.colorscheme = MONOKAI

# add_pass!("SyntaxHighlighter", SYNTAX_HIGHLIGHTER_SETTINGS, false)


function colorize_code(tokens::Vector{Token}, scheme::SyntaxHighlighterSettings = COLORSCHEME)
	b = IOBuffer()
	for t in tokens
		str = untokenize(t)
		#print(str)
		if kind(t) == Tokens.Eof
			break
		elseif kind(t) == Tokens.t_symbol
			_print_with_color(b, scheme.symbol, str)
		elseif iskeyword(kind(t))
			if kind(t) == Tokens.kw_true || kind(t) == Tokens.kw_false
				_print_with_color(b, scheme.symbol, str)
			else
				_print_with_color(b, scheme.op, str)
			end
		elseif kind(t) == Tokens.t_string || kind(t) == Tokens.t_string_triple
			_print_with_color(b, scheme.string, str)
		elseif Tokens.isoperator(kind(t))
			_print_with_color(b, scheme.op, str)
		elseif kind(t) == Tokens.Comment
			_print_with_color(b, scheme.comment, str)
		else
			_print_with_color(b, scheme.text, str)
		end
		prev_t = t
		if kind(t) != Tokens.Whitespace
			prev_nonws_t = t
		end
	end
	return takebuf_string(b)
end

function uncolorify(s::String)

	s = IOBuffer(s::String)

end

end