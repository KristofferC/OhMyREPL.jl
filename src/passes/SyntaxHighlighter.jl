module SyntaxHighlighter

import ..Passes: ANSITokenSettings

type SyntaxHighlighterSettings
	symbol::ANSIToken
	comment::ANSIToken
	string::ANSIToken
	call::ANSIToken
	op::ANSIToken
	text::ANSIToken
	function_def::ANSIToken
    error::ANSIToken
end

SyntaxHighlighterSettings() = SyntaxHighlighterSettings(:magenta, :dark_gray, :light_yellow, :light_blue, :red, :default, :green)


const JL_HIGHLIGHTER = SyntaxHighlighterSettings()

add_pass!("SyntaxHighlighter", JL_HIGHLIGHTER, false)


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