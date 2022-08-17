let

include("FakePTYs.jl")
import .FakePTYs: open_fake_pty

repl_script = """
const OhMyREPL = Base.require(Base.PkgId(Base.UUID("5fb14364-9ced-5910-84b2-373655c76a03"), "OhMyREPL"))
function f(x) x end
print("")
[]
?reinterpret
"""

julia_exepath() = joinpath(Sys.BINDIR, Base.julia_exename())


JULIA_PROMPT = "julia> "
PKG_PROMPT = "pkg> "
SHELL_PROMPT = "shell> "
HELP_PROMPT = "help?> "

function generate_precompile_statements()
    debug_output = devnull

    # Extract the precompile statements from the precompile file
    statements = Set{String}()

    mktemp() do precompile_file, precompile_file_h
        # Collect statements from running a REPL process and replaying our REPL script
        pts, ptm = open_fake_pty()
        blackhole = Sys.isunix() ? "/dev/null" : "nul"

        p = withenv("JULIA_HISTORY" => blackhole,
                    "TERM" => "") do
            run(```$(julia_exepath()) -O0 --trace-compile=$precompile_file
                --cpu-target=native --project=$(Base.active_project()) --compiled-modules=no --startup-file=no -i --color=yes```,
                pts, pts, pts; wait=false)
        end
        Base.close_stdio(pts)
        # Prepare a background process to copy output from process until `pts` is closed
        output_copy = Base.BufferStream()
        tee = @async try
            while !eof(ptm)
                l = readavailable(ptm)
                write(debug_output, l)
                Sys.iswindows() && (sleep(0.1); yield(); yield()) # workaround hang - probably a libuv issue?
                write(output_copy, l)
            end
        catch ex
            if !(ex isa Base.IOError && ex.code == Base.UV_EIO)
                rethrow() # ignore EIO on ptm after pts dies
            end
        finally
            close(output_copy)
            close(ptm)
        end
        # wait for the definitive prompt before start writing to the TTY
        readuntil(output_copy, JULIA_PROMPT)
        sleep(0.1)
        readavailable(output_copy)
        # Input our script
        precompile_lines = split(repl_script::String, '\n'; keepempty=false)
        curr = 0
        for l in precompile_lines
            sleep(0.1)
            curr += 1
            # print("\rGenerating REPL precompile statements... $curr/$(length(precompile_lines))")
            # consume any other output
            bytesavailable(output_copy) > 0 && readavailable(output_copy)
            # push our input
            write(debug_output, "\n#### inputting statement: ####\n$(repr(l))\n####\n")
            write(ptm, l, "\n")
            readuntil(output_copy, "\n")
            # wait for the next prompt-like to appear
            readuntil(output_copy, "\n")
            strbuf = ""
            while !eof(output_copy)
                strbuf *= String(readavailable(output_copy))
                occursin(JULIA_PROMPT, strbuf) && break
                occursin(PKG_PROMPT, strbuf) && break
                occursin(SHELL_PROMPT, strbuf) && break
                occursin(HELP_PROMPT, strbuf) && break
                sleep(0.1)
            end
        end
        write(ptm, "exit()\n")
        wait(tee)
        success(p) || Base.pipeline_error(p)
        close(ptm)
        write(debug_output, "\n#### FINISHED ####\n")

        for statement in split(read(precompile_file, String), '\n')
            # Main should be completely clean
            occursin("Main.", statement) && continue
            push!(statements, statement)
        end
    end
    num_prec = 0
    for statement in statements
        try
            eval(Meta.parse(statement))
            num_prec += 1
        catch e
            #@show e
            #@warn statement
        end
    end
    # @show num_prec
end

generate_precompile_statements()

end
