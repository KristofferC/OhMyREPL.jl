# Installation

The package is registered in `METADATA` so it is easily installed by

```jl
Pkg.add("OhMyREPL.jl")
```

## Automatically start with Julia.

One way of automatically starting the package with Julia is by putting

```jl
try
    using OhMyREPL
catch
    @warn "OhMyREPL not installed"
end
```

in your `.julia/config/startup.jl` file.

You can also compile `OhMyREPL` into the Julia system image. This will mean that there is no need to edit your `.juliarc` file and the Julia REPL will start a bit quicker since it does not have to parse and compile the package when it is loaded. The way to do this is described in the [Julia manual](http://docs.julialang.org/en/release-0.4/devdocs/sysimg/#building-the-julia-system-image) but is also summarized here:

* Create a `userimg.jl` file that contains `Base.require(:OhMyREPL)`.
* Run `include(joinpath(JULIA_HOME, Base.DATAROOTDIR, "julia", "build_sysimg.jl"))`
* Run `build_sysimg(default_sysimg_path(), "native", USERIMGPATH; force=true)` where `USERIMGPATH` is the path to the `userimg.jl` file.

If you are building Julia from source, the `userimg.jl` file can just be moved to the `Base` folder and then run `make` like normal.

Note that you will have to redo this process if `OhMyREPL` is updated.
