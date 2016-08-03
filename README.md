# PimpMyREPL

Loading it gives the Julia REPL syntax highlighting, bracket highlighting, [prompt paste mode](https://github.com/JuliaLang/julia/pull/17599) and some other goodies.

![repl](https://media.giphy.com/media/l0HlyCECiFySyUdBS/giphy.gif)

**Note:** This is heavily a WIP in progress and are many things to fix. Issues with clear [MCVE](http://stackoverflow.com/help/mcve) are very welcome.

### Installation

```jl
Pkg.clone("https://github.com/KristofferC/Tokenize.jl")
Pkg.clone("https://github.com/KristofferC/PimpMyREPL.jl")
```

and then just load with `using PimpMyREPL`.

### Automatically start with Julia.

Put this in `.juliarc.jl`

```jl
function setup()
    if isdir(Pkg.dir("PimpMyREPL"))
        @async while true
            if isdefined(Base, :active_repl)
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
* To each token there is an assoicated `ANSIToken` which represents how the Token should be
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

![](https://media.giphy.com/media/l0HlTd7DfONd0N9jG/giphy.gif)

For documentation of the `Token` type please see the [`Tokenize.jl` repo](https://github.com/KristofferC/Tokenize.jl).
