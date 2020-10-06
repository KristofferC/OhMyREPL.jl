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

    # reinstall keybindings to after Pkg. See https://github.com/KristofferC/OhMyREPL.jl/issues/166 
    # Pkg comes with a REPL. Enter the Pkg REPL by pressing ] from the Julia REPL. To get back to the 
    # Julia REPL, press backspace or ^C.
    # reference: see https://docs.julialang.org/en/v1/stdlib/Pkg/
    # ulitmately, it would be best to change the Pkg trigger key to something less common than ']' or ensure
    # that all julia REPL built-ins load before packages loaded from startup.jl. The following takes the
    # second strategy. 
    # Adding the following block fixes the behavior of OhMyREPL, and Pkg trigger still works (miraculously). 
    @async begin
       sleep(1)
       OhMyREPL.Prompt.insert_keybindings()
    end
end
```

in your `.julia/config/startup.jl` file. Create this file (and directory) if it is not already there.

You can also compile `OhMyREPL` into the Julia system image. This will mean that there is no need to edit your `.juliarc` file and the Julia REPL will start a bit quicker since it does not have to parse and compile the package when it is loaded. The way to do this is by using https://github.com/JuliaLang/PackageCompiler.jl.
