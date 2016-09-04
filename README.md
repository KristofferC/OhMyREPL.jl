# PimpMyREPL

A package that hooks into the Julia REPL and gives it syntax highlighting, bracket highlighting, [prompt paste mode](https://github.com/JuliaLang/julia/pull/17599), [colorized, structured error messages](https://github.com/JuliaLang/julia/pull/18228) and other goodies.

![repl](https://i.imgur.com/wtR0ASD.png)

If you like this package please give it a star. I like stars.

**Note:** This is WIP in progress and are many things to fix. Issues with clear [MCVE](http://stackoverflow.com/help/mcve) are very welcome.

### Installation

```jl
Pkg.clone("https://github.com/KristofferC/Tokenize.jl")
Pkg.clone("https://github.com/KristofferC/PimpMyREPL.jl")
```

and then just load with `using PimpMyREPL`.

### Features

* Syntax highlighting - Highlighting of keyword, operators, symbols, strings etc. in different colors. There available colorschemes are currently:
    * "JuliaDefault" - the default Julia scheme.
    * "Monokai16" - 16 colors
    * "Monokai256" - 256 colors
    * "BoxyMonokai256" - 256 colors

    To see an example output of a colorscheme use `test_colorscheme(name::String)`.
To activate a colorscheme use `colorscheme!(name::String)`. By default, "Monokai16" will be used on Windows and "Monokai256" otherwise. To test the supported colors in your terminal you can use `PimpMyREPL.ANSICodes.test_ANSI()` and `PimpMyREPL.ANSICodes.test_ANSI_256()` to test 16 and 256 colors respectively.
* Bracket highlighting - Will make matching brackets highlighted when the cursor is between an opening and closing bracket.
* Automatic bracket insertion - Will insert a matching closing bracket to an opening bracket automatically unless the next character is the same opening bracket. Will also ignore an input closing bracket if the character under the cursor is that closing bracket. This can be enabled or disabled at will with `enable_autocomplete_brackets(::Bool)`.
* Prompt pasting - If a pasted statement starts with `julia> ` any statement beginning with `julia> ` will have that part removed before getting parsed and any other statement will be removed. This makes easy to paste what others have copied from their REPL without the need to remove any prompts or output.
* Colorized error messages [0.5 only]. Will write the error messages in a bit nicer way. To disable, put `ENV["LEGACY_ERRORS"] = true` in your `.juliarc` file. Each stack frame has a number that is shown to the left. If you enter that number in the REPL and then press `Ctrl + Q` the editor will open at the line in the file of that stackframe. To set the editor to use, use for example `ENV["EDITOR"] = "subl"` for Sublime Text on linux. A demonstration of this functionality can be seen [here](https://media.giphy.com/media/3o7TKKlZrKQnWcdGTK/giphy.gif).

### Automatically start with Julia.

Put this in `.juliarc.jl`

```jl
function setup()
    if isdir(Pkg.dir("PimpMyREPL"))
        @async while true
            if isdefined(Base, :active_repl)
                sleep(0.05)
                @eval using PimpMyREPL
                break
            else
                sleep(0.1)
            end
        end
    else
        warn("PimpMyREPL not installed")
    end
end

setup()
```



### Documentation

TODO: `ANSIToken`, `ANSIValue` docs.

#### Pipeline

The pipeline of how things are transformed from normal text to pimped text is as follows:

* When a key is pressed, tokenize the full input string using `Tokenize.jl`.
* To each token there is an associated `ANSIToken` which represents how the Token should be
printed in the Terminal.
* The list of `Tokens`, the list of `ANSITokens`s and the current position of the cursor are then sent to each registered and enabled pass.
* The purpose of a pass is to look at the list of `Tokens` and update each `ANSIToken` to its liking. The `BracketHighlighter` pass for example looks through the tokens and find matching brackets with help of the cursor position and then updates the corresponding `ANSIToken`s for the found matching bracket `Token`s.
* After all passes are done, the `Token`s are then printed out to the terminal according to their now updated `ANSIToken`.

#### Creating your own pass.

It is simple to create your own pass. We will here show how to create a pass that will transform all the `*` operators to be underlined and bold. To do so, we simply create a function that looks through the list of tokens for this operator and updates the `ANSIToken` for that `Token`. We then add this function to the global pass handler. This will immediately take effect.

```jl
using Tokenize # Load the tokenization library
# import the global pass handler that keep track of all passes
import PimpMyREPL: PASS_HANDLER, ANSICodes.ANSIValue

# Write the pass function, the cursor position is not used but it needs to be given an argument
function underline_star(ansitokens, tokens, cursorposition::Int)
    # Loop over all tokens and ansitokens
    for (ansitok, tok) in zip(ansitokens, tokens)
        # If the token is a STAR token
        if Tokenize.Tokens.exactkind(tok) == Tokenize.Tokens.STAR
            # Update the ansi token
            ansitok.underline = ANSIValue(:underline, :true)
            ansitok.bold = ANSIValue(:bold, :true)
        end
    end
end

# Add the pass to the pass_handler
PimpMyREPL.add_pass!(PASS_HANDLER, "Underline star", underline_star);
```

![](https://i.imgur.com/MxVeA6j.png)

For documentation of the `Token` type please see the [`Tokenize.jl` repo](https://github.com/KristofferC/Tokenize.jl).
