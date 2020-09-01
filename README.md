# OhMyREPL

*This is my REPL. There are many like it, but this one is mine.*

![repl](https://i.imgur.com/wtR0ASD.png)

[![Build Status](https://travis-ci.org/KristofferC/OhMyREPL.jl.svg?branch=master)](https://travis-ci.org/KristofferC/OhMyREPL.jl) [![Build status](https://ci.appveyor.com/api/projects/status/4qlpyvwaggd1vrx7?svg=true)](https://ci.appveyor.com/project/KristofferC/ohmyrepl-jl) [![][docs-latest-img]][docs-latest-url]


A package that hooks into the Julia REPL and gives it syntax highlighting, bracket highlighting, rainbow brackets and other goodies.
A (slightly outdated) video showing installation and features of the package is available [here](https://www.youtube.com/watch?v=lTLPAOLLbTU).

If you like this package please give it a star. I like stars.

### Installation

```jl
Pkg.add("OhMyREPL")
```

and then just load with `using OhMyREPL` (preferably by putting it in the `.julia/config/startup.jl` file)

### Features

* Syntax highlighting - Highlighting of keyword, operators, symbols, strings etc. in different colors.
* Bracket highlighting - Will make matching brackets highlighted when the cursor is between an opening and closing bracket.
* Automatic bracket insertion - Will insert matching closing bracket and quotation symbols when suitable.
* Prompt changing - Can change the text and color of the `julia>` prompt as well as add a prompt for output.
* Rainbow brackets - Colorizes matching brackets in the same color.
* Fuzzy (fzf) history search - Search REPL history in any mode fuzzily with beloved [fzf](https://github.com/junegunn/fzf).

### Documentation

Please see [the documentation](https://KristofferC.github.io/OhMyREPL.jl/latest) for more extensive description of the features and their settings like how to change coloschemes, how to create your own colorschemes etc.

[docs-latest-img]: https://img.shields.io/badge/docs-latest-blue.svg
[docs-latest-url]: https://kristofferc.github.io/OhMyREPL.jl/latest/

### Warning

Note that this package overwrites some methods from Julia Base. If you get a weird error when using OhMyREPL you should reproduce it without having OhMyREPL loaded before reporting it as a Julia bug.
