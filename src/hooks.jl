import REPL
import REPL.LineEdit
using Crayons
import Markdown

function _refresh_line(s::REPL.LineEdit.BufferLike)
    LineEdit.refresh_multi_line(s)
    OhMyREPL.Prompt.rewrite_with_ANSI(s)
end

function _REPL_display(d::REPL.REPLDisplay, mime::MIME"text/plain", @nospecialize(x))
    x = Ref{Any}(x)
    REPL.with_repl_linfo(d.repl) do io
        if isdefined(REPL, :active_module)
            mod = REPL.active_module(d)::Module
        else
            mod = Main
        end
        io = IOContext(io, :limit => true, :module => mod)
        if OUTPUT_PROMPT !== nothing
            output_prompt = OUTPUT_PROMPT isa String ? OUTPUT_PROMPT : OUTPUT_PROMPT()
            write(io, OUTPUT_PROMPT_PREFIX)
            write(io, output_prompt, "\e[0m")
        end
        get(io, :color, false) && write(io, REPL.answer_color(d.repl))
        if isdefined(d.repl, :options) && isdefined(d.repl.options, :iocontext)
            # this can override the :limit property set initially
            io = foldl(IOContext, d.repl.options.iocontext, init=io)
        end
        show(io, mime, x[])
        println(io)
    end
    return nothing
end

split_lines(s::AbstractString) = isdefined(Markdown, :lines) ? Markdown.lines(s) : split(s, '\n')

function _Markdown_term(io::IO, md::Markdown.Code, columns)
    code = md.code
    # Want to remove potential.
    lang = md.language == "" ? "" : first(split(md.language))
    outputs = String[]
    sourcecodes = String[]
    do_syntax = false
    if occursin(r"jldoctest;?", lang) || lang == "julia-repl"
        do_syntax = true
        code_blocks = split("\n" * code, "\njulia> ")
        for codeblock in code_blocks[2:end] #
            expr, pos = Meta.parse(codeblock, 1, raise = false);
            sourcecode, output = begin
                if pos > length(codeblock)
                    codeblock, ""
                else
                    ind = nextind(codeblock, 0, pos)
                    pind = prevind(codeblock, ind)
                    codeblock[1:pind], codeblock[ind:end]
                end
            end
            push!(sourcecodes, string(sourcecode))
            push!(outputs, string(output))
        end
    elseif lang == "julia" || lang == ""
        do_syntax = true
        push!(sourcecodes, code)
        push!(outputs, "")
    end

    if do_syntax && OhMyREPL.HIGHLIGHT_MARKDOWN[]
        for (i, (sourcecode, output)) in enumerate(zip(sourcecodes, outputs))
            tokens = collect(tokenize(sourcecode))
            crayons = fill(Crayon(), length(tokens))
            OhMyREPL.Passes.SyntaxHighlighter.SYNTAX_HIGHLIGHTER_SETTINGS(crayons, tokens, 0, sourcecode)
            buff = IOBuffer()
            if lang == "jldoctest" || lang == "julia-repl"
                print(buff, Crayon(foreground = :red, bold = true), "julia> ", Crayon(reset = true))
            end
            for (token, crayon) in zip(tokens, crayons)
                print(buff, crayon)
                print(buff, untokenize(token, sourcecode))
                print(buff, Crayon(reset = true))
            end
            print(buff, output)

            str = String(take!(buff))
            lines = split_lines(str)
            for li in eachindex(lines)
                print(io, " "^Markdown.margin, lines[li])
                li < lastindex(lines) && println(io)
            end

            i < lastindex(sourcecodes) && println(io)
        end
    else
        Base.with_output_color(:cyan, io) do io
            lines = split_lines(md.code)
            for i in eachindex(lines)
                print(io, " "^Markdown.margin, lines[i])
                i < lastindex(lines) && println(io)
            end
        end
    end
end

_refresh_line_hook = _refresh_line

function activate_hooks()
    @eval begin
        LineEdit.refresh_line(s::REPL.LineEdit.BufferLike) =
            _refresh_line_hook(s)
        Markdown.term(io::IO, md::Markdown.Code, columns) =
            _Markdown_term(io, md, columns)
    end
    if !isdefined(REPL, :IPython)
        @eval REPL.display(d::REPL.REPLDisplay, mime::MIME"text/plain", x) =
            _REPL_display(d, mime, x)
    end
end
