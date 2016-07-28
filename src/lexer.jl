module Lexers

import Base: push!

import JuliaParser.Lexer: peekchar, readchar, EOF_CHAR, eof, is_identifier_char, is_identifier_start_char

using Logging

using ..Tokens
import ..Tokens: Token, Kind, TokenError

export Lexer, next_token

@Logging.configure(level=WARNING)

ishead(c::Char) = ('A' <= c <= 'z') || c == '$' || c == '-' || c == '_' || c == '.'
istail(c::Char) = ishead(c) || isdigit(c)
ishex(c::Char) =  isdigit(c) || ('a' <= c <= 'f')
iswhitespace(c::Char) = Base.UTF8proc.isspace(c)

type Lexer{IO_t <: Union{IO, String}}
    io::IO_t
    tokens::Vector{Token}
    token_startpos::Int64 # The start position in the IO of the current token being lexed
    prevpos::Int64
    current_pos::Int64
end

function reset!(l::Lexer)
    seekstart(l)
    l.token_startpos = 0
    l.prevpos = 0
    l.current_pos = 1
end

Lexer(io::Union{IO, String}) = Lexer(io, Token[], 0, 0, 1)


startpos(l::Lexer) = l.token_startpos
startpos!(l::Lexer, i::Int64) = l.token_startpos = i
tokens(l::Lexer) = l.tokens
io(l::Lexer) = l.io
prevpos(l::Lexer) = l.prevpos
prevpos!(l::Lexer, i::Int64) = l.prevpos = i
seekstart{I <: IO}(l::Lexer{I}) = seekstart(l.io)
seekstart(l::Lexer{String}) = seek(l, 1)

seek2startpos!(l::Lexer) = seek(l, startpos(l))

push!(l::Lexer, t::Token) = push!(l.tokens, t)
peekchar{I <: IO}(l::Lexer{I}) = peekchar(l.io)
peekchar(l::Lexer{String}) = eof(l) ? EOF_CHAR : l.io[position(l)]

position(l::Lexer{String}) = l.current_pos
position{I <: IO}(l::Lexer{I}) = Base.position(l.io)
eof{I <: IO}(l::Lexer{I}) = eof(l.io)
eof(l::Lexer{String}) = position(l) > sizeof(l.io)
Base.seek{I <: IO}(l::Lexer{I}, pos) = seek(l.io, pos)
Base.seek(l::Lexer{String}, pos) = l.current_pos = pos
ignore!(l::Lexer) = l.token_startpos = position(l)

function prevchar(l::Lexer)
    backup!(l)
    return readchar(l)
end

function readchar{I <: IO}(l::Lexer{I})
    prevpos!(l, position(l))
    readchar(l.io)
end

function readchar(l::Lexer{String})
    prevpos!(l, position(l))
    eof(l) && return EOF_CHAR
    c = l.io[position(l)]
    l.current_pos = nextind(l.io, position(l))
    return c
end


function backup!(l::Lexer)
    @assert prevpos(l) != -1
    seek(l, prevpos(l))
    prevpos!(l, -1)
end

function accept(l::Lexer, f::Union{Function, Char, Vector{Char}, String})::Bool
    c = peekchar(l)
    if isa(f, Function)
        ok = f(c)
    elseif isa(f, Char)
        ok = c == f
    else
        ok = c in f
    end
    ok && readchar(l)
    return ok
end

function accept_batch(l::Lexer, f)
    ok = false
    while accept(l, f)
        ok = true
    end
    return ok
end


function Base.show(io::IO, l::Lexer)
    n_errors = sum(Tokens.kind(tok) == Tokens.Error for tok in tokens(l))
    print(io, "Token buffer:")
    print(io, extract_tokenstring(l))
    print(io, "\n# tokens read: ", length(tokens(l)), " n errors: ", n_errors)
    print(io, "\n", tokens(l))
end



function emit(l::Lexer, kind::Kind; skipfirst::Int = 0, skiplast::Int = 0)
    tok = Token(kind, startpos(l) + skipfirst, position(l) - skiplast - 1)
    @debug "emitted token: $tok: $(extract_tokenstring(l, tok))"
    ignore!(l)
    return tok
