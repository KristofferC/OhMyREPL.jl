# How to create an extra prompt and attach it to the current REPL was learned
# by reading the source code of @Keno's CXX.jl

module Prompt

import Base: LineEdit, REPL

import Base.LineEdit: buffer
import Base.REPL: respond, LatexCompletions, return_callback, repl_filename

import ..Passes
import Tokenize.Lexers


using PimpMyREPL
import PimpMyREPL: untokenize_with_ANSI, apply_passes!

function create_highlightREPL(; prompt = "fulia> ", name = :wat, repl = Base.active_repl,
    main_mode = repl.interface.modes[1])

    # Wat is this?
    mirepl = isdefined(repl,:mi) ? repl.mi : repl

    # Setup highlight prompt
    highlight_prompt = LineEdit.Prompt(prompt;
        # Copy colors from the prompt object
        prompt_prefix="\e[38;5;166m",
        prompt_suffix=Base.text_colors[:white],
        on_enter = return_callback)

    hp = main_mode.hist
    hp.mode_mapping[name] = highlight_prompt
    highlight_prompt.hist = hp

    highlight_prompt.on_done = respond(x->Base.parse_input_line(x,filename=repl_filename(repl,hp)), repl, highlight_prompt)

    main_mode == mirepl.interface.modes[1] &&
        push!(mirepl.interface.modes, highlight_prompt)


    search_prompt, skeymap = LineEdit.setup_search_keymap(hp)
    search_prompt.complete = LatexCompletions()


    mk = REPL.mode_keymap(main_mode)

    b = Dict{Any,Any}[skeymap, mk, LineEdit.history_keymap, LineEdit.default_keymap, LineEdit.escape_defaults]
    highlight_prompt.keymap_dict = LineEdit.keymap(b)


    highlight_prompt
end

function run_highlightREPL(; prompt = "fulia> ", name = :wat, key = '>')
    repl = Base.active_repl
    mirepl = isdefined(repl,:mi) ? repl.mi : repl
    main_mode = mirepl.interface.modes[1]

    highlight_prompt = create_highlightREPL(prompt=prompt, name=name, repl=repl)

    second_buffer = IOBuffer()

    # Install this mode into the main mode
    const hl_keymap = Dict{Any,Any}(
        key => function (s,args...)
            print("pressed $key")
            if isempty(s) || position(LineEdit.buffer(s)) == 0
                buf = copy(LineEdit.buffer(s))
                LineEdit.transition(s, highlight_prompt) do
                    LineEdit.state(s, highlight_prompt).input_buffer = buf
                end
            else
                LineEdit.edit_insert(s,key)
            end
        end
    )
    main_mode.keymap_dict = LineEdit.keymap_merge(hl_keymap, main_mode.keymap_dict);

    q = function (s, data, c)
            LineEdit.edit_insert(s, c)
            tokens = collect(Lexers.Lexer(LineEdit.buffer(s)))
            b = IOBuffer()
            apply_passes!(tokens)
            Base.Terminals.clear_line(LineEdit.terminal(s))
            #LineEdit.write_prompt(t, main_mode)
            untokenize_with_ANSI(b, tokens)
            write(LineEdit.terminal(s), takebuf_string(b))
        end

    println("injecting")
    main_mode.keymap_dict['\0'] = q
    nothing
end

end # module
