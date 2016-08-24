module ErrorMessages

export display_last_error, ErrorMessageSettings, test_error

import Base.REPL: display_error, ip_matches_func
import Base.StackTraces: empty_sym, show_spec_linfo
import Base: process_backtrace, show_trace_entry, show_backtrace, default_color_warn


# We have a global variable that will always store the latest show backtrace
# This is useful for debugging the package itself but also if you want to reprint
# the latest error with different settings
local prev_er = nothing

function display_last_error(io::IO = STDOUT)
    if prev_er == nothing
        error("no error shown in this session")
    else
        Base.REPL.display_error(io, prev_er[1], prev_er[2])
    end
end


file_color = :green
funcdef_color = :yellow

function Base.REPL.display_error(io::IO, er, bt)
    global prev_er
    prev_er = (er, bt)
    legacy_errs = haskey(ENV, "LEGACY_ERRORS")
    Base.with_output_color(legacy_errs ? :red : :nothing, io) do io
        # remove REPL-related frames from interactive printing
        eval_ind = findlast(addr->Base.REPL.ip_matches_func(addr, :eval), bt)
        if eval_ind != 0
            bt = bt[1:eval_ind-1]
        end
        Base.showerror(IOContext(io, :REPLError => !legacy_errs), er, bt)
    end
end

function Base.showerror(io::IO, ex, bt; backtrace=true)
    if get(io, :REPLError, false)
        if backtrace
            io_bt = IOBuffer()
            io_bt_con = IOContext(io_bt, io)
            show_backtrace(io_bt_con, bt)
            backtrace_str = takebuf_string(io_bt)
            # Only print the backtrace header if there actually is a printed backtrace
            if backtrace_str != ""
                header = string(typeof(ex).name.name)
                line_len = 76
                print_with_color(default_color_warn, io, "-"^line_len * "\n")
                print_with_color(default_color_warn, io, header)
                print(io, lpad("Stacktrace (most recent call last)", line_len - strwidth(header), ' '))
                print(io, backtrace_str)
                println(io)
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
    process_entry(last_frame, n) =
        show_trace_entry(io, last_frame, n)
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


# Stackframes

function Base.show_trace_entry(io, frame, n)
    print(io, "\n")
    show(io, frame)
    n > 1 && print(io, " (repeats ", n, " times)")
    get(io, :REPLError, false) && println(io)
end

# Want to be able to not show the argument type signature for a stack frame

function Base.StackTraces.show(io::IO, frame::StackFrame; full_path::Bool=false)
    print(io, " in ")
    col = get(io, :REPLError, false)  ? funcdef_color : :nothing
    Base.with_output_color(col, io) do io
        show_spec_linfo(io, frame)
    end
    if frame.file !== empty_sym
        file_info = full_path ? string(frame.file) : basename(string(frame.file))
        get(io, :REPLError, false) && print(io, "\n    ⌙")
        print(io, " at ")
        col = get(io, :REPLError, false)  ? file_color : :nothing
        Base.with_output_color(col, io) do io
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


type ThisisALongTypeThatWeMightNotWantToSee end
typealias TL ThisisALongTypeThatWeMightNotWantToSee

@noinline ff(x) = (a = rand(5); a[6])
@noinline function g(a::TL, b::TL, c, d::Float64, e::Float64, f::TL, n)
    if n == 0
        return ff(2)
    else
        g(a, b, c, d, e, f, n-1)
    end
    return 0
end

@noinline h(x) = g(TL(), TL(), 2, 1.0, 2.0, TL(), 4)


function test_it(args...)
    h(2.0)
end

test_error() = test_it(1,2,3,4,5)


end # module
