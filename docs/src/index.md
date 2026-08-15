# OhMyREPL

*This is my REPL. There are many like it, but this one is mine.*

This is the documentation for `OhMyREPL`; a Julia package that makes the Julia REPL nicer.

![repl](https://i.imgur.com/wtR0ASD.png)

As of Julia 1.13, many features that used to be implemented by OhMyREPL (syntax
highlighting, matching bracket highlighting, rainbow brackets, automatic insertion of
closing brackets and highlighting of code blocks in docstrings) are built into the REPL
itself. OhMyREPL is now a thin layer on top of the native functionality that provides:

- Named colorschemes for the built-in syntax highlighting.
- Customizable input and output prompts.

## Manual Outline

```@contents
Pages = [
    "installation.md",
    "features/syntax_highlighting.md",
    "features/native.md",
    "features/prompt.md",
]
Depth = 1
```
