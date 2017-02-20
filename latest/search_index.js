var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#OhMyREPL-1",
    "page": "Home",
    "title": "OhMyREPL",
    "category": "section",
    "text": "This is my REPL. There are many like it, but this one is mine.This is the documentation for OhMyREPL; a Julia package that hooks into the Julia REPL and gives it new features.(Image: repl)A video showing installation and features of the package is available here but note that a few things (including the name of the package) has changed since the video was made."
},

{
    "location": "index.html#Manual-Outline-1",
    "page": "Home",
    "title": "Manual Outline",
    "category": "section",
    "text": "Pages = [\n    \"installation.md\",\n    \"features/syntax_highlighting.md\",\n    \"features/bracket_highlighting.md\",\n    \"features/prompt_pasting.md\",\n    \"features/error_messages.md\",\n    \"features/bracket_complete.md\",\n    \"internals/ansitoken.md\",\n    \"internals/passes.md\"\n]\nDepth = 1"
},

{
    "location": "installation.html#",
    "page": "Installation",
    "title": "Installation",
    "category": "page",
    "text": ""
},

{
    "location": "installation.html#Installation-1",
    "page": "Installation",
    "title": "Installation",
    "category": "section",
    "text": "Since the package is currently not registered Pkg.clone need to be used on this package and its dependencies.Pkg.clone(\"https://github.com/KristofferC/Tokenize.jl\")\nPkg.clone(\"https://github.com/KristofferC/OhMyREPL.jl\")"
},

{
    "location": "installation.html#Automatically-start-with-Julia.-1",
    "page": "Installation",
    "title": "Automatically start with Julia.",
    "category": "section",
    "text": "One way of automatically starting the package with Julia is by puttingif isdir(Pkg.dir(\"OhMyREPL\"))\n    @eval using OhMyREPL\nelse\n    warn(\"OhMyREPL not installed\")\nendin your .juliarc.jl file.You can also compile OhMyREPL into the Julia system image. This will mean that there is no need to edit your .juliarc file and the Julia REPL will start a bit quicker since it does not have to parse and compile the package when it is loaded. The way to do this is described in the Julia manual but is also summarized here:Create a userimg.jl file that contains Base.require(:OhMyREPL).\nRun include(joinpath(JULIA_HOME, Base.DATAROOTDIR, \"julia\", \"build_sysimg.jl\"))\nRun build_sysimg(default_sysimg_path(), \"native\", USERIMGPATH; force=true) where USERIMGPATH is the path to the userimg.jl file.If you are building Julia from source, the userimg.jl file can just be moved to the Base folder and then run make like normal.Note that you will have to redo this process if OhMyREPL is updated."
},

{
    "location": "features/syntax_highlighting.html#",
    "page": "Syntax highlighting",
    "title": "Syntax highlighting",
    "category": "page",
    "text": ""
},

{
    "location": "features/syntax_highlighting.html#Syntax-highlighting-1",
    "page": "Syntax highlighting",
    "title": "Syntax highlighting",
    "category": "section",
    "text": "(Image: repl)The Syntax highlighting pass transforms input text in the REPL to highlighted text, highlighting keyword, operators, symbols, strings etc. in different colors. There are a few color schemes that comes with OhMyREPL but it is fairly easy to create your own to your liking."
},

{
    "location": "features/syntax_highlighting.html#Default-schemes-1",
    "page": "Syntax highlighting",
    "title": "Default schemes",
    "category": "section",
    "text": "The current default colorschemes that comes with OhMyREPL are\"JuliaDefault\" - the default Julia scheme, white and bold.\n\"Monokai16\" - 16 color Monokai\n\"Monokai256\" - 256 colors Monokai\n\"BoxyMonokai256\" - 256 colors Monokai from hereBy default, \"Monokai16\" will be used on Windows and \"Monokai256\" otherwise. To test the supported colors in your terminal you can use OhMyREPL.ANSICodes.test_ANSI() and OhMyREPL.ANSICodes.test_ANSI_256() to test 16 and 256 colors respectively."
},

