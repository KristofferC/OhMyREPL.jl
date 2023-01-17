# Syntax highlighting

![repl](https://i.imgur.com/wtR0ASD.png)

The Syntax highlighting pass transforms input text in the REPL to highlighted text, highlighting keyword, operators, symbols, strings etc. in different colors. There are a few color schemes that comes with `OhMyREPL` but it is fairly easy to create your own to your liking.

## Default schemes

The current default colorschemes that comes with `OhMyREPL` are

* "JuliaDefault" - the default Julia scheme, white and bold.
* "Monokai16" - 16 color Monokai
* "Monokai256" - 256 colors Monokai
* "Monokai24bit" - 24 bit colored Monokai
* "BoxyMonokai256" - 256 colors Monokai from [here](https://github.com/oivva/st-boxy)
* "TomorrowNightBright" - 256 colors Tomorrow Night Bright
* "TomorrowNightBright24bit" - 24 bit colored Tomorrow Night Bright
* "OneDark" - 24 bit colored OneDark
* "Base16MaterialDarker" - 24-bit [Base16](https://github.com/chriskempson/base16) Material Darker color scheme by [Nate Peters](https://github.com/ntpeters/base16-materialtheme-scheme)
* "GruvboxDark" - Dark-mode variation of the [Gruvbox](https://github.com/morhetz/gruvbox#dark-mode) color scheme by Pavel Pertsev.
* "GitHubLight", "GitHubDark" and "GitHubDarkDimmed" - GitHub's [colorschemes](https://primer.style/primitives/colors#themes), matching the [VS Code themes](https://github.com/primer/github-vscode-theme/)

 By default, "Monokai16" will be used on Windows and "Monokai256" otherwise. To test the supported colors in your terminal you can use `Crayons.test_system_colors()`, `Crayons.test_256_colors()`, `Crayons.test_24bit_colors()` to test 16, 256 and 24 bit colors respectively.

## Preview

To see an example output of a colorscheme use `test_colorscheme(name::String, [test_string::String])`. If a `test_string` is not given, a default string will be used.

![](test_colorscheme.png)

## Activate

To activate a colorscheme use `colorscheme!(name::String)`

![](activate_colorscheme.png)

## Creating your own colorschemes.

This section will describe how to create your own colorscheme.

!!! info
    Please refer to the [Crayons.jl](https://github.com/KristofferC/Crayons.jl) documentation while reading this section.

We start by loading the `Crayons` package and importing the `SyntaxHighlighter` and the ..

```
using Crayons
import OhMyREPL: Passes.SyntaxHighlighter
```

We now create a default colorscheme:

```
scheme = SyntaxHighlighter.ColorScheme()
```

By using the function `test_colorscheme` we can see that the default colorscheme simply prints everything in the default color:

![](default_colorscheme.png)

There are a number of setter function that updates the colorscheme. They are called like `setter!(cs::ColorScheme, crayon::Crayon)`. The different setters are:

* `symbol!` - A symbol, ex `:symbol`
* `comment!` - A comment, ex `# comment`, `#= block comment =#`
* `string!` - A string or char, ex `"""string"""`, `'a'`
* `call!` - A functionc all, ex `foo()`
* `op!` - An operator, ex `*`, `√`
* `keyword!` - A keyword, ex `function`, `begin`, `try`
* `function_def!` - A function definition, ex `function foo(x) x end`
* `error!` - An error in the Tokenizer, ex `#= unending multi comment`
* `argdef!` - Definition of a type, ex `::Float64`
* `macro!` - A macro, ex `@time`
* `number!` - A number, ex `100`, `100_00.0`, `0xf00`
* `text!` - Nothing of the above

Let us set the strings to be printed in yellow, numbers to be printed in bold, and function calls to be printed in cyan:

```
SyntaxHighlighter.string!(scheme, Crayon(foreground = :yellow))
SyntaxHighlighter.number!(scheme, Crayon(bold = true))
SyntaxHighlighter.call!(scheme, Crayon(foreground = :cyan))
```

!!! info
    Remember that you can also use integers for the `foreground` and `background` arguments to `Crayon` and they will then refer to the colors showed by `Crayons.test_256_colors()`. Also, you can of course specify many properties for the same `Crayon`.

By recalling `test_colorscheme` on the scheme we can see it has been updated:

![](updated_scheme.png)

By continuing in this fashion you can build up a full colorscheme. When you are satisfied with your colorscheme you can add it to the group of color schemes and activate it as:

![](activate_custom_scheme.png)

You can look in the source code to see how the default color schemes are made.

For fun, the code below creates a truly random colorscheme:

```jl
function rand_token()
    Crayon(background = rand(Bool) ? :nothing : rand(1:256),
              foreground = rand(Bool) ? :nothing : rand(1:256),
              bold = rand(Bool), italics = rand(Bool), underline = rand(Bool))
end

function create_random_colorscheme()
    random = SyntaxHighlighter.ColorScheme()
    SyntaxHighlighter.symbol!(random,rand_token())
    SyntaxHighlighter.comment!(random, rand_token())
    SyntaxHighlighter.string!(random, rand_token())
    SyntaxHighlighter.call!(random, rand_token())
    SyntaxHighlighter.op!(random, rand_token())
    SyntaxHighlighter.keyword!(random, rand_token())
    SyntaxHighlighter.macro!(random, rand_token())
    SyntaxHighlighter.function_def!(random, rand_token())
    SyntaxHighlighter.text!(random, rand_token())
    SyntaxHighlighter.error!(random, rand_token())
    SyntaxHighlighter.argdef!(random, rand_token())
    SyntaxHighlighter.number!(random, rand_token())
    return random
end

test_colorscheme(create_random_colorscheme())
```

![](random_scheme.png)
