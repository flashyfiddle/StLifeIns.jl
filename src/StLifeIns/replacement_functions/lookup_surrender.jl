"""
    lookup_surrender(life::SingleLife, surrender_rates::CuArray{Float32})::CuArray{Float32}

Returns surrender rates applicable to a [`Life`](@ref) based on its term in
force (`term_if`).

Provided surrender rates should contain rates from the start of the product to
when `life` would end.
"""
function lookup_surrender(life::SingleLife, surrender_rates::CuArray{Float32})::CuArray{Float32}
    term = (1:life.proj_max) .+ life.term_if
    return @view(surrender_rates[:, term])
end