end

function emit_error(l::Lexer, err::TokenError=Tokens.unknown)
    tok = Token(Tokens.Error, startpos(l), position(l) -1 , err)
    ignore!(l)
    @debug "emitted error token: $tok: : $(extract_tokenstring(l, tok))"
    error()
    return tok
end

function extract_tokenstring{T}(l::Lexer{T}, t::Token)
    isstr = T == String
    p = position(l)
    if Tokens.kind(t) == Tokens.Eof
        return "EOF"
    end
    cs = Char[]
    sizehint!(cs, Tokens.endpos(t) - Tokens.startpos(t) + 1)
    seek(l, Tokens.startpos(t) + isstr)
    while position(l) <= Tokens.endpos(t)
        push!(cs, readchar(l))
    end
    str = normalize_string(String(cs))
    seek(l, p)
    return str
end

function extract_tokenstring{T}(l::Lexer{T})
    isstr = T == String
    cs = Char[]
    sizehint!(cs, position(l) - startpos(l))
    curr_pos = position(l)
    seek2startpos!(l)
    if isstr
        seek(l, position(l) + 1)
    end
    x = 0
    @debug "position: $(position(l)), curr_pos: $curr_pos, isstr: $isstr, "
    while position(l) < curr_pos
        push!(cs, readchar(l))
    end
    str = String(cs)
    return str
end


# We just consumed a " or a """
function read_string(l::Lexer, kind::Tokens.Kind)
    while true
        c = readchar(l)
        if c == '\\' && eof(readchar(l))
            return false
        end
        if c == '"'
            if kind == Tokens.t_string
                return true
            else
                if accept(l, "\"") && accept(l, "\"")
                    return true
                end
            end
        elseif eof(c)
            return false
        end
    end
end

function lex(l::Lexer)
    reset!(l)
    while true
        t =  next_token(l)
        push!(l, t)
        if eof(l)
            break
        end
    end
    return l
end

function next_token(l::Lexer)::Token

    c = readchar(l)

    if eof(c); return emit(l, Tokens.Eof)
    elseif iswhitespace(c); return lex_whitespace(l)
    elseif c == '#'; return lex_comment(l)
    elseif c == '='; return lex_equal(l)
    elseif c == '!'; return lex_exclaim(l)
    elseif c == '['; return emit(l, Tokens.lsquare)
    elseif c == ']'; return emit(l, Tokens.rsquare)
    elseif c == '{'; return emit(l, Tokens.lbrace)
    elseif c == ';'; return emit(l, Tokens.semicolon)
    elseif c == '}'; return emit(l, Tokens.rbrace)
    elseif c == '('; return emit(l, Tokens.lparen)
    elseif c == ')'; return emit(l, Tokens.rparen)
    elseif c == ','; return emit(l, Tokens.comma)
    elseif c == '*'; return emit(l, Tokens.star)
    elseif c == '>'; return lex_greater(l)
    elseif c == '<'; return lex_less(l)
    elseif c == ':'; return lex_colon(l)
    elseif c == '|'; return lex_bar(l)
    elseif c == '@'; return lex_at(l)
    elseif c == '&'; return lex_amper(l)
    elseif c == '\''; return lex_prime(l)
    elseif c == '?'; return emit(l, Tokens.conditional)
    elseif c == '"'; return lex_quote(l);
    elseif c == '%'; return lex_percent(l);
    elseif c == '/'; return lex_forwardslash(l);
    elseif c == '.'; return lex_dot(l);
    elseif isdigit(c) || c == '-' || c == '+' return lex_digitorsign(l)
    elseif is_identifier_start_char(c); return lex_identifier(l)
    else emit_error(l)
    end

    #=
    if eof(c); return emit(l, Tokens.Eof)
    elseif c == '$'; return lex_dollar(l);
    elseif c == '"'; return lex_quote(l);
    elseif c == ';'; return lex_comment(l)
    elseif c == '!'; return lex_exclaim(l);

    else emit_error(l)
    end
    =#
end


function lex_whitespace(l::Lexer)::Token
    accept_batch(l, iswhitespace)
    return emit(l, Tokens.Whitespace)
end

