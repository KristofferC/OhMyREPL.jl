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

using Test, OhMyREPL, CodeTracking
@testset "code_src macro" begin
    original_stdout = stdout

    (rd, wr) = redirect_stdout();

    @code_src sum(1:3)
    redirect_stdout(original_stdout)
    close(wr)

    s = read(rd, String)
    redirect_stdout(original_stdout)
    @test contains(s, "\e[")
    @test contains(s, "AbstractRange")
end
