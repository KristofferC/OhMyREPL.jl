# Generated with:
#
#   $ julia --startup-file=no --trace-compile="out.jl"
#
# ..and then typing the below commands one by one,
# each time recording the new precompile statements here.
#
# Lines containing "fzf_jll" and "JLLWrappers" where manually commented out
# (they made precompiling OhMyREPL error).
#
# ..and the following import was added:

import REPL.Markdown


# After REPL startup:
precompile(Tuple{typeof(Base.check_open), Base.TTY})
precompile(Tuple{typeof(REPL.LineEdit.activate), REPL.LineEdit.TextInterface, REPL.LineEdit.MIState, REPL.Terminals.AbstractTerminal, REPL.Terminals.TextTerminal})
precompile(Tuple{typeof(REPL.LineEdit.refresh_multi_line), REPL.Terminals.UnixTerminal, Any})

# "using OhMyREPL<enter>"
# precompile(Tuple{typeof(fzf_jll.__init__)})
# precompile(Tuple{typeof(fzf_jll.find_artifact_dir)})
precompile(Tuple{typeof(Base.invokelatest), Any})
# precompile(Tuple{typeof(JLLWrappers.get_julia_libpaths)})
precompile(Tuple{typeof(OhMyREPL.__init__)})
precompile(Tuple{typeof(Base.getindex), Array{REPL.LineEdit.TextInterface, 1}, Int64})
precompile(Tuple{typeof(Base.getindex), Type{Base.Dict{Any, Any}}, Base.Dict{Any, Any}, Base.Dict{Char, Any}})
precompile(Tuple{typeof(REPL.LineEdit.refresh_multi_line), REPL.Terminals.TerminalBuffer, REPL.LineEdit.ModeState})

# Typing first character ("1")
precompile(Tuple{REPL.LineEdit.var"#25#26"{OhMyREPL.Prompt.var"#2#29", String}, Any, Any})
precompile(Tuple{Type{Crayons.Crayon}, Crayons.ANSIColor, Crayons.ANSIColor, Crayons.ANSIStyle, Crayons.ANSIStyle, Crayons.ANSIStyle, Crayons.ANSIStyle, Crayons.ANSIStyle, Crayons.ANSIStyle, Crayons.ANSIStyle, Crayons.ANSIStyle, Crayons.ANSIStyle})
precompile(Tuple{typeof(Base.convert), Type{Crayons.Crayon}, Crayons.Crayon})
precompile(Tuple{OhMyREPL.Prompt.var"#2#29", Any, Any, Any})
precompile(Tuple{typeof(Base.write), Base.IOContext{Base.GenericIOBuffer{Array{UInt8, 1}}}, String})
precompile(Tuple{typeof(Base.Unicode.textwidth), String})
precompile(Tuple{typeof(Base.unsafe_write), Base.IOContext{Base.GenericIOBuffer{Array{UInt8, 1}}}, Ptr{UInt8}, UInt64})
precompile(Tuple{Type{Tokenize.Tokens.Token}})
precompile(Tuple{typeof(Tokenize.Tokens.exactkind), Tokenize.Tokens.Token})
precompile(Tuple{typeof(Base.:(==)), Tokenize.Tokens.Kind, Tokenize.Tokens.Kind})
precompile(Tuple{typeof(Tokenize.Tokens.kind), Tokenize.Tokens.Token})
precompile(Tuple{OhMyREPL.Passes.SyntaxHighlighter.SyntaxHighlighterSettings, Array{Crayons.Crayon, 1}, Array{Tokenize.Tokens.Token, 1}, Int64})
precompile(Tuple{OhMyREPL.Passes.BracketHighlighter.BracketHighlighterSettings, Array{Crayons.Crayon, 1}, Array{Tokenize.Tokens.Token, 1}, Int64})
precompile(Tuple{OhMyREPL.Passes.RainbowBrackets.RainbowBracketsSettings, Array{Crayons.Crayon, 1}, Array{Tokenize.Tokens.Token, 1}, Int64})
precompile(Tuple{typeof(OhMyREPL.untokenize_with_ANSI), Base.IOContext{Base.GenericIOBuffer{Array{UInt8, 1}}}, OhMyREPL.PassHandler, Array{Tokenize.Tokens.Token, 1}, Int64})
precompile(Tuple{typeof(Base.position), Base.GenericIOBuffer{Array{UInt8, 1}}})
precompile(Tuple{typeof(Base.pipe_reader), REPL.Terminals.TTYTerminal})
precompile(Tuple{typeof(Base.seek), Base.GenericIOBuffer{Array{UInt8, 1}}, Int64})
precompile(Tuple{Base.var"#readline##kw", NamedTuple{(:keep,), Tuple{Bool}}, typeof(Base.readline), Base.GenericIOBuffer{Array{UInt8, 1}}})
precompile(Tuple{typeof(Base.divrem), Int64, Int64})
precompile(Tuple{typeof(Base.flush), REPL.Terminals.TTYTerminal})

