"""
    indices(x)

Returns the indices of a matrix x

# Examples
```julia-repl
julia> a = [1 2 3; 4 5 6]
julia> b = [1 2; 3 4]
julia> a[indices(b)]
2×2 Matrix{Int64}:
 1  2
 4  5
```
"""
function indices(x)
    return (1:i for i in size(x))
end
