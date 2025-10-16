# Markdown Syntax Highlighting

![](markdown_highlight_example.png)

OhMyREPL will by default make code blocks written in markdown syntax (for example in docstrings) highlighted with the colorscheme used by the syntax highlighter.

## Settings

Can be disabled or enabled with `enable_highlight_markdown(::Bool)`.

To distinguish the `julia> ` in a markdown output from the real REPL prompt, its appearance is configurable.

```@docs
OhMyREPL.markdown_prompt!
```