function lex_comment(l::Lexer)::Token
    if readchar(l) != '='
        while true
            c = readchar(l)
            if c == '\n' || eof(c)
                backup!(l)
                return emit(l, Tokens.Comment, skipfirst = 1)
            end
        end
    else
        c = readchar(l) # consume the '='
        n_start, n_end = 1, 0
        while true
            if eof(c)
                return emit_error(l, Tokens.EOF_in_multicomment)
            end
            nc = readchar(l)
            if c == '#' && nc == '='
                n_start += 1
            elseif c == '=' && nc == '#'
                n_end += 1
            end
            if n_start == n_end
                return emit(l, Tokens.Comment, skipfirst = 2, skiplast = 2)
            end
            c = nc
        end
    end
end

# Lex a greater char, a '>' has been consumed
function lex_greater(l::Lexer)::Token
    if accept(l, '>') # >>
        if accept(l, '>') # >>>
            if accept(l, '=') # >>>=
                return emit(l, Tokens.ass_bitshift_rrr)
            elseif accept(l, iswhitespace)
                return emit(l, Tokens.bitshift_rrr)
            else # >>>?, ? not a =
                return emit_error(l)
            end
        else # >>?
            if accept(l, '=') # >>=
                return emit(l, Tokens.ass_bitshift_rr)
            elseif accept(l, iswhitespace) # '>> '
                return emit(l, Tokens.bitshift_rr)
            else # '>>?', ? not =, >, ' '
                return emit_error(l)
            end
        end
    elseif accept(l, '=')
            return emit(l, Tokens.ass_bitshift_r)
    elseif accept(l, iswhitespace)
            return emit(l, Tokens.comp_r) # '> '
    else
        return emit_error(l)
    end
end

# Lex a less char, a '<' has been consumed
function lex_less(l::Lexer)::Token
    if accept(l, '<') # <<
        if accept(l, '=') # <<=
            return emit(l, Tokens.ass_bitshift_ll)
        elseif accept(l, iswhitespace) # '<< '
            return emit(l, Tokens.bitshift_ll)
        else # '<<?', ? not =, ' '
            return emit_error(l)
        end
    elseif accept(l, '=')
        return emit(l, Tokens.ass_bitshift_l)
    elseif accept(l, ':')
        return emit(l, Tokens.issubtype)
    elseif accept(l, '|') # <|
        return emit(l, Tokens.pipe_l)
    else
        return emit(l, Tokens.comp_l) # '> '
    end
end



# Lex all tokens that start with an = character.
# An '=' char has been consumed
function lex_equal(l::Lexer)::Token
    if accept(l, '=') # ==
        if accept(l, iswhitespace)
            return emit(l, Tokens.ass_equal2)
        elseif accept(l, '=') # ===
            if accept(l, iswhitespace)
                emit(l, Tokens.ass_equal3)
            else # ===?, ? != ' '
                emit_error(l)
            end
        end
    elseif accept(l, '>') # =>
        emit(l, Tokens.ass_equal_r)
    else
        emit(l, Tokens.ass_equal)
    end
end

# Lex a colon, a ':' has been consumed
function lex_colon(l::Lexer)::Token
    if accept(l, ':') # '::'
        emit(l, Tokens.decl)
    elseif accept(l, iswhitespace) # ': '
        emit(l, Tokens._colon)
    elseif accept_batch(l, is_identifier_char) # :foo32
        emit(l, Tokens.t_symbol, skipfirst = 1)
    else
        emit_error(l)
    end
end

function lex_exclaim(l::Lexer)::Token
    if accept(l, '=') # !=
        if accept(l, '=')
            return emit(l, Tokens.comp_neq2) # !==
        else # !=
            return emit(l, Tokens.comp_neq)
        end
    else
        return emit(l, Tokens.exclaim)
    end
end

function lex_percent(l::Lexer)::Token
    if accept(l, '=')
        return emit(l, Tokens.ass_perc)
    else
        return emit(l, Tokens.perc)
    end
end

