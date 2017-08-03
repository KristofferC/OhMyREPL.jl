
using Crayons
using Tokenize

import OhMyREPL.Passes.SyntaxHighlighter.SYNTAX_HIGHLIGHTER_SETTINGS

HIGHLIGHT_MARKDOWN = Ref(true)
enable_highlight_markdown(v::Bool) = HIGHLIGHT_MARKDOWN[] = v

function Base.Markdown.term(io::IO, md::Base.Markdown.Code, columns)
    code = md.code
    # Want to remove potential.
    lang = md.language == "" ? "" : first(split(md.language))
    outputs = String[]
    sourcecodes = String[]
    do_syntax = false
    if lang == "jldoctest" || lang == "julia-repl"
        do_syntax = true
        code_blocks = split("\n"*code, "\njulia> ")
        for codeblock in code_blocks[2:end] #
            expr, pos = parse(codeblock, 1, raise = false);
            sourcecode, output = if pos > length(codeblock)
                codeblock, ""
            else
                ind = Base.chr2ind(codeblock, pos)
                codeblock[1:ind-1], codeblock[ind:end]
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
            SYNTAX_HIGHLIGHTER_SETTINGS(crayons, tokens, 0)
            buff = IOBuffer()
            if lang == "jldoctest" || lang == "julia-repl"
                print(buff, Crayon(foreground = :green, bold = true), "julia> ", Crayon(reset = true))
            end
            for (token, crayon) in zip(tokens, crayons)
                print(buff, crayon)
                print(buff, untokenize(token))
                print(buff, Crayon(reset = true))
            end
            print(buff, output)

            str = String(take!(buff))
            for line in Base.Markdown.lines(str)
                print(io, " "^Base.Markdown.margin)
                println(io, line)
            end
        end
    else
        Base.Markdown.with_output_format(:cyan, io) do io
            for line in Base.Markdown.lines(md.code)
                print(io, " "^Base.Markdown.margin)
                println(io, line)
            end
        end
    end
end
