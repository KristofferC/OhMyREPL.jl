# PimpMyREPL

Loading it gives the Julia REPL syntax highlighting, bracket highlighting, [prompt paste mode](https://github.com/JuliaLang/julia/pull/17599) and some other goodies.

![repl](https://media.giphy.com/media/l0HlyCECiFySyUdBS/giphy.gif)

**Note:** This is heavily a WIP in progress and are many things to fix. Issues with clear [MCVE](http://stackoverflow.com/help/mcve) are very welcome.

# Installation

```jl
Pkg.clone("https://github.com/KristofferC/Tokenize.jl")
Pkg.clone("https://github.com/KristofferC/PimpMyREPL.jl")
```

and then just load with `using PimpMyREPL`.

# Automatically start with Julia.

Put this in `.juliarc.jl`

```jl
function setup()
    @async while true
        if isdefined(Base,:active_repl)
                @eval using PimpMyREPL
            end
            break
        else
            sleep(0.1)
        end
    end
end

setup()
```
