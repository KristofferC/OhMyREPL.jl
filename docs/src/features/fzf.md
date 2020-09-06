# Fuzzy REPL history search

![](fzf.png)

By default (on Julia 1.3+), OhMyREPL will use
[fzf](https://github.com/junegunn/fzf) to search in the REPL history (initiated
by pressing Ctrl-R). This is a [fuzzy
searcher](https://en.wikipedia.org/wiki/Approximate_string_matching) which means
that you don't need to verbatim enter what you want to match. So if you wrote
`@eval Base foo(x) = x+1` at some time you can search for e.g. `@eval foo` to
find it.

This feature can be turned on/off using `enable_fzf(::Bool)`.
