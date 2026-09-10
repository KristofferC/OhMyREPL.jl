# Colorschemes

![repl](https://i.imgur.com/wtR0ASD.png)

Julia 1.13+ highlights REPL input (and code blocks in docstrings) natively using the
`JuliaSyntaxHighlighting` standard library, which reads its colors from
[StyledStrings](https://docs.julialang.org/en/v1/stdlib/StyledStrings/) *faces* named
`julia_keyword`, `julia_string` and so on. An OhMyREPL colorscheme is simply a named
collection of these faces, and activating one sets the faces globally, so the scheme
applies everywhere the native highlighting is used.

## Default schemes

The colorschemes that come with `OhMyREPL` are

* "JuliaDefault" - the stock Julia colors
* "Monokai" - the default when loading OhMyREPL
* "BoxyMonokai" - Monokai variant from [here](https://github.com/oivva/st-boxy)
* "Tomorrow", "TomorrowDay" and "TomorrowNightBright" - the [Tomorrow](https://github.com/chriskempson/tomorrow-theme) themes
* "Distinguished"
* "OneDark" and "OneLight" - the Atom themes
* "Base16MaterialDarker" - [Base16](https://github.com/chriskempson/base16) Material Darker color scheme by [Nate Peters](https://github.com/ntpeters/base16-materialtheme-scheme)
* "GruvboxDark" - Dark-mode variation of the [Gruvbox](https://github.com/morhetz/gruvbox#dark-mode) color scheme by Pavel Pertsev.
* "GitHubLight", "GitHubDark" and "GitHubDarkDimmed" - GitHub's [colorschemes](https://primer.style/primitives/colors#themes), matching the [VS Code themes](https://github.com/primer/github-vscode-theme/)

All schemes are defined in 24-bit color; StyledStrings automatically downsamples them
to 256 or 16 colors depending on what the terminal supports. The old
capability-specific scheme names ("Monokai256", "Monokai24bit", ...) still work as
aliases.

Use `colorschemes()` to list the schemes together with a sample of their colors.

## Preview

To see an example output of a colorscheme use `test_colorscheme(name::String,
[test_string::String])`. If a `test_string` is not given, a default string will be
used.

## Activate

To activate a colorscheme use `colorscheme!(name::String)`.

## Creating your own colorschemes

A colorscheme is created with the `OhMyREPL.ColorScheme` constructor, where every
keyword argument is a `StyledStrings.Face`:

```julia
using StyledStrings: Face

scheme = OhMyREPL.ColorScheme(
    symbol       = Face(foreground = 0xae81ff),         # :foo, true/false
    comment      = Face(foreground = 0x595959),         # # comment
    string       = Face(foreground = 0xe6db74),         # "str", 'c', `cmd`, r"re"
    call         = Face(foreground = 0x66d9ef),         # foo(...)
    op           = Face(foreground = 0xf92672),         # *, =, √
    keyword      = Face(foreground = 0xf92672, weight = :bold), # function, begin
    function_def = Face(foreground = 0xa6e22a),         # the name in function foo(x)
    error        = Face(background = :bright_red),      # syntax errors
    argdef       = Face(foreground = 0x66d9ef),         # ::Float64
    macro_       = Face(foreground = 0x66d9ef),         # @time
    number       = Face(foreground = 0xae81ff),         # 100, 1.0, 0xf00
)
```

Colors can be given as 24-bit hex values (`0xae81ff`), or as named terminal colors
(`:red`, `:bright_blue`, ...). Besides `foreground` and `background`, a `Face` supports
attributes like `weight`, `slant`, `underline` and more; see the
[StyledStrings documentation](https://docs.julialang.org/en/v1/stdlib/StyledStrings/).
Fields that are left out use the terminal's default color.

Register and activate the scheme with:

```julia
colorscheme!("MyScheme", scheme)
```

## Fine-grained control

A colorscheme covers the most important faces, but the native highlighting
distinguishes more token types than a colorscheme does (booleans, string delimiters,
broadcasting operators, ...). Individual faces can be adjusted directly with
`StyledStrings.loadface!`:

```julia
using StyledStrings: loadface!, Face
loadface!(:julia_comparator => Face(foreground = :cyan))
```

Faces customized this way are reset the next time a colorscheme is activated. See the
`JuliaSyntaxHighlighting` documentation for the full list of `julia_*` faces. Faces can
also be customized persistently, independently of OhMyREPL, in
`~/.julia/config/faces.toml`.

## Toggling highlighting

The native input highlighting itself can be turned off with the REPL option

```julia
Base.active_repl.options.style_input = false
```
