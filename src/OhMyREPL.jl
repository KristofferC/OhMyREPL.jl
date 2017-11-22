    __precompile__()
"""
A package that provides a new REPL that has syntax highlighting,
bracket matching and other nifty features.
"""
module OhMyREPL

using Tokenize
using Crayons

export colorscheme!, colorschemes, enable_autocomplete_brackets, enable_highlight_markdown, test_colorscheme

include("repl_pass.jl")
include("repl.jl")
include("passes/Passes.jl")

include("BracketInserter.jl")
include("prompt.jl")

import .BracketInserter.enable_autocomplete_brackets


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
    options = Base.JLOptions()
    # command-line
    if v"0.5.2" < VERSION < v"0.7-"
         if (options.eval != C_NULL) || (options.print != C_NULL)
            return
        end
    else
        options.commands != C_NULL && return
    end

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

    mktemp() do file, io
        old_stderr = STDERR
        redirect_stderr(io)
        include(joinpath(@__DIR__, "refresh_lines.jl"))
        include(joinpath(@__DIR__, "output_prompt_overwrite.jl"))
        include(joinpath(@__DIR__, "MarkdownHighlighter.jl"))
        redirect_stderr(old_stderr)
        seek(io, 0)
        for line in eachline(io)
            if !ismatch(Regex("^WARNING: Method definition [refresh_line|display|term]" *
                    ".* overwritten in module .* at $(escape_string(@__DIR__)).*\$"), line)
                println(line)
            end
        end
    end
end

end # module