# <enter>
precompile(Tuple{REPL.LineEdit.var"#25#26"{OhMyREPL.Prompt.var"#22#49", String}, Any, Any})
precompile(Tuple{OhMyREPL.Prompt.var"#22#49", Any, Any, Any})
precompile(Tuple{typeof(REPL.LineEdit.mode), REPL.LineEdit.MIState})
precompile(Tuple{typeof(REPL.LineEdit.state), REPL.LineEdit.MIState, REPL.LineEdit.TextInterface})
precompile(Tuple{typeof(Base.Multimedia.display), Any})
precompile(Tuple{typeof(Base.Multimedia.display), REPL.REPLDisplay{R} where R<:REPL.AbstractREPL, Any})
precompile(Tuple{typeof(Base.Multimedia.display), REPL.REPLDisplay{REPL.LineEditREPL}, Base.Multimedia.MIME{Symbol("text/plain")}, Int64})
precompile(Tuple{typeof(Base.write), Base.TTY, String, String})
precompile(Tuple{Type{Base.IOContext{IO_t} where IO_t<:IO}, Base.TTY, Pair{Symbol, Bool}})
precompile(Tuple{typeof(Base.println), Base.TTY})

# Pasting in `OhMyREPL.colorscheme!("OneLight")`
precompile(Tuple{REPL.LineEdit.var"#25#26"{OhMyREPL.BracketInserter.var"#1#8"{Array{Char, 1}, Char, Char}, String}, Any, Any})
precompile(Tuple{OhMyREPL.BracketInserter.var"#1#8"{Array{Char, 1}, Char, Char}, REPL.LineEdit.MIState, REPL.LineEditREPL, Vararg{Any}})
precompile(Tuple{REPL.LineEdit.var"#25#26"{OhMyREPL.BracketInserter.var"#5#12"{Char}, String}, Any, Any})
precompile(Tuple{OhMyREPL.BracketInserter.var"#5#12"{Char}, REPL.LineEdit.MIState, REPL.LineEditREPL, Vararg{Any}})
precompile(Tuple{REPL.LineEdit.var"#25#26"{OhMyREPL.BracketInserter.var"#2#9"{Char}, String}, Any, Any})
precompile(Tuple{OhMyREPL.BracketInserter.var"#2#9"{Char}, REPL.LineEdit.MIState, REPL.LineEditREPL, Vararg{Any}})

