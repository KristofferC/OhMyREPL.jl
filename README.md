# OhMyREPL

*This is my REPL. There are many like it, but this one is mine.*

![repl](https://i.imgur.com/wtR0ASD.png)

[![Build Status](https://travis-ci.org/KristofferC/OhMyREPL.jl.svg?branch=master)](https://travis-ci.org/KristofferC/OhMyREPL.jl) [![Build status](https://ci.appveyor.com/api/projects/status/4qlpyvwaggd1vrx7?svg=true)](https://ci.appveyor.com/project/KristofferC/ohmyrepl-jl) [![][docs-latest-img]][docs-latest-url]


A package that hooks into the Julia REPL and gives it syntax highlighting, bracket highlighting, [prompt paste mode](https://github.com/JuliaLang/julia/pull/17599), [colorized, structured error messages](https://github.com/JuliaLang/julia/pull/18228) and other goodies.

**Note:** A video showing installation and features of the package is available [here](https://www.youtube.com/watch?v=lTLPAOLLbTU).

If you like this package please give it a star. I like stars.

### Installation

```jl
Pkg.clone("https://github.com/KristofferC/Tokenize.jl")
Pkg.clone("https://github.com/KristofferC/OhMyREPL.jl")
```

and then just load with `using OhMyREPL` (preferably by putting it in the `.juliarc.jl`)

### Features

* Syntax highlighting - Highlighting of keyword, operators, symbols, strings etc. in different colors.
* Bracket highlighting - Will make matching brackets highlighted when the cursor is between an opening and closing bracket.
* Automatic bracket insertion - Will insert matching closing bracket and quotation symbols when suitable.
* Prompt pasting - If a pasted statement starts with `julia> ` any statement beginning with `julia> ` will have that part removed before getting parsed and any other statement will be removed. 
* Colorized error messages [0.5 only]. Will write the error messages in a bit nicer way.

### Documentation

Please see [the documentation](https://KristofferC.github.io/OhMyREPL.jl/latest) for more extensive description of the features and their settings like how to change coloschemes, how to create your own colorschemes etc.

[docs-latest-img]: https://img.shields.io/badge/docs-latest-blue.svg
[docs-latest-url]: https://kristofferc.github.io/OhMyREPL.jl/latest/
