"""
    create_surrender_rates(per_len, nsims::Int64, proj::Int64)

Converts short-hand fixed surrender probabilities to full `Matrix` of surrender
rates.

# Examples
```julia-repl
julia> nsims, proj = 3, 100
julia> surr = [0.05 => 12, 0.04 => 12, 0.03 => 12, 0.02 => 12, 0.01 => Inf]
julia> create_surrender_rates(surr, nsims, proj)
5×100 Matrix{Float64}:
 0.00427444  0.00427444  0.00427444  0.00427444  …  0.000837528  0.000837528
 0.00427444  0.00427444  0.00427444  0.00427444     0.000837528  0.000837528
 0.00427444  0.00427444  0.00427444  0.00427444     0.000837528  0.000837528
```
"""
function create_surrender_rates(per_len, nsims::Int64, proj::Int64)::Matrix{Float64}
    surrender_rates = Vector{Float64}(undef, proj)
    k = 0
    for i in eachindex(per_len)
        per, len = per_len[i]
        rate = -log(1-per)/12
        if len == Inf
            surrender_rates[(k+1):proj] .= rate
        else
            len = Int64(ifelse(k+len>=proj, proj-k, len))
            surrender_rates[(k+1):(k+len)] .= rate
            k += len
        end

        if k == proj
            break
        end
    end

    surrender_rates = transpose(hcat([surrender_rates for i in 1:nsims]...))

    return surrender_rates
end


"""
    lookup_surrender(life::SingleLife, surrender_rates::Matrix{Float64})::Matrix{Float64}

Returns surrender rates applicable to a [`Life`](@ref) based on its term in
force (`term_if`).

Provided surrender rates should contain rates from the start of the product to
when `life` would end.
"""
function lookup_surrender(life::SingleLife, surrender_rates::Matrix{Float64})::Matrix{Float64}
    term = (1:life.proj_max) .+ life.term_if
    return @view(surrender_rates[:, term])
end