{
    "location": "features/syntax_highlighting.html#Preview-1",
    "page": "Syntax highlighting",
    "title": "Preview",
    "category": "section",
    "text": "To see an example output of a colorscheme use test_colorscheme(name::String, [test_string::String]). If a test_string is not given, a default string will be used.(Image: )"
},

{
    "location": "features/syntax_highlighting.html#Activate-1",
    "page": "Syntax highlighting",
    "title": "Activate",
    "category": "section",
    "text": "To activate a colorscheme use colorscheme!(name::String)(Image: )"
},

{
    "location": "features/syntax_highlighting.html#Creating-your-own-colorschemes.-1",
    "page": "Syntax highlighting",
    "title": "Creating your own colorschemes.",
    "category": "section",
    "text": "This section will describe how to create your own colorscheme.info: Info\nPlease refer to the ANSIToken section while reading this section.We start by importing the SyntaxHighlighter module and the ANSIToken type.import OhMyREPL: Passes.SyntaxHighlighter, ANSICodes.ANSITokenWe now create a default colorscheme:scheme = SyntaxHighlighter.ColorScheme()By using the function test_colorscheme we can see that the default colorscheme simply prints everything in the default color:(Image: )There are a number of setter function that updates the colorscheme. They are called like setter!(cs::ColorScheme, token::ANSIToken). The different setters are:symbol! - A symbol, ex :symbol\ncomment! - A comment, ex # comment, #= block comment =#\nstring! - A string or char, ex \"\"\"string\"\"\", 'a'\ncall! - A functionc all, ex foo()\nop! - An operator, ex *, √\nkeyword! - A keyword, ex function, begin, try\nfunction_def! - A function definition, ex function foo(x) x end\nerror! - An error in the Tokenizer, ex #= unending multi comment\nargdef! - Definition of a type, ex ::Float64\nmacro! - A macro, ex @time\nnumber! - A number, ex 100, 100_00.0, 0xf00\ntext! - Nothing of the aboveLet us set the strings to be printed in yellow, numbers to be printed in bold, and function calls to be printed in cyan:SyntaxHighlighter.string!(scheme, ANSIToken(foreground = :yellow))\nSyntaxHighlighter.number!(scheme, ANSIToken(bold = true))\nSyntaxHighlighter.call!(scheme, ANSIToken(foreground = :cyan))info: Info\nRemember that you can also use integers for the foreground and background arguments to ANSIToken and they will then refer to the colors showed by OhMyREPL.ANSICodes.test_ANSI_256(). You can of course also specify many properties for the same ANSIToken.By recalling test_colorscheme on the scheme we can see it has been updated:(Image: )By continuing in this fashion you can build up a full colorscheme. When you are satisfied with your colorscheme you can add it to the group of color schemes and activate it as:(Image: )You can look in the source code to see how the default color schemes are made.For fun, the code below creates a truly random colorscheme:function rand_token()\n    ANSIToken(background = rand(1:256), foreground = rand(1:256),\n              bold = rand(Bool), italics = rand(Bool), underline = rand(Bool))\nend\n\nfunction create_random_colorscheme()\n    random = SyntaxHighlighter.ColorScheme()\n    SyntaxHighlighter.symbol!(random,rand_token())\n    SyntaxHighlighter.comment!(random, rand_token())\n    SyntaxHighlighter.string!(random, rand_token())\n    SyntaxHighlighter.call!(random, rand_token())\n    SyntaxHighlighter.op!(random, rand_token())\n    SyntaxHighlighter.keyword!(random, rand_token())\n    SyntaxHighlighter.macro!(random, rand_token())\n    SyntaxHighlighter.function_def!(random, rand_token())\n    SyntaxHighlighter.text!(random, rand_token())\n    SyntaxHighlighter.error!(random, rand_token())\n    SyntaxHighlighter.argdef!(random, rand_token())\n    SyntaxHighlighter.number!(random, rand_token())\n    return random\nend\n\ntest_colorscheme(create_random_colorscheme())(Image: )"
},

{
    "location": "features/bracket_highlighting.html#",
    "page": "Bracket highlighting",
    "title": "Bracket highlighting",
    "category": "page",
    "text": ""
},