# <enter>  (which prints `KeyError: key "OneLight" not found`)
precompile(Tuple{typeof(OhMyREPL.colorscheme!), String})
precompile(Tuple{Type{Base.KeyError}, String})
precompile(Tuple{Type{NamedTuple{(:exception, :backtrace), T} where T<:Tuple}, Tuple{Base.KeyError, Array{Union{Ptr{Nothing}, Base.InterpreterIP}, 1}}})
precompile(Tuple{typeof(Base.getproperty), NamedTuple{(:exception, :backtrace), Tuple{Base.KeyError, Array{Union{Ptr{Nothing}, Base.InterpreterIP}, 1}}}, Symbol})
precompile(Tuple{Type{NamedTuple{(:exception, :backtrace), T} where T<:Tuple}, Tuple{Base.KeyError, Array{Base.StackTraces.StackFrame, 1}}})
precompile(Tuple{typeof(Base.getproperty), NamedTuple{(:exception, :backtrace), Tuple{Base.KeyError, Array{Base.StackTraces.StackFrame, 1}}}, Symbol})
precompile(Tuple{typeof(Base.indexed_iterate), NamedTuple{(:exception, :backtrace), Tuple{Base.KeyError, Array{Base.StackTraces.StackFrame, 1}}}, Int64})
precompile(Tuple{typeof(Base.indexed_iterate), NamedTuple{(:exception, :backtrace), Tuple{Base.KeyError, Array{Base.StackTraces.StackFrame, 1}}}, Int64, Int64})
precompile(Tuple{Base.var"#showerror##kw", NamedTuple{(:backtrace,), Tuple{Bool}}, typeof(Base.showerror), Base.IOContext{Base.TTY}, Base.KeyError, Array{Base.StackTraces.StackFrame, 1}})
precompile(Tuple{typeof(Base.show), Base.IOContext{Base.TTY}, String})
precompile(Tuple{typeof(Base.Filesystem.joinpath), Tuple{String, String, String, String, String, String, String, String}})

# typing "OhMyREPL.<tab>"
precompile(Tuple{REPL.LineEdit.var"#25#26"{OhMyREPL.Prompt.var"#25#52", String}, Any, Any})
precompile(Tuple{OhMyREPL.Prompt.var"#25#52", Any, Any, Any})
precompile(Tuple{typeof(REPL.REPLCompletions.get_value), Symbol, Module})
precompile(Tuple{typeof(Base.indexed_iterate), Tuple{Module, Bool}, Int64})
precompile(Tuple{typeof(Base.indexed_iterate), Tuple{Module, Bool}, Int64, Int64})
precompile(Tuple{typeof(Base.in), REPL.REPLCompletions.ModuleCompletion, Base.Set{REPL.REPLCompletions.Completion}})
precompile(Tuple{typeof(Base.push!), Base.Set{REPL.REPLCompletions.Completion}, REPL.REPLCompletions.ModuleCompletion})
precompile(Tuple{typeof(Base.Order.lt), Base.Order.By{typeof(REPL.REPLCompletions.completion_text), Base.Order.ForwardOrdering}, REPL.REPLCompletions.ModuleCompletion, REPL.REPLCompletions.ModuleCompletion})
precompile(Tuple{typeof(REPL.REPLCompletions.completion_text), REPL.REPLCompletions.ModuleCompletion})

# continuing: ."colorscheme!("OneDark")"
# <enter>
precompile(Tuple{Type{NamedTuple{(:foreground,), T} where T<:Tuple}, Tuple{Symbol}})
precompile(Tuple{typeof(Base.haskey), NamedTuple{(:foreground,), Tuple{Symbol}}, Symbol})
precompile(Tuple{typeof(Base.Multimedia.display), REPL.REPLDisplay{REPL.LineEditREPL}, Base.Multimedia.MIME{Symbol("text/plain")}, OhMyREPL.Passes.SyntaxHighlighter.ColorScheme})
precompile(Tuple{typeof(Base.show), Base.IOContext{Base.TTY}, Base.Multimedia.MIME{Symbol("text/plain")}, OhMyREPL.Passes.SyntaxHighlighter.ColorScheme})
precompile(Tuple{typeof(Base.print), Base.IOContext{Base.TTY}, UInt8})

# <up>
precompile(Tuple{REPL.LineEdit.var"#25#26"{OhMyREPL.Prompt.var"#55#57"{REPL.LineEdit.PrefixHistoryPrompt}, String}, Any, Any})
precompile(Tuple{OhMyREPL.Prompt.var"#55#57"{REPL.LineEdit.PrefixHistoryPrompt}, Any, Any, Vararg{Any}})
precompile(Tuple{typeof(Base.print), Base.IOContext{Base.GenericIOBuffer{Array{UInt8, 1}}}, UInt8})

# <home>
precompile(Tuple{REPL.LineEdit.var"#25#26"{OhMyREPL.Prompt.var"#10#37", String}, Any, Any})
precompile(Tuple{OhMyREPL.Prompt.var"#10#37", Any, Any, Any})

