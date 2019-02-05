withenv("FORCE_COLOR" => true) do
    if Sys.islinux()
        include("flicker.jl")
    end
    include("test_custompass.jl")
    include("test_bracketmatch.jl")
    include("test_highlighter.jl")
    include("test_rainbowbrackets.jl")
end