{
    "location": "features/bracket_highlighting.html#Bracket-highlighting-1",
    "page": "Bracket highlighting",
    "title": "Bracket highlighting",
    "category": "section",
    "text": "(Image: )Makes matching brackets highlighted when the cursor is between an opening and closing bracket."
},

{
    "location": "features/bracket_highlighting.html#Settings-1",
    "page": "Bracket highlighting",
    "title": "Settings",
    "category": "section",
    "text": "info: Info\nPlease refer to the ANSIToken section while reading this section.It is possbile to change the way the highlighted bracket is printed with the functionOhMyREPL.Passes.BracketHighlighting.set_token!(::ANSIToken)(Image: )"
},

{
    "location": "features/prompt_pasting.html#",
    "page": "Prompt pasting",
    "title": "Prompt pasting",
    "category": "page",
    "text": ""
},

{
    "location": "features/prompt_pasting.html#Prompt-pasting-1",
    "page": "Prompt pasting",
    "title": "Prompt pasting",
    "category": "section",
    "text": "If a pasted statement starts with julia> any statement beginning with julia> will have that part removed before getting parsed and any other statement will also be removed. This makes easy to paste what others have copied from their REPL without the need to remove any prompts or output.You can try it out by copying and pasting the below straight into the REPL.julia> 1 + 1\n2\n\njulia> str = \"\"\" this\n       is\n       a\n       string \"\"\"\n\" this\\nis\\na\\nstring \"\n\njulia> @time rand(3)\n  0.000003 seconds (6 allocations: 288 bytes)\n3-element Array{Float64,1}:\n 0.560418\n 0.883501\n 0.27273warning: Warning\nThis feature does not work on the standard Windows command prompt.note: Note\nPrompt pasting has been upstreamed to Julia v0.6."
},

{
    "location": "features/error_messages.html#",
    "page": "Error Messages",
    "title": "Error Messages",
    "category": "page",
    "text": ""
},

{
    "location": "features/error_messages.html#Error-Messages-1",
    "page": "Error Messages",
    "title": "Error Messages",
    "category": "section",
    "text": "warn: Warn\nThis feature only works on Julia v0.5 and currently v0.6 master. Due to rapid changes of the master branch, stability on v0.6 can not be guaranteed.OhMyREPL provides what can be argued to be a bit nicer error messages than Julia's default ones.The difference between the standard error messages and the ones from OhMyREPL is shown below:"
},

{
    "location": "features/error_messages.html#Default-error-message-1",
    "page": "Error Messages",
    "title": "Default error message",
    "category": "section",
    "text": "(Image: )"
},

{
    "location": "features/error_messages.html#OhMyREPL-error-message-1",
    "page": "Error Messages",
    "title": "OhMyREPL error message",
    "category": "section",
    "text": "(Image: )The differences between the two are:Stack trace in OhMyREPL is printed in reverse. This makes the top stack frame which is the one that is likely most interesting be closest to the cursor and will prevent the need to scroll to it for long traces.\nThe actual error message is in the bottom.\nInstead of everything being in bold red the color and boldness is varied to try to highlight the information that is likely to be more important.\nEach stack frame has a number. By entering the number in the REPL and then pressing <CTRL + Q> the editor will open at the file and line number of that stack frame. For this to work, set the \"EDITOR\" environment variable, for example ENV[\"EDITOR\"] = subl for Sublime Text on linux."
},

{
    "location": "features/error_messages.html#Settings-1",
    "page": "Error Messages",
    "title": "Settings",
    "category": "section",
    "text": "There are a few environment variables that can be set to change the way the error messages are printed.\"JULIA_ERR_LINFO_COLOR\" can be set to one of the symbols in Base.text_colors and determines how the file name and line number is printed.\n\"JULIA_ERR_FUNCDEF_COLOR\" can be set to one of the symbols in Base.text_colors and determines how function name is printed.\n\"JULIA_ERR_LINFO_NEWLINE can be set to true or false and determines if the line info should be printed on a new line.(Image: )"
},

