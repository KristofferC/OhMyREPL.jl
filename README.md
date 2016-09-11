# OhMyREPL

*This is my REPL. There are many like it, but this one is mine.*

![repl](https://i.imgur.com/wtR0ASD.png)

A package that hooks into the Julia REPL and gives it syntax highlighting, bracket highlighting, [prompt paste mode](https://github.com/JuliaLang/julia/pull/17599), [colorized, structured error messages](https://github.com/JuliaLang/julia/pull/18228) and other goodies.

**Note:** A video showing installation and features of the package is available [here](https://www.youtube.com/watch?v=lTLPAOLLbTU).

If you like this package please give it a star. I like stars.

### Installation

```jl
Pkg.clone("https://github.com/KristofferC/Tokenize.jl")
Pkg.clone("https://github.com/KristofferC/OhMyREPL.jl")
```

and then just load with `using OhMyREPL` (preferably by putting it in the `.juliarc`)

### Features

* Syntax highlighting - Highlighting of keyword, operators, symbols, strings etc. in different colors.
* Bracket highlighting - Will make matching brackets highlighted when the cursor is between an opening and closing bracket.
* Automatic bracket insertion - Will insert matching closing bracket and quotation symbols when suitable.
* Prompt pasting - If a pasted statement starts with `julia> ` any statement beginning with `julia> ` will have that part removed before getting parsed and any other statement will be removed. 
* Colorized error messages [0.5 only]. Will write the error messages in a bit nicer way.

### Documentation

Please see [the documentation](https://KristofferC.github.io/OhMyREPL.jl/latest) for more extensive description of the features and their settings like how to change coloschemes, how to create your own colorschemes etc.

