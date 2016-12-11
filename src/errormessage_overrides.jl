import OhMyREPL.ErrorMessages: prev_er, err_linfo_color, err_funcdef_color,
                                linfos, stack_counter

import Base.REPL: display_error, ip_matches_func
import Base.StackTraces: empty_sym, show_spec_linfo
import Base: process_backtrace, show_trace_entry, show_backtrace, default_color_warn, repl_color, have_color,
             text_colors, color_normal

Base.text_colors[:nothing] = ""

function Base.REPL.display_error(io::IO, er, bt)
    prev_er = (er, bt)
    legacy_errs = haskey(ENV, "LEGACY_ERRORS")
    # remove REPL-related frames from interactive printing
    eval_ind = findlast(addr->Base.REPL.ip_matches_func(addr, :eval), bt)
    if eval_ind != 0
        bt = bt[1:eval_ind-1]
    end

    Base.with_output_color(legacy_errs ? :red : :nothing, io) do io
        legacy_errs && print(io, "ERROR: ")
        Base.showerror(IOContext(io, :REPLError => !legacy_errs), er, bt)
    end
end

function Base.showerror(io::IO, ex, bt; backtrace=true)
    if get(io, :REPLError, false)
        if backtrace
            io_bt = IOBuffer()
            io_bt_con = IOContext(io_bt, io)
            show_backtrace(io_bt_con, bt)
            backtrace_str = String(take!(io_bt))
            # Only print the backtrace header if there actually is a printed backtrace
            if backtrace_str != ""
                header = string("------ ", typeof(ex).name.name, " ")
                stacktrace_str = " Stacktrace (most recent call last)"
                line_len = min(75, Base.Terminals.width(Base.active_repl.t))
                print_with_color(default_color_warn, io, header, "-"^(line_len - strwidth(header) - strwidth(stacktrace_str)))
                print(io, stacktrace_str, "\n")
                print(io, backtrace_str, "\n")
            end
        end
        try
            Base.with_output_color(default_color_warn, io) do io
                showerror(io, ex)
            end
        end
    else
        try
            showerror(io, ex)
        finally
            backtrace && show_backtrace(io, bt)
        end
    end
end

# This is replaced because we want to have the option to not show inlined functions in backtrace
function Base.show_backtrace(io::IO, t::Vector)
    stack_counter[] = 0
    resize!(linfos, 0)
    process_entry(last_frame, n) = begin
        show_trace_entry(io, last_frame, n)
        push!(linfos, (string(last_frame.file), last_frame.line))
    end
    process_backtrace(process_entry, t, rev  = get(io, :REPLError, false))
end


# This is replaced because we want to have the option to not show inlined functions in backtrace
# call process_func on each frame in a backtrace
function process_backtrace(process_func::Function, t::Vector, limit::Int=typemax(Int); skipC = true, rev = false)
    n = 0
    last_frame = StackTraces.UNKNOWN
    count = 0
    for i = (rev ? reverse(eachindex(t)) : eachindex(t))
        lkups = StackTraces.lookup(t[i])
        for lkup in (rev ? reverse(lkups) : lkups)
            if lkup === StackTraces.UNKNOWN
                continue
            end

            if lkup.from_c && skipC; continue; end
            if i == 1 && lkup.func == :error; continue; end
            count += 1
            if count > limit; break; end

            if lkup.file != last_frame.file || lkup.line != last_frame.line || lkup.func != last_frame.func
                if n > 0
                    process_func(last_frame, n)
                end
                n = 1
                last_frame = lkup
            else
                n += 1
            end
        end
    end
    if n > 0
        process_func(last_frame, n)
    end
end

function Base.show_lambda_types(io::IO, li::LambdaInfo)
    isreplerror = get(io, :REPLError, false)
    local sig
    returned_from_do = false
    Base.with_output_color(isreplerror  ? err_funcdef_color() : :nothing, io) do io
        if li.specTypes === Tuple
            print(io, li.def.name, "(...)")
            returned_from_do = true
            return
        end
        sig = li.specTypes.parameters
        ft = sig[1]
        if ft <: Function && isempty(ft.parameters) &&
                isdefined(ft.name.module, ft.name.mt.name) &&
                ft == typeof(getfield(ft.name.module, ft.name.mt.name))
            print(io, ft.name.mt.name)
        elseif isa(ft, DataType) && is(ft.name, Type.name) && isleaftype(ft)
            f = ft.parameters[1]
            print(io, f)
        else
            print(io, "(::", ft, ")")
        end
    end
    returned_from_do && return
    first = true
    isreplerror ? print_with_color(:bold, io, "(") : print(io, '(')
    for i = 2:length(sig)  # fixme (iter): `eachindex` with offset?
        first || print(io, ", ")
        first = false
        print(io, "::", sig[i])
    end
    isreplerror ? print_with_color(:bold, io, ")") : print(io, ')')
    nothing
end


# Stackframes

function Base.show_trace_entry(io, frame, n)
    print(io, "\n")
    show(io, frame)
    n > 1 && print(io, " (repeats ", n, " times)")
    get(io, :REPLError, false) && println(io)
end

# Want to be able to not show the argument type signature for a stack frame

function Base.StackTraces.show(io::IO, frame::StackFrame; full_path::Bool=false)
    isreplerror = get(io, :REPLError, false)
    isreplerror ? print_with_color(:bold, io, " [$(stack_counter[] += 1)] — ") : print(io, " in ")
    show_spec_linfo(io, frame)
    if frame.file !== empty_sym
        file_info = full_path ? string(frame.file) : basename(string(frame.file))
        isreplerror && haskey(ENV, "JULIA_ERR_LINFO_NEWLINE") && print(io, "\n       ⌙")
        print(io, " at ")
        Base.with_output_color(isreplerror ? err_linfo_color() : :nothing, io) do io
            print(io, file_info, ":")
            if frame.line >= 0
                print(io, frame.line)
            else
                print(io, "?")
            end
        end
    end
    if frame.inlined
        print(io, " [inlined]")
    end
end

function Base.with_output_color(f::Function, color::Symbol, io::IO, args...)
    buf = IOBuffer()
    have_color && print(buf, get(text_colors, color, color_normal))
    try f(buf, args...)
    finally
        have_color && color != :nothing && print(buf, color_normal)
        print(io, String(take!(buf)))
    end
end
