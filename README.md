# PimpMyREPL

- Have different passses that take a list of tokens and return a
"replacement rule" or something that says for each character index, no for each token because the
if it should have a change of color, boldness, underliness..

We have a list of n_tokens bools if there is a replacement rule and then we find which one and apply it.

These are called "repl passes".

A user can add a repl pass with add_pass(func, :name)

pass_enabled(:name, bool)


#

The way colourized text is written to the Terminal is by first writing something called an ANSI Code followed by the text tto be shown. An ansi code is first initializedPrinting `"\e[33mHello" will

In `PimpMyREPL` this is abstracted away by a type called `ANSIToken` in the `ANSICode` module.

Àn `ANSIToken` is created from the where all the arguments are optional keyword arguments.

`ANSIToken(;background::Symbol, foreground::Symbol, bold::Bool, italics::Bold, strikethrough::Bool)`

Showing an `ANSIToken` will prints it

Printing italic red text with a green background can then be done as:

`print(ANSIToken(foreground = :red, italics = true, background = :green), "red and italic text")`



To test what colors and are available to your terminal you can run the `ANSICode.test_ANSI()` which will print some text with different colors and modifiers.





# Tokenize

Same as python,..
return an iterator, next, done, end, might have to put the check in next.

- Generate a big enum of all ops.

add some funcs like
isoperator alt have another field with exact_operator..
