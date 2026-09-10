# OhMyREPL


[![][docs-stable-img]][docs-stable-url] [![build](https://github.com/KristofferC/OhMyREPL.jl/workflows/CI/badge.svg)](https://github.com/KristofferC/OhMyREPL.jl/actions?query=workflow%3ACI)

[docs-stable-img]: https://img.shields.io/badge/docs-blue.svg
[docs-stable-url]: https://kristofferc.github.io/OhMyREPL.jl/latest

*This is my REPL. There are many like it, but this one is mine.*

![repl](https://i.imgur.com/wtR0ASD.png)

As of Julia 1.13, most of the features OhMyREPL used to implement (syntax highlighting,
bracket highlighting, rainbow brackets, automatic bracket insertion and markdown
highlighting in docstrings) are built into the Julia REPL itself. OhMyREPL is now a thin
layer on top of the native functionality that provides:

* Colorschemes - Named colorschemes for the built-in syntax highlighting (applied as
  [StyledStrings](https://docs.julialang.org/en/v1/stdlib/StyledStrings/) faces), plus
  an easy way to define your own.
* Prompt changing - Can change the text and color of the `julia>` prompt as well as add
  a prompt for output.

OhMyREPL 0.6+ requires Julia 1.13. On older Julia versions the 0.5.x releases are
installed instead, which implement the REPL features within the package itself.

If you like this package please give it a star. I like stars.

### Installation

```jl
Pkg.add("OhMyREPL")
```

and then just load with `using OhMyREPL` (preferably by putting it in the `.julia/config/startup.jl` file)

### Quick start

```julia
julia> colorschemes()       # list available colorschemes

julia> colorscheme!("OneDark")  # activate one

julia> test_colorscheme("GruvboxDark")  # preview one without activating it
```

### Documentation

Please see [the documentation](https://KristofferC.github.io/OhMyREPL.jl/latest) for a
more extensive description of the features and their settings, like how to change
colorschemes and how to create your own.

[docs-latest-img]: https://img.shields.io/badge/docs-latest-blue.svg
[docs-latest-url]: https://kristofferc.github.io/OhMyREPL.jl/latest/
