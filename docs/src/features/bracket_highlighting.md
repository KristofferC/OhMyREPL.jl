# Bracket highlighting

![](bracket_highlight_example.png)

Makes matching brackets highlighted when the cursor is between an opening and closing bracket.

## Settings

!!! info
    Please refer to the [ANSIToken](@ref) section while reading this section.

It is possbile to change the way the highlighted bracket is printed with the function

```OhMyREPL.Passes.BracketHighlighting.set_token!(::ANSIToken)```

![](bracket_highlight_setting.png)