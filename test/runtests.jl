withenv("FORCE_COLOR" => true) do
    include("test_custompass.jl")
    include("test_bracketmatch.jl")
    include("test_highlighter.jl")
    include("test_rainbowbrackets.jl")
end
