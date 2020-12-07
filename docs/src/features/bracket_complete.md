# Bracket completion

Will insert a matching closing bracket to an opening bracket automatically if this is deemed likely to be desireable from the context of the surrounding text to the cursor. This is disabled by default on Windows because it interacts badly with pasting code with the default windows terminal.

![](bracket_complete.gif)

## Settings

Can be disabled or enabled with `enable_autocomplete_brackets(::Bool)`.

## Example

If you want to enable `OhMyREPL` on startup of every Julia session, but have brackets turned off, add this to your `~/.julia/config/startup.jl` file:

```julia
using OhMyREPL
enable_autocomplete_brackets(false)
```
