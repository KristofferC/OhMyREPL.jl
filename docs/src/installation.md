# Installation

OhMyREPL 0.6+ requires Julia 1.13 or later. On older Julia versions, the 0.5.x releases
are installed instead, which implement the REPL features within the package itself.

The package is registered in the General registry so it is easily installed by

```julia
import Pkg; Pkg.add("OhMyREPL")
```

## Automatically start with Julia.

One way of automatically starting the package with Julia is by putting

```julia
atreplinit() do repl
    try
        @eval using OhMyREPL
    catch e
        @warn "error while importing OhMyREPL" e
    end
end
```

in your `.julia/config/startup.jl` file. Create this file (and directory) if it is not already there.
