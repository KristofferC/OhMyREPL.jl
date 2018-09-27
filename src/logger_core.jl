using Base.CoreLogging: LogLevel, AbstractLogger,
    BelowMinLevel, Debug, Info, Warn, Error, AboveMaxLevel

import Base.CoreLogging: handle_message, shouldlog, min_enabled_level, catch_exceptions

using Logging: default_metafmt, termlength


"""
    OhMyLogger(stream=stderr, min_level=Info; meta_formatter=default_metafmt,
                  show_limited=true, right_justify=0)

Logger with formatting optimized for readability in a text console, for example
interactive work with the Julia REPL.

Log levels less than `min_level` are filtered out.

Message formatting can be controlled by setting keyword arguments:

* `meta_formatter` is a function which takes the log event metadata
  `(level, _module, group, id, file, line)` and returns a color (as would be
  passed to printstyled), prefix and suffix for the log message.  The
  default is to prefix with the log level and a suffix containing the module,
  file and line location.
* `show_limited` limits the printing of large data structures to something
  which can fit on the screen by setting the `:limit` `IOContext` key during
  formatting.
* `right_justify` is the integer column which log metadata is right justified
  at. The default is zero (metadata goes on its own line).
"""
struct OhMyLogger <: AbstractLogger
    stream::IO
    min_level::LogLevel
    meta_formatter
    show_limited::Bool
    right_justify::Int
    message_limits::Dict{Any,Int}

    last_message_nlines::Ref{Int}
    last_message_id::Ref{Symbol}
end

function OhMyLogger(stream::IO=stderr, min_level=Info;
                       meta_formatter=default_metafmt, show_limited=true,
                       right_justify=0)

    OhMyLogger(stream, min_level, meta_formatter,
               show_limited, right_justify, Dict{Any,Int}(),
               Ref(0), Ref(Symbol(""))
              )
end

shouldlog(logger::OhMyLogger, level, _module, group, id) =
    get(logger.message_limits, id, 1) > 0

min_enabled_level(logger::OhMyLogger) = logger.min_level

##################### Formatting of values in key value pairs #######################
showvalue(io, msg, key::Symbol) = showvalue(io, msg, Val{key}())
_showvalue(io, msg) = show(io, "text/plain", msg)

function showvalue(io, msg, ::Any)
    if msg isa AbstractString && occursin(r"\%\s*$", msg) # ends with a %
        showvalue(io, msg, Val{:progress}())
    else
        _showvalue(io, msg)
    end
end

showvalue(io, msg, ::Val{:progress}) = _showvalue(io, progress_message(msg))


function showvalue(io, e::Tuple{Exception,Any}, ::Any)
    ex,bt = e
    showerror(io, ex, bt; backtrace = bt!=nothing)
end
showvalue(io, ex::Exception, ::Any) = showerror(io, ex)

#####################################################################################



function prepare_output(logger::OhMyLogger, level, message, _module, group, id,
                        filepath, line; kwargs...)
    # Generate a text representation of the message and all key value pairs,
    # split into lines.
    msglines = [(indent=0,msg=l) for l in split(chomp(string(message)), '\n')]
    dsize = displaysize(logger.stream)
    if !isempty(kwargs)
        valbuf = IOBuffer()
        rows_per_value = max(1, dsize[1]÷(length(kwargs)+1))
        valio = IOContext(IOContext(valbuf, logger.stream),
                          :displaysize=>(rows_per_value,dsize[2]-5))
        if logger.show_limited
            valio = IOContext(valio, :limit=>true)
        end
        for (key,val) in pairs(kwargs)
            showvalue(valio, val, key)
            vallines = split(String(take!(valbuf)), '\n')
            if length(vallines) == 1
                push!(msglines, (indent=2,msg=SubString("$key = $(vallines[1])")))
            else
                push!(msglines, (indent=2,msg=SubString("$key =")))
                append!(msglines, ((indent=3,msg=line) for line in vallines))
            end
        end
    end

    # Format lines as text with appropriate indentation and with a box
    # decoration on the left.
    color, prefix, suffix = logger.meta_formatter(level, _module, group, id, filepath, line)
    minsuffixpad = 2
    buf = IOBuffer()
    iob = IOContext(buf, logger.stream)
    nonpadwidth = 2 + (isempty(prefix) || length(msglines) > 1 ? 0 : length(prefix)+1) +
                  msglines[end].indent + termlength(msglines[end].msg) +
                  (isempty(suffix) ? 0 : length(suffix)+minsuffixpad)
    justify_width = min(logger.right_justify, dsize[2])
    if nonpadwidth > justify_width && !isempty(suffix)
        push!(msglines, (indent=0,msg=SubString("")))
        minsuffixpad = 0
        nonpadwidth = 2 + length(suffix)
    end
    for (i,(indent,msg)) in enumerate(msglines)
        boxstr = length(msglines) == 1 ? "[ " :
                 i == 1                ? "┌ " :
                 i < length(msglines)  ? "│ " :
                                         "└ "
        printstyled(iob, boxstr, bold=true, color=color)
        if i == 1 && !isempty(prefix)
            printstyled(iob, prefix, " ", bold=true, color=color)
        end
        print(iob, " "^indent, msg)
        if i == length(msglines) && !isempty(suffix)
            npad = max(0, justify_width - nonpadwidth) + minsuffixpad
            print(iob, " "^npad)
            printstyled(iob, suffix, color=Base.stackframe_lineinfo_color())
        end
        println(iob)
    end

    buf
end


function handle_message(logger::OhMyLogger, level, message, _module, group, id,
                        filepath, line; maxlog=nothing, overwrite_lastlog=nothing,
                        kwargs...)
    id = Symbol(filepath, "#", line,'#', message)  # HACK around https://github.com/JuliaLang/julia/issues/29227
    prev_id = logger.last_message_id[]
    if overwrite_lastlog == nothing
        # default to only overwrite if same source
        overwrite_lastlog = id == prev_id
    end

    if maxlog != nothing && maxlog isa Integer
        if overwrite_lastlog && haskey(logger.message_limits, prev_id)
            # We are overwriting it so it undoes one of it's limitted uses
            logger.message_limits[prev_id] += 1
        end

        remaining = get!(logger.message_limits, id, maxlog)
        logger.message_limits[id] = remaining - 1
        remaining > 0 || return
    end
    
    buf = prepare_output(logger, level, message, _module, group, id,
                         filepath, line; kwargs...)
    
    buf_contents = take!(buf)
    if overwrite_lastlog
        move_cursor_up_while_clearing_lines(logger.stream, logger.last_message_nlines[])
    end

    write(logger.stream, buf_contents)
    logger.last_message_id[] = id
    logger.last_message_nlines[] = count(isequal(Int('\n')), buf_contents)
    nothing
end



