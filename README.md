### Note: This package has been renamed from `PimpMyREPL` to `OhMyREPL`. The simplest way of updating is to remove the old package and reclone this one.





### Features


* Automatic bracket insertion - Will insert a matching closing bracket to an opening bracket automatically unless the next character is the same opening bracket. Will also ignore an input closing bracket if the character under the cursor is that closing bracket. This can be enabled or disabled at will with `enable_autocomplete_brackets(::Bool)`.


### Documentation

TODO: `ANSIToken`, `ANSIValue` docs.

#### Pipeline

The pipeline of how things are transformed from normal text to fancy text is as follows:

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
import OhMyREPL: PASS_HANDLER, ANSICodes.ANSIToken

# Write the pass function, the cursor position is not used but it needs to be given an argument
function underline_star(ansitokens, tokens, cursorposition::Int)
    # Loop over all tokens and ansitokens
    for (i, (ansitok, tok)) in enumerate(zip(ansitokens, tokens))
        # If the token is a STAR token
        if Tokenize.Tokens.exactkind(tok) == Tokenize.Tokens.STAR
            # Update the ansi token
            ansitokens[i] = ANSIToken(foreground = :green, underline = true, bold = true)
        end
    end
end

# Add the pass to the pass_handler
OhMyREPL.add_pass!(PASS_HANDLER, "Underline star", underline_star);
```

![](https://i.imgur.com/MxVeA6j.png)

For documentation of the `Token` type please see the [`Tokenize.jl` repo](https://github.com/KristofferC/Tokenize.jl).
