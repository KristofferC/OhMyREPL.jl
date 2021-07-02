var documenterSearchIndex = {"docs":
[{"location":"features/rainbow_brackets/#Rainbow-Brackets","page":"Rainbow Brackets","title":"Rainbow Brackets","text":"","category":"section"},{"location":"features/rainbow_brackets/","page":"Rainbow Brackets","title":"Rainbow Brackets","text":"Rainbow brackets is a feature that colors matching brackets in the same color (with non matching closing brackets are showed in bold red):","category":"page"},{"location":"features/rainbow_brackets/","page":"Rainbow Brackets","title":"Rainbow Brackets","text":"(Image: rainbow brackets)","category":"page"},{"location":"features/rainbow_brackets/","page":"Rainbow Brackets","title":"Rainbow Brackets","text":"There are two modes of this pass, one that uses 256 colors and one that uses only the 16 system colors. By default, we default to using the 16 color mode on Windows and 256 color mode otherwise. Changing between the modes is done by:","category":"page"},{"location":"features/rainbow_brackets/","page":"Rainbow Brackets","title":"Rainbow Brackets","text":"OhMyREPL.Passes.RainbowBrackets.activate_16colors()\nOhMyREPL.Passes.RainbowBrackets.activate_256colors()","category":"page"},{"location":"features/rainbow_brackets/","page":"Rainbow Brackets","title":"Rainbow Brackets","text":"As with all different passes, this can be enabled or disabled with the function OhMyREPL.enable_pass!(\"RainbowBrackets\", enable::Bool) where enable determines wether if the pass is enabled or disabled.","category":"page"},{"location":"features/rainbow_brackets/","page":"Rainbow Brackets","title":"Rainbow Brackets","text":"Inspired by the VSCode plugin with the same name.","category":"page"},{"location":"features/bracket_complete/#Bracket-completion","page":"Bracket completion","title":"Bracket completion","text":"","category":"section"},{"location":"features/bracket_complete/","page":"Bracket completion","title":"Bracket completion","text":"Will insert a matching closing bracket to an opening bracket automatically if this is deemed likely to be desireable from the context of the surrounding text to the cursor. This is disabled by default on Windows because it interacts badly with pasting code with the default windows terminal.","category":"page"},{"location":"features/bracket_complete/","page":"Bracket completion","title":"Bracket completion","text":"(Image: )","category":"page"},{"location":"features/bracket_complete/#Settings","page":"Bracket completion","title":"Settings","text":"","category":"section"},{"location":"features/bracket_complete/","page":"Bracket completion","title":"Bracket completion","text":"Can be disabled or enabled with enable_autocomplete_brackets(::Bool).","category":"page"},{"location":"features/syntax_highlighting/#Syntax-highlighting","page":"Syntax highlighting","title":"Syntax highlighting","text":"","category":"section"},{"location":"features/syntax_highlighting/","page":"Syntax highlighting","title":"Syntax highlighting","text":"(Image: repl)","category":"page"},{"location":"features/syntax_highlighting/","page":"Syntax highlighting","title":"Syntax highlighting","text":"The Syntax highlighting pass transforms input text in the REPL to highlighted text, highlighting keyword, operators, symbols, strings etc. in different colors. There are a few color schemes that comes with OhMyREPL but it is fairly easy to create your own to your liking.","category":"page"},{"location":"features/syntax_highlighting/#Default-schemes","page":"Syntax highlighting","title":"Default schemes","text":"","category":"section"},{"location":"features/syntax_highlighting/","page":"Syntax highlighting","title":"Syntax highlighting","text":"The current default colorschemes that comes with OhMyREPL are","category":"page"},{"location":"features/syntax_highlighting/","page":"Syntax highlighting","title":"Syntax highlighting","text":"\"JuliaDefault\" - the default Julia scheme, white and bold.\n\"Monokai16\" - 16 color Monokai\n\"Monokai256\" - 256 colors Monokai\n\"Monokai24bit\" - 24 bit colored Monokai\n\"BoxyMonokai256\" - 256 colors Monokai from here\n\"TomorrowNightBright\" - 256 colors Tomorrow Night Bright\n\"TomorrowNightBright24bit\" - 24 bit colored Tomorrow Night Bright\n\"OneDark\" - 24 bit colored OneDark\n\"Base16MaterialDarker\" - 24-bit Base16 Material Darker color scheme by Nate Peters\n\"GruvboxDark\" - Dark-mode variation of the Gruvbox color scheme by Pavel Pertsev.","category":"page"},{"location":"features/syntax_highlighting/","page":"Syntax highlighting","title":"Syntax highlighting","text":"By default, \"Monokai16\" will be used on Windows and \"Monokai256\" otherwise. To test the supported colors in your terminal you can use Crayons.test_system_colors(), Crayons.test_256_colors(), Crayons.test_24bit_colors() to test 16, 256 and 24 bit colors respectively.","category":"page"},{"location":"features/syntax_highlighting/#Preview","page":"Syntax highlighting","title":"Preview","text":"","category":"section"},{"location":"features/syntax_highlighting/","page":"Syntax highlighting","title":"Syntax highlighting","text":"To see an example output of a colorscheme use test_colorscheme(name::String, [test_string::String]). If a test_string is not given, a default string will be used.","category":"page"},{"location":"features/syntax_highlighting/","page":"Syntax highlighting","title":"Syntax highlighting","text":"(Image: )","category":"page"},{"location":"features/syntax_highlighting/#Activate","page":"Syntax highlighting","title":"Activate","text":"","category":"section"},{"location":"features/syntax_highlighting/","page":"Syntax highlighting","title":"Syntax highlighting","text":"To activate a colorscheme use colorscheme!(name::String)","category":"page"},{"location":"features/syntax_highlighting/","page":"Syntax highlighting","title":"Syntax highlighting","text":"(Image: )","category":"page"},{"location":"features/syntax_highlighting/#Creating-your-own-colorschemes.","page":"Syntax highlighting","title":"Creating your own colorschemes.","text":"","category":"section"},{"location":"features/syntax_highlighting/","page":"Syntax highlighting","title":"Syntax highlighting","text":"This section will describe how to create your own colorscheme.","category":"page"},{"location":"features/syntax_highlighting/","page":"Syntax highlighting","title":"Syntax highlighting","text":"info: Info\nPlease refer to the Crayons.jl documentation while reading this section.","category":"page"},{"location":"features/syntax_highlighting/","page":"Syntax highlighting","title":"Syntax highlighting","text":"We start by loading the Crayons package and importing the SyntaxHighlighter and the ..","category":"page"},{"location":"features/syntax_highlighting/","page":"Syntax highlighting","title":"Syntax highlighting","text":"using Crayons\nimport OhMyREPL: Passes.SyntaxHighlighter","category":"page"},{"location":"features/syntax_highlighting/","page":"Syntax highlighting","title":"Syntax highlighting","text":"We now create a default colorscheme:","category":"page"},{"location":"features/syntax_highlighting/","page":"Syntax highlighting","title":"Syntax highlighting","text":"scheme = SyntaxHighlighter.ColorScheme()","category":"page"},{"location":"features/syntax_highlighting/","page":"Syntax highlighting","title":"Syntax highlighting","text":"By using the function test_colorscheme we can see that the default colorscheme simply prints everything in the default color:","category":"page"},{"location":"features/syntax_highlighting/","page":"Syntax highlighting","title":"Syntax highlighting","text":"(Image: )","category":"page"},{"location":"features/syntax_highlighting/","page":"Syntax highlighting","title":"Syntax highlighting","text":"There are a number of setter function that updates the colorscheme. They are called like setter!(cs::ColorScheme, crayon::Crayon). The different setters are:","category":"page"},{"location":"features/syntax_highlighting/","page":"Syntax highlighting","title":"Syntax highlighting","text":"symbol! - A symbol, ex :symbol\ncomment! - A comment, ex # comment, #= block comment =#\nstring! - A string or char, ex \"\"\"string\"\"\", 'a'\ncall! - A functionc all, ex foo()\nop! - An operator, ex *, √\nkeyword! - A keyword, ex function, begin, try\nfunction_def! - A function definition, ex function foo(x) x end\nerror! - An error in the Tokenizer, ex #= unending multi comment\nargdef! - Definition of a type, ex ::Float64\nmacro! - A macro, ex @time\nnumber! - A number, ex 100, 100_00.0, 0xf00\ntext! - Nothing of the above","category":"page"},{"location":"features/syntax_highlighting/","page":"Syntax highlighting","title":"Syntax highlighting","text":"Let us set the strings to be printed in yellow, numbers to be printed in bold, and function calls to be printed in cyan:","category":"page"},{"location":"features/syntax_highlighting/","page":"Syntax highlighting","title":"Syntax highlighting","text":"SyntaxHighlighter.string!(scheme, Crayon(foreground = :yellow))\nSyntaxHighlighter.number!(scheme, Crayon(bold = true))\nSyntaxHighlighter.call!(scheme, Crayon(foreground = :cyan))","category":"page"},{"location":"features/syntax_highlighting/","page":"Syntax highlighting","title":"Syntax highlighting","text":"info: Info\nRemember that you can also use integers for the foreground and background arguments to Crayon and they will then refer to the colors showed by Crayons.test_256_colors(). Also, you can of course specify many properties for the same Crayon.","category":"page"},{"location":"features/syntax_highlighting/","page":"Syntax highlighting","title":"Syntax highlighting","text":"By recalling test_colorscheme on the scheme we can see it has been updated:","category":"page"},{"location":"features/syntax_highlighting/","page":"Syntax highlighting","title":"Syntax highlighting","text":"(Image: )","category":"page"},{"location":"features/syntax_highlighting/","page":"Syntax highlighting","title":"Syntax highlighting","text":"By continuing in this fashion you can build up a full colorscheme. When you are satisfied with your colorscheme you can add it to the group of color schemes and activate it as:","category":"page"},{"location":"features/syntax_highlighting/","page":"Syntax highlighting","title":"Syntax highlighting","text":"(Image: )","category":"page"},{"location":"features/syntax_highlighting/","page":"Syntax highlighting","title":"Syntax highlighting","text":"You can look in the source code to see how the default color schemes are made.","category":"page"},{"location":"features/syntax_highlighting/","page":"Syntax highlighting","title":"Syntax highlighting","text":"For fun, the code below creates a truly random colorscheme:","category":"page"},{"location":"features/syntax_highlighting/","page":"Syntax highlighting","title":"Syntax highlighting","text":"function rand_token()\n    Crayon(background = rand(Bool) ? :nothing : rand(1:256),\n              foreground = rand(Bool) ? :nothing : rand(1:256),\n              bold = rand(Bool), italics = rand(Bool), underline = rand(Bool))\nend\n\nfunction create_random_colorscheme()\n    random = SyntaxHighlighter.ColorScheme()\n    SyntaxHighlighter.symbol!(random,rand_token())\n    SyntaxHighlighter.comment!(random, rand_token())\n    SyntaxHighlighter.string!(random, rand_token())\n    SyntaxHighlighter.call!(random, rand_token())\n    SyntaxHighlighter.op!(random, rand_token())\n    SyntaxHighlighter.keyword!(random, rand_token())\n    SyntaxHighlighter.macro!(random, rand_token())\n    SyntaxHighlighter.function_def!(random, rand_token())\n    SyntaxHighlighter.text!(random, rand_token())\n    SyntaxHighlighter.error!(random, rand_token())\n    SyntaxHighlighter.argdef!(random, rand_token())\n    SyntaxHighlighter.number!(random, rand_token())\n    return random\nend\n\ntest_colorscheme(create_random_colorscheme())","category":"page"},{"location":"features/syntax_highlighting/","page":"Syntax highlighting","title":"Syntax highlighting","text":"(Image: )","category":"page"},{"location":"features/markdown_highlight/#Markdown-Syntax-Highlighting","page":"Markdown Syntax Highlighting","title":"Markdown Syntax Highlighting","text":"","category":"section"},{"location":"features/markdown_highlight/","page":"Markdown Syntax Highlighting","title":"Markdown Syntax Highlighting","text":"(Image: )","category":"page"},{"location":"features/markdown_highlight/","page":"Markdown Syntax Highlighting","title":"Markdown Syntax Highlighting","text":"OhMyREPL will by default make code blocks written in markdown syntax (for example in docstrings) highlighted with the colorscheme used by the syntax highlighter.","category":"page"},{"location":"features/markdown_highlight/#Settings","page":"Markdown Syntax Highlighting","title":"Settings","text":"","category":"section"},{"location":"features/markdown_highlight/","page":"Markdown Syntax Highlighting","title":"Markdown Syntax Highlighting","text":"Can be disabled or enabled with enable_highlight_markdown(::Bool).","category":"page"},{"location":"features/prompt/#Prompt-changing","page":"Prompt changing","title":"Prompt changing","text":"","category":"section"},{"location":"features/prompt/","page":"Prompt changing","title":"Prompt changing","text":"The functions","category":"page"},{"location":"features/prompt/","page":"Prompt changing","title":"Prompt changing","text":"OhMyREPL.input_prompt!(str::Union{String, Function}, color::Symbol)\nOhMyREPL.output_prompt!(str::Union{String, Function}, color::Symbol)","category":"page"},{"location":"features/prompt/","page":"Prompt changing","title":"Prompt changing","text":"can be used to change the way that the input and output prompts are displayed.","category":"page"},{"location":"features/prompt/","page":"Prompt changing","title":"Prompt changing","text":"As an example, after running:","category":"page"},{"location":"features/prompt/","page":"Prompt changing","title":"Prompt changing","text":"OhMyREPL.input_prompt!(\">\", :magenta)\nOhMyREPL.output_prompt!(\">\", :red)","category":"page"},{"location":"features/prompt/","page":"Prompt changing","title":"Prompt changing","text":"(Image: )","category":"page"},{"location":"features/prompt/","page":"Prompt changing","title":"Prompt changing","text":"If the first argument instead is a function, it will be run every time the prompt wants to update which allows for more dynamic behavior.","category":"page"},{"location":"features/prompt/","page":"Prompt changing","title":"Prompt changing","text":"The different possible colors can be found by typing Base.text_colors in the Julia REPL's help mode.","category":"page"},{"location":"features/prompt/","page":"Prompt changing","title":"Prompt changing","text":"hint: Hint\nYou can use something like OhMyREPL.input_prompt!(string(VERSION) * \">\", :green) to show which version of Julia you are currently running.(Image: )","category":"page"},{"location":"internals/passes/#Passes","page":"Passes","title":"Passes","text":"","category":"section"},{"location":"internals/passes/","page":"Passes","title":"Passes","text":"In OhMyREPL each plugin that changes the way text is printed to the REPL is implemented as a pass. A pass is defined as a function (or a call overloaded type) that takes a list of Julia tokens from Tokenize.jl, a list of Crayons from Crayons.jl, the position of the cursor and sets the Crayons to however the pass wants the Julia tokens to be printed. Both the Syntax highlighting and the Bracket highlighting are implemented as passses.","category":"page"},{"location":"internals/passes/","page":"Passes","title":"Passes","text":"All the passes are registered in a global pass handler. To show all the passes use OhMyREPL.showpasses():","category":"page"},{"location":"internals/passes/","page":"Passes","title":"Passes","text":"julia> OhMyREPL.showpasses()\n----------------------------------\n #   Pass name             Enabled  \n----------------------------------\n 1   BracketHighlighter    true     \n 2   SyntaxHighlighter     true     \n----------------------------------","category":"page"},{"location":"internals/passes/","page":"Passes","title":"Passes","text":"A pass can be enabled or disabled at will with OhMyREPL.enable_pass!(pass_name::String, enabled::Bool). As an example, we disable the syntax highlighting:","category":"page"},{"location":"internals/passes/","page":"Passes","title":"Passes","text":"(Image: )","category":"page"},{"location":"internals/passes/#How-a-pass-works","page":"Passes","title":"How a pass works","text":"","category":"section"},{"location":"internals/passes/","page":"Passes","title":"Passes","text":"This section shows how text from the REPL get transformed into syntax highlighted text. The sample text used is:","category":"page"},{"location":"internals/passes/","page":"Passes","title":"Passes","text":"str = \"function f(x::Float64) return :x + 'a' end\"","category":"page"},{"location":"internals/passes/","page":"Passes","title":"Passes","text":"First the text is tokenized with Tokenize.jl:","category":"page"},{"location":"internals/passes/","page":"Passes","title":"Passes","text":"julia> using Tokenize\n\njulia> tokens = collect(Tokenize.tokenize(str))\n20-element Array{Tokenize.Tokens.Token,1}:\n  1,1-1,8:          KEYWORD           \"function\"\n  1,9-1,9:          WHITESPACE        \" \"       \n  1,10-1,10:        IDENTIFIER        \"f\"       \n  1,11-1,11:        LPAREN            \"(\"       \n  1,12-1,12:        IDENTIFIER        \"x\"       \n  1,13-1,14:        OP                \"::\"      \n  1,15-1,21:        IDENTIFIER        \"Float64\"\n  1,22-1,22:        RPAREN            \")\"       \n  1,23-1,23:        WHITESPACE        \" \"       \n  1,24-1,29:        KEYWORD           \"return\"  \n  1,30-1,30:        WHITESPACE        \" \"       \n  1,31-1,31:        OP                \":\"       \n  1,32-1,32:        IDENTIFIER        \"x\"       \n  1,33-1,33:        WHITESPACE        \" \"       \n  1,34-1,34:        OP                \"+\"       \n  1,35-1,35:        WHITESPACE        \" \"       \n  1,36-1,38:        CHAR              \"'a'\"     \n  1,39-1,39:        WHITESPACE        \" \"       \n  1,40-1,42:        KEYWORD           \"end\"     \n  1,43-1,42:        ENDMARKER         \"\"","category":"page"},{"location":"internals/passes/","page":"Passes","title":"Passes","text":"A vector of Crayons of the same length as the Julia tokens is then created and filled  with empty tokens.","category":"page"},{"location":"internals/passes/","page":"Passes","title":"Passes","text":"crayons = Vector{Crayon}(length(tokens));\nfill!(crayons, Crayon()) # Crayon is a bits type so this is OK","category":"page"},{"location":"internals/passes/","page":"Passes","title":"Passes","text":"These two vectors are then sent to the syntax highlighter pass together with an integer that represent what character offset the cursor currently is located. The syntax highlighter does not use this information but the bracket highlighter does.","category":"page"},{"location":"internals/passes/","page":"Passes","title":"Passes","text":"OhMyREPL.Passes.SyntaxHighlighter.SYNTAX_HIGHLIGHTER_SETTINGS(crayons, tokens, 0)","category":"page"},{"location":"internals/passes/","page":"Passes","title":"Passes","text":"Running this function has the effect of updating the crayons vector. If we print this vector we see that they have been updated:","category":"page"},{"location":"internals/passes/","page":"Passes","title":"Passes","text":"(Image: )","category":"page"},{"location":"internals/passes/","page":"Passes","title":"Passes","text":"To print the original string with the updated vector of Crayons we use the OhMyREPL.untokenize_with_ANSI([io::IO], crayons, tokens) function as:","category":"page"},{"location":"internals/passes/","page":"Passes","title":"Passes","text":"(Image: )","category":"page"},{"location":"internals/passes/","page":"Passes","title":"Passes","text":"Each registered and enabled pass does this updating and the contributions from each pass to the Crayon vector is merged in to a separate vector. After each pass is done, the result is printed to the REPL.","category":"page"},{"location":"internals/passes/#Creating-a-pass","page":"Passes","title":"Creating a pass","text":"","category":"section"},{"location":"internals/passes/","page":"Passes","title":"Passes","text":"This section shows how to create a very pass that let the user define a Crayon for each typeassertion / declaration that happens to be a Float64.","category":"page"},{"location":"internals/passes/","page":"Passes","title":"Passes","text":"info: Info\nPlease refer to the Tokenize.jl API section and the  Crayons.jl documentation while reading this section.","category":"page"},{"location":"internals/passes/","page":"Passes","title":"Passes","text":"We start off with a few imports and creating a new struct which will hold the setting for the pass:","category":"page"},{"location":"internals/passes/","page":"Passes","title":"Passes","text":"using Crayons\nimport Tokenize.Tokens: Token, untokenize, exactkind\nusing OhMyREPL\n\nmutable struct Float64Modifier\n    crayon::Crayon\nend\n\n# Default it the underlined red:\nconst FLOAT64_MODIFIER = Float64Modifier(Crayon(foreground = :red, underline= true))","category":"page"},{"location":"internals/passes/","page":"Passes","title":"Passes","text":"We then use call overloading to define a function for the type. The function will update the Crayon if the previous token was a :: operator and that the current token is a Float64 identifier, as in ::Float64.","category":"page"},{"location":"internals/passes/","page":"Passes","title":"Passes","text":"# The pass function, the cursor position is not used but it needs to be given an argument\nfunction (float64modifier::Float64Modifier)(crayons::Vector{Crayon}, tokens::Vector{Token}, cursorpos::Int)\n    # Loop over all tokens and crayons\n    for i in 1:length(crayons)\n        if untokenize(tokens[i]) == \"Float64\"\n            if i > 1 && exactkind(tokens[i-1]) == Tokenize.Tokens.DECLARATION\n                # Update the crayon\n                crayons[i] = float64modifier.crayon\n            end\n        end\n    end\nend","category":"page"},{"location":"internals/passes/#Testing-the-pass","page":"Passes","title":"Testing the pass","text":"","category":"section"},{"location":"internals/passes/","page":"Passes","title":"Passes","text":"A pass can be tested with the OhMyREPL.test_pass([io::IO], pass, str::String) where str is a test string to test the pass on:","category":"page"},{"location":"internals/passes/","page":"Passes","title":"Passes","text":"(Image: )","category":"page"},{"location":"internals/passes/#Register-the-pass","page":"Passes","title":"Register the pass","text":"","category":"section"},{"location":"internals/passes/","page":"Passes","title":"Passes","text":"To register and start using the pass simply use OhMyREPL.add_pass!(passname::String, pass):","category":"page"},{"location":"internals/passes/","page":"Passes","title":"Passes","text":"julia> OhMyREPL.add_pass!(\"Redify Float64\", FLOAT64_MODIFIER)\n----------------------------------\n #   Pass name             Enabled  \n----------------------------------\n 1   Redify Float64        true     \n 2   BracketHighlighter    true     \n 3   SyntaxHighlighter     true     \n----------------------------------","category":"page"},{"location":"internals/passes/","page":"Passes","title":"Passes","text":"We can now try it out together with the other passes by writing some syntax that includes ::Float64:","category":"page"},{"location":"internals/passes/","page":"Passes","title":"Passes","text":"(Image: )","category":"page"},{"location":"internals/passes/#Modify-prescedence-of-registered-passes","page":"Passes","title":"Modify prescedence of registered passes","text":"","category":"section"},{"location":"internals/passes/","page":"Passes","title":"Passes","text":"We actually have a conflict now because both the syntax highlighter and the newly added pass will try to modify the properties of the printed Float64 token. This is where the prescedence of each pass come in. The order of each pass is executed from bottom up in the list given by OhMyREPL.show_passes(). As can be see above, the new pass has the highest prescedence which is why the color of Float64 is actually red.","category":"page"},{"location":"internals/passes/","page":"Passes","title":"Passes","text":"The prescedence of a pass can be modified with the OhMyREPL.prescedence!(pass::Union{String, Int}, prescedence::Int). The variable pass here is either the name of the pass or its number as given by OhMyREPL.show_passes(). We now set the prescedence of the new pass to 3:","category":"page"},{"location":"internals/passes/","page":"Passes","title":"Passes","text":"julia> OhMyREPL.prescedence!(\"Redify Float64\", 3)\n----------------------------------\n #   Pass name             Enabled  \n----------------------------------\n 1   BracketHighlighter    true     \n 2   SyntaxHighlighter     true     \n 3   Redify Float64        true     \n----------------------------------","category":"page"},{"location":"internals/passes/","page":"Passes","title":"Passes","text":"Rewriting the same string in the REPL as above we now get:","category":"page"},{"location":"internals/passes/","page":"Passes","title":"Passes","text":"(Image: )","category":"page"},{"location":"internals/passes/","page":"Passes","title":"Passes","text":"The foreground color of Float64 is now determined by the Syntax highlighter pass. Note that the syntax highlighter does not touch the underlining so that one is still kept from the new pass.","category":"page"},{"location":"installation/#Installation","page":"Installation","title":"Installation","text":"","category":"section"},{"location":"installation/","page":"Installation","title":"Installation","text":"The package is registered in the General registry so it is easily installed by","category":"page"},{"location":"installation/","page":"Installation","title":"Installation","text":"import Pkg; Pkg.add(\"OhMyREPL\")","category":"page"},{"location":"installation/#Automatically-start-with-Julia.","page":"Installation","title":"Automatically start with Julia.","text":"","category":"section"},{"location":"installation/","page":"Installation","title":"Installation","text":"One way of automatically starting the package with Julia is by putting","category":"page"},{"location":"installation/","page":"Installation","title":"Installation","text":"atreplinit() do repl\n    try\n        @eval using OhMyREPL\n    catch e\n        @warn \"error while importing OhMyREPL\" e\n    end\nend","category":"page"},{"location":"installation/","page":"Installation","title":"Installation","text":"in your .julia/config/startup.jl file. Create this file (and directory) if it is not already there.","category":"page"},{"location":"installation/","page":"Installation","title":"Installation","text":"You can also compile OhMyREPL into the Julia system image. This will mean that there is no need to edit your .juliarc file and the Julia REPL will start a bit quicker since it does not have to parse and compile the package when it is loaded. The way to do this is by using PackageCompiler.jl.","category":"page"},{"location":"features/fzf/#Fuzzy-REPL-history-search","page":"Fuzzy REPL history search","title":"Fuzzy REPL history search","text":"","category":"section"},{"location":"features/fzf/","page":"Fuzzy REPL history search","title":"Fuzzy REPL history search","text":"(Image: )","category":"page"},{"location":"features/fzf/","page":"Fuzzy REPL history search","title":"Fuzzy REPL history search","text":"By default (on Julia 1.3+), OhMyREPL will use fzf to search in the REPL history (initiated by pressing Ctrl-R). This is a fuzzy searcher which means that you don't need to verbatim enter what you want to match. So if you wrote @eval Base foo(x) = x+1 at some time you can search for e.g. @eval foo to find it.","category":"page"},{"location":"features/fzf/","page":"Fuzzy REPL history search","title":"Fuzzy REPL history search","text":"This feature can be turned on/off using enable_fzf(::Bool).","category":"page"},{"location":"#OhMyREPL","page":"Home","title":"OhMyREPL","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"This is my REPL. There are many like it, but this one is mine.","category":"page"},{"location":"","page":"Home","title":"Home","text":"This is the documentation for OhMyREPL; a Julia package that hooks into the Julia REPL and gives it new features.","category":"page"},{"location":"","page":"Home","title":"Home","text":"(Image: repl)","category":"page"},{"location":"","page":"Home","title":"Home","text":"A video showing installation and features of the package is available here but note that a few things (including the name of the package) has changed since the video was made.","category":"page"},{"location":"#Manual-Outline","page":"Home","title":"Manual Outline","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Pages = [\n    \"installation.md\",\n    \"features/syntax_highlighting.md\",\n    \"features/bracket_highlighting.md\",\n    \"features/bracket_complete.md\",\n    \"features/rainbow_brackets.md\",\n    \"features/markdown_highlight.md\",\n    \"features/fzf.md\",\n    \"internals/passes.md\"\n]\nDepth = 1","category":"page"},{"location":"features/bracket_highlighting/#Bracket-highlighting","page":"Bracket highlighting","title":"Bracket highlighting","text":"","category":"section"},{"location":"features/bracket_highlighting/","page":"Bracket highlighting","title":"Bracket highlighting","text":"(Image: )","category":"page"},{"location":"features/bracket_highlighting/","page":"Bracket highlighting","title":"Bracket highlighting","text":"Makes matching brackets highlighted when the cursor is between an opening and closing bracket.","category":"page"},{"location":"features/bracket_highlighting/#Settings","page":"Bracket highlighting","title":"Settings","text":"","category":"section"},{"location":"features/bracket_highlighting/","page":"Bracket highlighting","title":"Bracket highlighting","text":"info: Info\nPlease refer to the Crayons.jl documentation while reading this section.","category":"page"},{"location":"features/bracket_highlighting/","page":"Bracket highlighting","title":"Bracket highlighting","text":"It is possbile to change the way the highlighted bracket is printed with the function","category":"page"},{"location":"features/bracket_highlighting/","page":"Bracket highlighting","title":"Bracket highlighting","text":"OhMyREPL.Passes.BracketHighlighter.setcrayon!(::Crayon)","category":"page"},{"location":"features/bracket_highlighting/","page":"Bracket highlighting","title":"Bracket highlighting","text":"(Image: )","category":"page"}]
}