# type "?"
# <end>
precompile(Tuple{REPL.LineEdit.var"#25#26"{REPL.LineEdit.var"#147#201", String}, Any, Any})
precompile(Tuple{REPL.LineEdit.var"#147#201", REPL.LineEdit.MIState, Any, Vararg{Any}})

# <enter>
precompile(Tuple{REPL.var"#repl##kw", NamedTuple{(:brief,), Tuple{Bool}}, typeof(REPL.repl), Base.TTY, Expr})
precompile(Tuple{typeof(REPL.lookup_doc), Expr})
precompile(Tuple{typeof(Base.hash), Expr, UInt64})
precompile(Tuple{typeof(Base.hash), Any, UInt64})
precompile(Tuple{typeof(Base.hash), QuoteNode, UInt64})
precompile(Tuple{typeof(Base.hash), String, UInt64})
precompile(Tuple{typeof(Base.Docs.aliasof), Function, Any})
precompile(Tuple{typeof(REPL.summarize), Base.GenericIOBuffer{Array{UInt8, 1}}, Function, Base.Docs.Binding})
precompile(Tuple{typeof(Base.print), Base.GenericIOBuffer{Array{UInt8, 1}}, Base.MethodList})
precompile(Tuple{typeof(Base.string_with_env), Base.ImmutableDict{Symbol, Any}, Type})
precompile(Tuple{Base.var"#sprint##kw", NamedTuple{(:context,), Tuple{Base.ImmutableDict{Symbol, Any}}}, typeof(Base.sprint), Function, Type, Vararg{Any}})
precompile(Tuple{Base.var"##sprint#452", Base.ImmutableDict{Symbol, Any}, Int64, typeof(Base.sprint), Function, Type, Vararg{Any}})
precompile(Tuple{typeof(Base.show_signature_function), Base.IOContext{Base.GenericIOBuffer{Array{UInt8, 1}}}, Any, Bool, String, Bool})
precompile(Tuple{typeof(Base.Multimedia.display), REPL.REPLDisplay{REPL.LineEditREPL}, Base.Multimedia.MIME{Symbol("text/plain")}, Markdown.MD})
precompile(Tuple{Type{NamedTuple{(:raise,), T} where T<:Tuple}, Tuple{Bool}})
precompile(Tuple{typeof(Base.haskey), NamedTuple{(:raise,), Tuple{Bool}}, Symbol})
precompile(Tuple{Type{NamedTuple{(:foreground, :bold), T} where T<:Tuple}, Tuple{Symbol, Bool}})
precompile(Tuple{typeof(Base.haskey), NamedTuple{(:foreground, :bold), Tuple{Symbol, Bool}}, Symbol})
precompile(Tuple{Type{Crayons.ANSIStyle}, Bool})
precompile(Tuple{Type{NamedTuple{(:reset,), T} where T<:Tuple}, Tuple{Bool}})
precompile(Tuple{Core.var"#Type##kw", NamedTuple{(:reset,), Tuple{Bool}}, Type{Crayons.Crayon}})
precompile(Tuple{typeof(Markdown.term), Base.IOContext{Base.TTY}, Markdown.Code, Int64})
precompile(Tuple{typeof(Base.print), Base.GenericIOBuffer{Array{UInt8, 1}}, UInt8})

# Paste in `OhMyREPL.enable_autocomplete_brackets(true)`
# <enter>
precompile(Tuple{typeof(OhMyREPL.BracketInserter.enable_autocomplete_brackets), Bool})
precompile(Tuple{typeof(Base.Multimedia.display), REPL.REPLDisplay{REPL.LineEditREPL}, Base.Multimedia.MIME{Symbol("text/plain")}, Bool})

# Type "1", then <backspace>
precompile(Tuple{REPL.LineEdit.var"#25#26"{OhMyREPL.BracketInserter.var"#6#13"{Array{Char, 1}, Array{Char, 1}}, String}, Any, Any})
precompile(Tuple{OhMyREPL.BracketInserter.var"#6#13"{Array{Char, 1}, Array{Char, 1}}, REPL.LineEdit.MIState, REPL.LineEditREPL, String})

