withenv("FORCE_COLOR" => true) do
    # TODO: re-enable
    if false # Sys.isunix() && VERSION >= v"1.1.0"
        include("flicker.jl")
    else
        @warn "flicker test not run"
    end
    include("test_custompass.jl")
    include("test_bracketmatch.jl")
    include("test_highlighter.jl")
    include("test_rainbowbrackets.jl")
end
