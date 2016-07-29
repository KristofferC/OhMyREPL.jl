# PimpMyREPL

- Have different passses that take a list of tokens and return a
"replacement rule" or something that says for each character index, no for each token because the
if it should have a change of color, boldness, underliness..

We have a list of n_tokens bools if there is a replacement rule and then we find which one and apply it.

These are called "repl passes".

A user can add a repl pass with add_pass(func, :name)

pass_enabled(:name, bool)




# Tokenize

Same as python,..
return an iterator, next, done, end, might have to put the check in next.

- Generate a big enum of all ops.

add some funcs like
isoperator alt have another field with exact_operator..