function lex_bar(l::Lexer)::Token
    if accept(l, iswhitespace)
        emit(l, Tokens.pipe) # '| '
    elseif accept(l, '=') # |=
        return emit(l, Tokens.ass_bar)
    elseif accept(l, '>') # |>
        return emit(l, Tokens.pipe_r)
    elseif accept(l, '|') # ||
        return emit(l, Tokens.lazy_or)
    else
        return emit_error(l)
    end
end


function lex_digitorsign(l::Lexer)::Token
    # A digit is an int
    longest, kind = position(l), Tokens.t_int

    accept(l, '-')
    if accept_batch(l, isdigit) && position(l) > longest
        longest, kind = position(l), Tokens.t_int
    end

    seek2startpos!(l)

    accept(l, "+-")
    if accept_batch(l, isdigit) && accept(l, '.')
        accept_batch(l, isdigit)
        if position(l) > longest
            longest, kind = position(l), Tokens.t_float
        end
        if accept(l, "eE")
            accept(l, "+-")
            if accept_batch(l, isdigit) && position(l) > longest
                longest, kind = position(l), Tokens.t_float
            end
        end
    end

    seek2startpos!(l)

    # 0x[0-9A-Fa-f]+
    if accept(l, '0') && accept(l, 'x')
        accept("o")
        if accept_batch(ishex) && position(l) > longest
            longest, kind = position(l), Tokens.APFloat
        end
    end

    seek(l, longest)

    if kind == Tokens.Error
        return emit_error(l)
    else
        return emit(l, kind)
    end

end


# Lex a prim sign, a ''' has been consumed
function lex_prime(l)
    @debug "lexing prime, current char is $(peekchar(l)), pos is $(position(l))"
    while true
        c = readchar(l)
        if eof(c)
            return emit_error(l, Tokens.EOF_in_char)
        elseif c == '\\'
            if eof(readchar(l))
                return emit_error(l, Tokens.EOF_in_char)
            end
        elseif c == '\''
            return emit(l, Tokens.t_char, skipfirst=1, skiplast=1)
        end
    end
end


# Lex all tokens that start with an @ character.
# An '@' char has been consumed
function lex_at(l::Lexer)::Token
    if accept_batch(l, is_identifier_char)
        return emit(l, Tokens.macro_call)
    else
        return emit_error(l)
    end
end


function lex_amper(l::Lexer)::Token
    if accept(l, '&')
        return emit(l, Tokens.lazy_and)
    elseif accept(l, "=")
        return emit(l, Tokens.ass_ampr)
    else
        return emit(l, Tokens.amper)
    end
end

function lex_identifier(l::Lexer)::Token

    accept_batch(l, is_identifier_char)

    kind = get(Tokens.KEYWORDS, extract_tokenstring(l), Tokens.Identifier)
    return emit(l, kind)
end

# Parse a token starting with a quote.
# A '"' has been consumed
function lex_quote(l::Lexer)::Token
    if accept(l, '"') # ""
        if accept(l, '"') # """
            if read_string(l, Tokens.t_string_triple)
                emit(l, Tokens.t_string_triple)
            else
                emit_error(l, Tokens.EOF_in_string)
            end
        else # empty string
            return emit(l, Tokens.t_string)
        end
    else # "?, ? != '"'
        if read_string(l, Tokens.t_string)
            emit(l, Tokens.t_string)
        else
            return emit_error(l, Tokens.EOF_in_string)
        end
    end
end

# Parse a token starting with a quote.
# A '"' has been consumed
function lex_forwardslash(l::Lexer)::Token
    if accept(l, "/") # //
        if accept(l, "=") # //=
            return emit(l, Tokens.ass_fslash2)
        else
            return emit(l, Tokens.fslash2)
        end
    elseif accept(l, "=") # /=
        return emit(l, Tokens.ass_fslash)
    else
        return emit(l, Tokens.fslash)
    end
end


function lex_dot(l::Lexer)::Token
    if accept(l, '.')
        if accept(l, '.')
            return emit(l, Tokens.dot3)
        else
            return emit(l, Tokens.dot2)
        end
    else
        return emit(l, Tokens.dot)
    end
end


function lex_dollar(l::Lexer)::Token
    if accept(l, '$')
        return emit(l, Tokens.lazy_and)
    emit_error(l)
end


end # module