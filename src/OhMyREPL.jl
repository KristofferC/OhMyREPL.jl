    __precompile__()
"""
A package that provides a new REPL that has syntax highlighting,
bracket matching and other nifty features.
"""
module OhMyREPL

using Compat
import Compat: UTF8String, String

using Tokenize
using Crayons

export colorscheme!, colorschemes, enable_autocomplete_brackets, test_colorscheme

include("repl_pass.jl")
include("repl.jl")
include(joinpath("passes", "Passes.jl"))

include("BracketInserter.jl")
if VERSION > v"0.5-" && VERSION.minor < 6
    include("ErrorMessages.jl")
end
include("prompt.jl")

# Some backward compatability
module ANSICodes
    using Crayons
    const ANSIToken = Crayon
end

export ANSITokens

function colorscheme!(name::String)
    Passes.SyntaxHighlighter.activate!(Passes.SyntaxHighlighter.SYNTAX_HIGHLIGHTER_SETTINGS,
                                       name)
end

function colorschemes()
    show(Passes.SyntaxHighlighter.SYNTAX_HIGHLIGHTER_SETTINGS)
end

const TEST_STR = """

function funcdef(x::Float64, y::Int64)
    y = 100_000
    x = :foo
    s = "I am a happy string"
    @time 1+1
    #= Comments look like this =#
    z = funccall(x, y)
    5 * 3 + 2 - 1
end
"""

function test_colorscheme(name::String, str::String = TEST_STR)
    syntaxpass = get_pass(PASS_HANDLER, "SyntaxHighlighter")
    active = syntaxpass.active
    try
        colorscheme!(name)
        test_pass(syntaxpass, str)
    finally
        syntaxpass.active = active
    end
    return
end


function test_colorscheme(cs::Passes.SyntaxHighlighter.ColorScheme, str::String = TEST_STR)
    syntaxpass = get_pass(PASS_HANDLER, "SyntaxHighlighter")
    active = syntaxpass.active
    name = "plzdontnameyourcolorschemethis"
    try
        Passes.SyntaxHighlighter.add!(syntaxpass, name, cs)
        colorscheme!(name)
        test_pass(syntaxpass, str)
    finally
        syntaxpass.active = active
        if haskey(syntaxpass.schemes, name)
            delete!(syntaxpass.schemes, name)
        end
    end
    return
end


showpasses(io::IO = STDOUT) = Base.show(io, PASS_HANDLER)


function __init__()
    if isdefined(Base, :active_repl)
        Prompt.insert_keybindings()
    else
        atreplinit() do repl
            repl.interface = Base.REPL.setup_interface(repl)
            Prompt.insert_keybindings()
            update_interface(repl.interface)
            main_mode = repl.interface.modes[1]
            p = repl.interface.modes[5]
            # These are inserted here because we only want to insert them for the Julia mode
            d = Dict(
            # Up Arrow
            "\e[A" => (s,o...)-> begin
                Base.LineEdit.edit_move_up(s) || Base.LineEdit.enter_prefix_search(s, p, true)
                Prompt.rewrite_with_ANSI(s)
            end,
            # Down Arrow
            "\e[B" => (s,o...)-> begin
                 Base.LineEdit.edit_move_down(s) || Base.LineEdit.enter_prefix_search(s, p, false)
                 Prompt.rewrite_with_ANSI(s)
            end
            )
            main_mode.keymap_dict = Base.LineEdit.keymap([d, main_mode.keymap_dict])
        end
    end

    mktemp() do _, f
        old_stderr = STDERR
        redirect_stderr(f)

        Base.LineEdit.refresh_line(s) = (Base.LineEdit.refresh_multi_line(s); OhMyREPL.Prompt.rewrite_with_ANSI(s))
        if VERSION > v"0.5-" && VERSION.minor < 6
            include(joinpath(dirname(@__FILE__), "errormessage_overrides.jl"))
        end
        include(joinpath(dirname(@__FILE__), "output_prompt_overwrite.jl"))

        @eval begin
            function Base.REPL.display(d::Base.REPL.REPLDisplay, mime::MIME"text/plain", x)
                global OUTPUT_PROMPT
                io = Base.REPL.outstream(d.repl)
                write(io, OUTPUT_PROMPT)
                Base.have_color && write(io, Base.REPL.answer_color(d.repl))
                show(IOContext(io, :limit => true), mime, x)
                println(io)
            end
        end

        redirect_stderr(old_stderr)
    end
end

end # module
