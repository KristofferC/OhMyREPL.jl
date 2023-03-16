
using Crayons
import Markdown

import .OhMyREPL.Passes.SyntaxHighlighter.SYNTAX_HIGHLIGHTER_SETTINGS
import .OhMyREPL.HIGHLIGHT_MARKDOWN

function Markdown.term(io::IO, md::Markdown.Code, columns)
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

    if do_syntax && HIGHLIGHT_MARKDOWN[]
        for (sourcecode, output) in zip(sourcecodes, outputs)
            tokens = collect(tokenize(sourcecode))
            crayons = fill(Crayon(), length(tokens))
            SYNTAX_HIGHLIGHTER_SETTINGS(crayons, tokens, 0, sourcecode)
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
            for line in Markdown.lines(str)
                print(io, " "^Markdown.margin)
                println(io, line)
            end
        end
    else
        Base.with_output_color(:cyan, io) do io
            for line in Markdown.lines(md.code)
                print(io, " "^Markdown.margin)
                println(io, line)
            end
        end
    end
end