# Type "[", then <end><backspace><backspace>
precompile(Tuple{REPL.LineEdit.var"#25#26"{OhMyREPL.Prompt.var"#11#38", String}, Any, Any})
precompile(Tuple{OhMyREPL.Prompt.var"#11#38", Any, Any, Any})

# Type "OhMy<tab>"
precompile(Tuple{typeof(Base.incomplete_tag), Symbol})

# Type ."Passes.Rain<tab>"
precompile(Tuple{typeof(REPL.REPLCompletions.get_value), Module, Module})
precompile(Tuple{typeof(REPL.REPLCompletions.get_value), QuoteNode, Module})

# Continue (".activate_256colors()")
# <enter>
precompile(Tuple{typeof(OhMyREPL.Passes.RainbowBrackets.activate_256colors)})
precompile(Tuple{typeof(Base.Multimedia.display), REPL.REPLDisplay{REPL.LineEditREPL}, Base.Multimedia.MIME{Symbol("text/plain")}, OhMyREPL.Passes.RainbowBrackets.RainBowTokens})
precompile(Tuple{typeof(Base.show), Base.IOContext{Base.TTY}, Base.Multimedia.MIME{Symbol("text/plain")}, OhMyREPL.Passes.RainbowBrackets.RainBowTokens})
precompile(Tuple{typeof(Base.sizeof), OhMyREPL.Passes.RainbowBrackets.RainBowTokens})
precompile(Tuple{typeof(Base.length), Core.SimpleVector})
precompile(Tuple{typeof(Base.show), Base.IOContext{Base.TTY}, Array{Crayons.Crayon, 1}})

# "?Int<enter>"
precompile(Tuple{REPL.LineEdit.var"#25#26"{REPL.var"#67#70"{REPL.LineEdit.Prompt}, String}, Any, Any})
precompile(Tuple{REPL.var"#67#70"{REPL.LineEdit.Prompt}, REPL.LineEdit.MIState, Any, Vararg{Any}})
precompile(Tuple{typeof(Base._typed_vcat), Type{Symbol}, Tuple{Array{Symbol, 1}, Array{Symbol, 1}, Array{Symbol, 1}, Array{Symbol, 1}, Array{Symbol, 1}, Array{Symbol, 1}}})
precompile(Tuple{typeof(Base.Docs.aliasof), DataType, Any})
precompile(Tuple{typeof(Base.Docs.formatdoc), Base.GenericIOBuffer{Array{UInt8, 1}}, Base.Docs.DocStr, Int64})
precompile(Tuple{typeof(Base.vcat), Markdown.MD})

# "x = [1,2]<enter>"
precompile(Tuple{typeof(Base.Multimedia.display), REPL.REPLDisplay{REPL.LineEditREPL}, Base.Multimedia.MIME{Symbol("text/plain")}, Array{Int64, 1}})

# Type <up> a few times
precompile(Tuple{REPL.LineEdit.var"#25#26"{REPL.LineEdit.var"#242#250", String}, Any, Any})
precompile(Tuple{REPL.LineEdit.var"#242#250", REPL.LineEdit.MIState, REPL.LineEdit.ModeState, Any})

# <home>
precompile(Tuple{REPL.LineEdit.var"#25#26"{REPL.LineEdit.var"#146#200", String}, Any, Any})
precompile(Tuple{REPL.LineEdit.var"#146#200", REPL.LineEdit.MIState, Any, Vararg{Any}})

# <backspace>
precompile(Tuple{REPL.var"#68#71"{REPL.LineEdit.MIState, Base.GenericIOBuffer{Array{UInt8, 1}}, REPL.LineEdit.Prompt}})

# <ctrl>-<k> (empty line)
precompile(Tuple{REPL.LineEdit.var"#25#26"{REPL.LineEdit.var"#139#193", String}, Any, Any})
precompile(Tuple{REPL.LineEdit.var"#139#193", REPL.LineEdit.MIState, Any, Vararg{Any}})

