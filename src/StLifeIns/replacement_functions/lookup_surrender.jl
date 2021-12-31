function lookup_surrender(life::SingleLife, surrender_rates::CuArray{Float32})
    term = (1:life.proj_max) .+ life.term_if
    return @view(surrender_rates[:, term])
end
