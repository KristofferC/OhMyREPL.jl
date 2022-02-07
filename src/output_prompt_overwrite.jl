import REPL
function REPL.display(d::REPL.REPLDisplay, mime::MIME"text/plain", x)
    io = REPL.outstream(d.repl)
    output_prompt = OUTPUT_PROMPT isa String ? OUTPUT_PROMPT : OUTPUT_PROMPT()
    write(io, OUTPUT_PROMPT_PREFIX)
    write(io, output_prompt, "\e[0m")
    Base.have_color && write(io, REPL.answer_color(d.repl))
    scheme = OhMyREPL.Passes.SyntaxHighlighter.SYNTAX_HIGHLIGHTER_SETTINGS.active
    color_prefs = GarishPrint.ColorScheme(
        fieldname = scheme.text,
        type      = scheme.argdef,

        keyword   = scheme.keyword,
        call      = scheme.call,

        text      = scheme.text,
        number    = scheme.number,
        string    = scheme.string,
        symbol    = scheme.symbol,
        op        = scheme.op,
        literal   = scheme.number,
        constant  = scheme.text,
        
        comment   = scheme.comment,
        undef     = scheme.comment,
        lineno    = scheme.comment,
    )
    limited_io = GarishPrint.GarishIO(io;
        limit = true,
        color = true,
        color_prefs = color_prefs,
    )
    pprint(limited_io, mime, x)
    println(io)
end
