module ErrorMessages

using OhMyREPL

import Base: repl_color

export display_last_error, test_error

Base.text_colors[:nothing] = ""

# We have a global variable that will always store the latest show backtrace
# This is useful for debugging the package itself but also if you want to reprint
# the latest error with different settings
global prev_er = nothing

function display_last_error(io::IO = STDOUT)
    if prev_er == nothing
        error("no error shown in this session")
    else
        Base.REPL.display_error(io, prev_er[1], prev_er[2])
    end
end

err_linfo_color()   = repl_color("JULIA_ERR_LINFO_COLOR", :bold)
err_funcdef_color() = repl_color("JULIA_ERR_FUNCDEF_COLOR", :bold)

# TODO: Get rid of these globals..
n_frames = Ref{Int}(0)
linfos = []
stack_counter = Ref{Int}(0)

function insert_keymap!(D)
    D["^Q"] = (s, o...) -> begin
        str = takebuf_string(Base.LineEdit.buffer(s))
        n = tryparse(Int, str)
        if isnull(n)
            write(Base.LineEdit.buffer(s), str)
            return
        else
            n = get(n, false)
            if n <= 0 || n > length(linfos) || startswith(linfos[n][1], "./REPL")
                write(Base.LineEdit.buffer(s), str)
                return
            end
            Base.edit(linfos[n][1], linfos[n][2])
            Base.LineEdit.refresh_line(s)
            return
        end
    end
end

insert_keymap!(OhMyREPL.Prompt.NEW_KEYBINDINGS)

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