# <ctrl>-<r> (fuzzy history search)
precompile(Tuple{REPL.LineEdit.var"#25#26"{REPL.LineEdit.var"#139#193", String}, Any, Any})
precompile(Tuple{REPL.LineEdit.var"#139#193", REPL.LineEdit.MIState, Any, Vararg{Any}})
precompile(Tuple{REPL.LineEdit.var"#25#26"{OhMyREPL.Prompt.var"#26#53", String}, Any, Any})
precompile(Tuple{typeof(Base.:(<)), UInt32, UInt32})
precompile(Tuple{typeof(Base.:(>)), UInt32, UInt32})
precompile(Tuple{typeof(Base.:(!=)), UInt32, UInt32})
precompile(Tuple{Type{Base.Broadcast.Broadcasted{Base.Broadcast.DefaultArrayStyle{0}, Nothing, typeof(Base.identity), Tuple{Int64}}}, Function, Tuple{Int64}, Nothing})
precompile(Tuple{typeof(Base.ntuple), Base.Returns{Base.OneTo{Int64}}, Base.Val{1}})
precompile(Tuple{Type{MethodError}, Any, Any, UInt64})
precompile(Tuple{Type{MethodError}, Any, Any})
precompile(Tuple{OhMyREPL.Prompt.var"#26#53", Any, Any, Any})
precompile(Tuple{typeof(Base.withenv), OhMyREPL.Prompt.var"#27#54"{REPL.LineEdit.MIState, Module}, Pair{String, Nothing}})
precompile(Tuple{typeof(JLFzf.read_repl_hist)})
precompile(Tuple{typeof(JLFzf.inter_fzf), Array{Base.SubString{String}, 1}, String, Vararg{String}})
precompile(Tuple{typeof(JLFzf.inter_fzf), String, String, Vararg{String}})
# precompile(Tuple{typeof(fzf_jll.fzf), Function})
# precompile(Tuple{fzf_jll.var"##fzf#3", Bool, Bool, typeof(fzf_jll.fzf), Function})
# precompile(Tuple{typeof(JLLWrappers.withenv_executable_wrapper), Function, String, String, String, Bool, Bool})
# precompile(Tuple{typeof(JLLWrappers.adjust_ENV!), Base.Dict{K, V} where V where K, String, String, Bool, Bool})
precompile(Tuple{typeof(Base.iterate), Base.Dict{String, String}})
precompile(Tuple{typeof(Base.iterate), Base.Dict{String, String}, Int64})
# precompile(Tuple{typeof(Base.withenv), JLLWrappers.var"#2#3"{JLFzf.var"#1#2"{String, Tuple{String, String, String, String}}, String}, Pair{String, String}})
# precompile(Tuple{JLLWrappers.var"#2#3"{JLFzf.var"#1#2"{String, Tuple{String, String, String, String}}, String}})
precompile(Tuple{typeof(Base.haskey), NamedTuple{(:ignorestatus,), Tuple{Bool}}, Symbol})
precompile(Tuple{JLFzf.var"#1#2"{String, Tuple{String, String, String, String}}, String})
precompile(Tuple{typeof(Base.arg_gen), Tuple{String, String, String, String}})
precompile(Tuple{typeof(Base.read), Base.PipeEndpoint})
precompile(Tuple{Base.var"#729#730"{Base.GenericIOBuffer{Array{UInt8, 1}}, Bool, Base.PipeEndpoint, Base.PipeEndpoint, Base.GenericIOBuffer{Array{UInt8, 1}}}})

# <up> a few times, then <enter>
precompile(Tuple{typeof(JLFzf.insert_history_to_repl), REPL.LineEdit.MIState, Base.SubString{String}})

# <ctrl>-<d> (to quit julia)
precompile(Tuple{REPL.LineEdit.var"#25#26"{OhMyREPL.Prompt.var"#21#48", String}, Any, Any})
precompile(Tuple{OhMyREPL.Prompt.var"#21#48", Any, Any, Any})
precompile(Tuple{typeof(Base.indexed_iterate), Tuple{Nothing, Int64}, Int64})
precompile(Tuple{typeof(Base.indexed_iterate), Tuple{Nothing, Int64}, Int64, Int64})
precompile(Tuple{REPL.var"#48#53"{REPL.REPLBackendRef}})