{
    "location": "features/bracket_complete.html#",
    "page": "Bracket completion",
    "title": "Bracket completion",
    "category": "page",
    "text": ""
},

{
    "location": "features/bracket_complete.html#Bracket-completion-1",
    "page": "Bracket completion",
    "title": "Bracket completion",
    "category": "section",
    "text": "Will insert a matching closing bracket to an opening bracket automatically if this is deemed likely to be desireable from the context of the surrounding text to the cursor. (Image: )"
},

{
    "location": "features/bracket_complete.html#Settings-1",
    "page": "Bracket completion",
    "title": "Settings",
    "category": "section",
    "text": "Can be disabled or enabled with enable_autocomplete_brackets(::Bool)."
},

{
    "location": "features/prompt.html#",
    "page": "Prompt changing",
    "title": "Prompt changing",
    "category": "page",
    "text": ""
},

{
    "location": "features/prompt.html#Prompt-changing-1",
    "page": "Prompt changing",
    "title": "Prompt changing",
    "category": "section",
    "text": "The functionsOhMyREPL.input_prompt!(str::String, color::Symbol)\nOhMyREPL.output_prompt!(str::String, color::Symbol)can be used to change the way that the input and output prompts are displayed.As an example, after running:OhMyREPL.input_prompt!(\">\", :blue)\nOhMyREPL.output_prompt!(\">\", :red)(Image: )The different possible colors can be found by typing Base.text_colors in the Julia REPL's help mode.hint: Hint\nYou can use something like OhMyREPL.input_prompt!(string(VERSION) * \">\", :green) to show which version of Julia you are currently running.(Image: )"
},

{
    "location": "internals/ansitoken.html#",
    "page": "ANSIToken",
    "title": "ANSIToken",
    "category": "page",
    "text": ""
},

{
    "location": "internals/ansitoken.html#ANSIToken-1",
    "page": "ANSIToken",
    "title": "ANSIToken",
    "category": "section",
    "text": "note: Note\nSome reading of how colors and text styles are printed in a terminal might be good before reading this section, see the Wiki article and this linkThe ANSIToken type defined in the exported ANSICodes module is the object that makes the text from OhMyREPL gets it color and bold / italics."
},

{
    "location": "internals/ansitoken.html#Creating-an-ANSIToken-1",
    "page": "ANSIToken",
    "title": "Creating an ANSIToken",
    "category": "section",
    "text": "Creation of an ANSIToken is done with the constructor:ANSIToken(;foreground, background, bold, italics, underline)The types of  the foreground and background keywords can either be a Symbol or an Int.The different possible symbols are: :default, :black, :red, :green, :yellow, :blue, :magenta, :cyan, :light_gray, :dark_gray, :light_red, :light_green, :light_yellow, :light_blue, :light_magenta, :light_cyan, :white.Too see how these colors look in your terminal there is the ANSICodes.test_ANSI() function.In case the argument type is an integer it should be between 0 and 256. To see what color each number represent there is the ANSICodes.test_ANSI_256() function.note: Note\nNot all terminals support the 256 color version, for example the default Windows command prompt does not. On Windows you can install for example mintty which has better color support. On other OS's consult Google for how to enable 256 color support for the terminal.If you want to convert between RGB hex codes and the 256 color codes the script at this link is quite useful.The keyword arguments bold, italics,  and underline are simply bools representing if the text should have that attribute.An ANSIToken can be show-ed which will print the ANSI code of it in the style that successive text will be printed in.(Image: )"
},

{
    "location": "internals/ansitoken.html#Using-an-ANSIToken-1",
    "page": "ANSIToken",
    "title": "Using an ANSIToken",
    "category": "section",
    "text": "By printing an ANSIToken to the terminal it sets up the following printed text to be printed in the style defined by the token. To print a text in the format of the ANSIToken simply print the token first followed by the text:(Image: )note: Note\nSimply printing a new token will not reset previously activated tokens. For example, if you have started printing in bold, printing a token that sets the foreground to a color will not stop the bold from still being in effect. To reset everything, there is a ANSICodes.ResetToken that resets the printing to the default state:(Image: )If you create a token that actually has bold = false then it will of course change the bold mode:(Image: )"
},

