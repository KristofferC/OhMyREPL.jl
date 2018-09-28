using OhMyREPL
using Test

@testset "overwriting" begin
    @testset "force overwrite" begin
        @info "A"^8 overwrite_lastlog=true
        sleep(0.5)
        @info "B"^8 overwrite_lastlog=true
        sleep(0.5)
        @info "C"^8 overwrite_lastlog=true
        sleep(0.5)
        @info "D"^8 overwrite_lastlog=true
        sleep(0.5)
        @info "E"^8 overwrite_lastlog=true
        sleep(0.5)

        @info "F"^3 n=2 overwrite_lastlog=true 
        sleep(0.5)
        @info "G"^3 n=3 m=3  overwrite_lastlog=true 
         sleep(0.5)
        @info "H"^3  overwrite_lastlog=true 


    end

    @testset "repeat overwrite" begin
        for ii in 1:10
            @info "Should Overwrite1" ii
            sleep(0.5)
        end
        
        for ii in 1:10
            @info "Should Overwrite2 (but not first)" ii doubleii=2ii
            sleep(0.5)
        end
    end


    @testset "don't repeat overwrite" begin
        for ii in 1:10
            @info "Should not overwrite" ii overwrite_lastlog=false
            sleep(0.5)
        end
    end
end


@testset "progress" begin

    @testset "single" begin
        @info "A" progress=0.1
        @info "A" progress=-0.1
        @info "A" progress=10
        @info "A" progress=NaN
        @info "A" progress=Inf
        @info "A" progress=-Inf
        
        @info "A" progress="Good"

        @info "B" progress = "50%"
        @info "B" progress = "fully done 100%"

        @info "C" completion = "5%"
    end
    
    @testset "loop" begin
        for ii in 1:100
            @info "loop" ii progress=ii/100 half="$(ii/2)%"
            sleep(0.1)
        end
    end


end


