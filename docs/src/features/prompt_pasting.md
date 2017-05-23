# Prompt pasting

If a pasted statement starts with `julia> ` any statement beginning with `julia> ` will have that part removed before getting parsed and any other statement will also be removed. This makes easy to paste what others have copied from their REPL without the need to remove any prompts or output.

You can try it out by copying and pasting the below straight into the REPL.

```jl
julia> 1 + 1
2

julia> str = """ this
       is
       a
       string """
" this\nis\na\nstring "

julia> @time rand(3)
  0.000003 seconds (6 allocations: 288 bytes)
3-element Array{Float64,1}:
 0.560418
 0.883501
 0.27273
```

!!! warning
    This feature does not work on the standard Windows shells `cmd` or `powershell`.
    Consider using e.g. `cygwin` or `cmder`.


!!! note
    Prompt pasting has been upstreamed to Julia v0.6.
