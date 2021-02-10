# Installation

The package is registered in the General registry so it is easily installed by

```jl
import Pkg; Pkg.add("OhMyREPL")
```

## Automatically start with Julia.

One way of automatically starting the package with Julia is by putting

```jl
atreplinit() do repl
    try
        @eval using OhMyREPL
    catch e
        @warn "error while importing OhMyREPL" e
    end
end
```

in your `.julia/config/startup.jl` file. Create this file (and directory) if it is not already there.

You can also compile `OhMyREPL` into the Julia system image. This will mean that there is no need to edit your `.juliarc` file and the Julia REPL will start a bit quicker since it does not have to parse and compile the package when it is loaded. The way to do this is by using [PackageCompiler.jl](https://github.com/JuliaLang/PackageCompiler.jl).