{
    "location": "internals/ansitoken.html#Merging-ANSITokens-1",
    "page": "ANSIToken",
    "title": "Merging ANSITokens",
    "category": "section",
    "text": "Two or more ANSITokens can be merged creating a new ANSIToken that has all properties of the merged ones. If two of the ANSIToken specify the same property (for example the foreground color) then the property of the last token in the argument list is used:(Image: )The resulting token in the figure above is green because the foreground of the green token overrides the foreground in the underline_red one."
},

{
    "location": "internals/passes.html#",
    "page": "Passes",
    "title": "Passes",
    "category": "page",
    "text": ""
},

{
    "location": "internals/passes.html#Passes-1",
    "page": "Passes",
    "title": "Passes",
    "category": "section",
    "text": "In OhMyREPL each plugin that changes the way text is printed to the REPL is implemented as a pass. A pass is defined as a function (or a call overloaded type) that takes a list of Julia tokens from Tokenize.jl, a list of ANSITokens, the position of the cursor and sets the ANSITokens to however the pass wants the Julia tokens to be printed. Both the Syntax highlighting and the Bracket highlighting are implemented as passses.All the passes are registered in a global pass handler. To show all the passes use OhMyREPL.showpasses():julia> OhMyREPL.showpasses()\n----------------------------------\n #   Pass name             Enabled  \n----------------------------------\n 1   BracketHighlighter    true     \n 2   SyntaxHighlighter     true     \n----------------------------------A pass can be enabled or disabled at will with OhMyREPL.enable_pass!(pass_name::String, enabled::Bool). As an example, we disable the syntax highlighting:(Image: )"
},

{
    "location": "internals/passes.html#How-a-pass-works-1",
    "page": "Passes",
    "title": "How a pass works",
    "category": "section",
    "text": "We will here show how text from the REPL get transformed into syntax highlighted text. The sample text used is:str = \"function f(x::Float64) return :x + 'a' end\"First the text is tokenized with Tokenize.jl:julia> using Tokenize\n\njulia> tokens = collect(Tokenize.tokenize(str))\n20-element Array{Tokenize.Tokens.Token,1}:\n  1,1-1,8:          KEYWORD           \"function\"\n  1,9-1,9:          WHITESPACE        \" \"       \n  1,10-1,10:        IDENTIFIER        \"f\"       \n  1,11-1,11:        LPAREN            \"(\"       \n  1,12-1,12:        IDENTIFIER        \"x\"       \n  1,13-1,14:        OP                \"::\"      \n  1,15-1,21:        IDENTIFIER        \"Float64\" \n  1,22-1,22:        RPAREN            \")\"       \n  1,23-1,23:        WHITESPACE        \" \"       \n  1,24-1,29:        KEYWORD           \"return\"  \n  1,30-1,30:        WHITESPACE        \" \"       \n  1,31-1,31:        OP                \":\"       \n  1,32-1,32:        IDENTIFIER        \"x\"       \n  1,33-1,33:        WHITESPACE        \" \"       \n  1,34-1,34:        OP                \"+\"       \n  1,35-1,35:        WHITESPACE        \" \"       \n  1,36-1,38:        CHAR              \"'a'\"     \n  1,39-1,39:        WHITESPACE        \" \"       \n  1,40-1,42:        KEYWORD           \"end\"     \n  1,43-1,42:        ENDMARKER         \"\" We then create a vector of ANSITokens of the same length as the Julia tokens and fill it with empty tokens. .ansitokens = Vector{OhMyREPL.ANSIToken}(length(tokens));\nfill!(ansitokens, OhMyREPL.ANSIToken()) # ANSIToken is a bits type so this is OKThese two vectors are then sent to the syntax highlighter pass together with an integer that represent what character offset the cursor currently is located. The syntax highlighter does not use this information but the bracket highlighter does.OhMyREPL.Passes.SyntaxHighlighter.SYNTAX_HIGHLIGHTER_SETTINGS(ansitokens, tokens, 0)Running this function has the effect of updating the ansitokens vector. If we print this vector we see that they have been updated:(Image: )To print the original string with the updated vector of ANSITokens we use the OhMyREPL.untoktenize_with_ANSI([io::IO], ansitokens, tokens) function as:(Image: )Each registered and enabled pass does this updating and the contributions from each pass to the ANSIToken vector is merged in to a separate vector. After each pass is done, the result is printed to the REPL."
},

