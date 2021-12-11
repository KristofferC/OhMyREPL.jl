# `@code_src` macro

The macro allows you to display source code of a method in-line,
just like `@code_llvm` and `@code_typed`. Inspired by: 
https://github.com/JuliaLang/julia/issues/2625#issuecomment-498840808

```julia-repl
julia> @code_src sum(1:3)
function sum(r::AbstractRange{<:Real})
    l = length(r)
    # note that a little care is required to avoid overflow in l*(l-1)/2
    return l * first(r) + (iseven(l) ? (step(r) * (l-1)) * (l>>1)
                                     : (step(r) * l) * ((l-1)>>1))
end
```
