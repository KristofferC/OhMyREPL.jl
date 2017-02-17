    __precompile__()
"""
A package that provides a new REPL that has syntax highlighting,
bracket matching and other nifty features.
"""
module OhMyREPL

using Tokenize

using Compat
import Compat: UTF8String, String

export colorscheme!, colorschemes, enable_autocomplete_brackets, test_colorscheme

include("ANSICodes.jl")
include("repl_pass.jl")
include("repl.jl")
include(joinpath("passes", "Passes.jl"))

include("BracketInserter.jl")
include("ErrorMessages.jl")
include("prompt.jl")

using .ANSICodes
export ANSICodes


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
            repl.interface = Base.REPL.setup_interface(repl; extra_repl_keymap = Prompt.NEW_KEYBINDINGS)
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
    # Thanks to @Ismael-VC for this code.
    if ccall(:jl_generating_output, Cint, ()) == 0
        ORIGINAL_STDERR = STDERR
        err_rd, err_wr = redirect_stderr()
        err_reader = @async @compat readstring(err_rd)
        Base.LineEdit.refresh_line(s) = (Base.LineEdit.refresh_multi_line(s); OhMyREPL.Prompt.rewrite_with_ANSI(s))
        if VERSION > v"0.5-"
            include(joinpath(dirname(@__FILE__), "errormessage_overrides.jl"))
        end
        redirect_stderr(ORIGINAL_STDERR)
        close(err_wr)
    end
end

end # module