{
    "location": "internals/passes.html#Creating-a-pass-1",
    "page": "Passes",
    "title": "Creating a pass",
    "category": "section",
    "text": "We will here show how to create a very pass that let the user define an ANSIToken for each type assertion / declaration that happens to be a Float64.info: Info\nPlease refer to the Tokenize.jl API and  ANSIToken sections when reading this section.We start off with a few imports and creating a new type which will hold the setting for the pass:using Compat # For the call overloading syntax\nimport Tokenize.Tokens: Token, untokenize, exactkind\nimport OhMyREPL: ANSICodes.ANSIToken\n\ntype Float64Modifier\n    token::ANSIToken\nend\n\n# Default it the underlined red:\nconst FLOAT64_MODIFIER = Float64Modifier(ANSIToken(foreground = :red, underline= true))We then use call overloading to define a function for the type. The function will update the ANSIToken if the previous token was a :: operator and that the current token is a Float64 identifier, as in ::Float64.# The pass function, the cursor position is not used but it needs to be given an argument\n@compat function (float64modifier::Float64Modifier)(ansitokens::Vector{ANSIToken}, tokens::Vector{Token}, cursorpos::Int)\n    # Loop over all tokens and ansitokens\n    for i in 1:length(ansitokens)\n        if untokenize(tokens[i]) == \"Float64\"\n            if i > 1 && exactkind(tokens[i-1]) == Tokenize.Tokens.DECLARATION\n                # Update the ansi token\n                ansitokens[i] = float64modifier.token\n            end\n        end\n    end\nend"
},

{
    "location": "internals/passes.html#Testing-the-pass-1",
    "page": "Passes",
    "title": "Testing the pass",
    "category": "section",
    "text": "We can now test the pass with the OhMyREPL.test_pass([io::IO], pass, str::String) where str is a test string to test the pass on:(Image: )"
},

{
    "location": "internals/passes.html#Register-the-pass-1",
    "page": "Passes",
    "title": "Register the pass",
    "category": "section",
    "text": "To register and start using the pass simply use OhMyREPL.add_pass!(passname::String, pass):julia> OhMyREPL.add_pass!(\"Redify Float64\", FLOAT64_MODIFIER)\n----------------------------------\n #   Pass name             Enabled  \n----------------------------------\n 1   Redify Float64        true     \n 2   BracketHighlighter    true     \n 3   SyntaxHighlighter     true     \n----------------------------------We can now try it out together with the other passes by writing some syntax that includes ::Float64:(Image: )"
},

{
    "location": "internals/passes.html#Modify-prescedence-of-registered-passes-1",
    "page": "Passes",
    "title": "Modify prescedence of registered passes",
    "category": "section",
    "text": "We actually have a conflict now because both the syntax highlighter and the newly added pass will try to modify the properties of the printed Float64 token. This is where the prescedence of each pass come in. The order of each pass is executed from bottom up in the list given by OhMyREPL.show_passes(). As can be see above, the new pass has the highest prescedence which is why the color of Float64 is actually red.The prescedence of a pass can be modified with the OhMyREPL.prescedence!(pass::Union{String, Int}, prescedence::Int). The variable pass here is either the name of the pass or its number as given by OhMyREPL.show_passes(). We now set the prescedence of the new pass to 3:julia> OhMyREPL.prescedence!(\"Redify Float64\", 3)\n----------------------------------\n #   Pass name             Enabled  \n----------------------------------\n 1   BracketHighlighter    true     \n 2   SyntaxHighlighter     true     \n 3   Redify Float64        true     \n----------------------------------Rewriting the same string in the REPL as above we now get:(Image: )The foreground color of Float64 is now determined by the Syntax highlighter pass. Note that the syntax highlighter does not touch the underlining so that one is still kept from the new pass."
},

]}
