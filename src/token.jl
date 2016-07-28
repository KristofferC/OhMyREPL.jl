module Tokens

import JuliaParser.Lexer: eof

export Token

# https://github.com/llvm-mirror/llvm/blob/master/lib/AsmParser/LLToken.h
@enum(Kind,
  # Markers
  Nothing,
  Eof,
  Error,
  Comment,
  Whitespace,
  Identifier,

  decl,
  _colon,
  prime,
  macro_call,

  dot,
  dot2,
  dot3,

  begin_ops,

    lazy_or, # ||
    lazy_and, # &&
    pipe, #? |
    amper, # &
    conditional, # ?
    perc, # %
    fslash,
    fslash2,
    transpose, # .'
    issubtype,

    begin_comparisons,
      comp_r, # >
      comp_l, # <
      comp_neq, # !=
      comp_neq2, # !==
    end_comparisons,

    begin_pipe,
      pipe_l, # |>
      pipe_r, # <|
    end_pipe,

    begin_assignments,
      ass_equal, # =
      ass_equal2, # ==
      ass_equal3, # ===
      ass_equal_r, # =>
      ass_bitshift_r, # >=
      ass_bitshift_l, # <=
      ass_bitshift_rr, # >>=
      ass_bitshift_rrr, # >>>=
      ass_bitshift_ll, # <<=
      ass_bar, # |=
      ass_ampr, # &=
      ass_perc, # %=
      ass_fslash, # /=
      ass_fslash2, # //=
    end_assignments,

    begin_bitshifts,
      bitshift_ll, # <<
      bitshift_rr, # >>
      bitshift_rrr, # >>>
    end_bitshifts,



  end_ops,


  begin_keywords,

    kw_begin,  kw_while, kw_if, kw_for, kw_try, kw_return,
    kw_break, kw_continue, kw_function, kw_stagedfunction,
    kw_macro, kw_quote, kw_let, kw_local, kw_global, kw_const,
    kw_abstract, kw_typealias, kw_type, kw_bitstype, kw_immutable,
    kw_ccall, kw_do, kw_module, kw_baremodule, kw_using, kw_import,
    kw_export, kw_importall, kw_end, kw_false, kw_true,

  end_keywords,

  comma, # =  ,
  star,  # *
  lsquare,
  rsquare, # [  ]
  lbrace,
  rbrace, # {  }
  lparen,
  rparen,  # (  )
  exclaim, # !
  bar,     # |
  semicolon,

  begin_types,

  t_int, t_float, t_string, t_string_triple, t_symbol, t_char,

  end_types
)

@enum(TokenError,
  no_err,
  EOF_in_multicomment,
  EOF_in_string,
  EOF_in_char,
  unknown
)

TOKEN_ERROR_DESCRIPTION = Dict{TokenError, String}(
EOF_in_multicomment => "unterminated multi-line comment #= ... =#",
EOF_in_string => "unterminated string literal",
EOF_in_char => "unterminated character literal",
unknown => "unknown"
)


iskeyword(k::Kind) = begin_keywords < k < end_keywords
istype(k::Kind) = begin_types < k < end_types

const KEYWORDS = Dict{String, Kind}()

function _add_kws()
    offset = length("kw_")
    for k in instances(Kind)
        if iskeyword(k)
            KEYWORDS[string(k)[offset+1:end]] = k
        end
    end
end
_add_kws()

const KEYWORD_SYMBOLS = Vector{Symbol}()


function _add_kw_symbols()
    resize!(KEYWORD_SYMBOLS, Int32(end_keywords) - Int32(begin_keywords) - 1)
    for (k, v) in KEYWORDS
        KEYWORD_SYMBOLS[Int32(v) - Int32(begin_keywords)] = Symbol(k)
    end
end
_add_kw_symbols()
kwsym(k::Kind) = KEYWORD_SYMBOLS[Int32(k) - Int32(begin_keywords)]


immutable Token
	kind::Kind
  # Offsets into a string or buffer
	startpos::Int64
  endpos::Int64
  token_error::TokenError
end

Token(kind::Kind, startpos::Int64, endpos::Int64) = Token(kind, startpos, endpos, no_err)


kind(t::Token) = t.kind
startpos(t::Token) = t.startpos
endpos(t::Token) = t.endpos

function Base.show(io::IO, t::Token)
	if t.kind == Eof
		print(io, "EOF")
  end
	print(io, startpos(t), "-", endpos(t), "::", t.kind)
end

eof(t::Token) = t.kind == Eof

end # module
