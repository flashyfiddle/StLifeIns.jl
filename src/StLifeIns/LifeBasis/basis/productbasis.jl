struct StProductBasis <: ProductBasis
    nsims::Int64
    proj::Int16
    mortality::Dict{Bool, MortalityForecasts}
    surrender_rates::CuArray{Float32, 2}
    cum_infl::CuArray{Float32, 2}
    int_acc::CuArray{Float32, 2}
    v::CuArray{Float32, 2}
    """
        StProductBasis(nsims::Int64, proj::Int16, mortality::Dict{Bool, MortalityForecasts}, surrender_rates::CuArray{Float32, 2}, int::CuArray{Float32, 2}, infl::CuArray{Float32, 2})

    Full basis information for a product. Includes mortality, surrender,
    interest and inflation rates. `int` and `infl` must be monthly
    effective rates.

    Note that proj must be at least as large as the largest
    `proj_max` of a `Life` on further use.

    Also note that rates are stored as `Float32` since they don't need to be
    overly accurate and this saves space on the GPU.
    """
    function StProductBasis(nsims::Int64, proj::Int16, mortality::Dict{Bool, MortalityForecasts}, surrender_rates::Matrix{Float64}, int::Matrix{Float64}, infl::Matrix{Float64})
        int_acc = 1 .+ int
        cum_infl = mapslices(cumprod, 1 .+ infl, dims=2)
        v = 1 ./(int_acc)
        return new(nsims, proj, mortality, surrender_rates, cum_infl, int_acc, v)
    end

    function StProductBasis(nsims::Int64, proj::Int16, mortality::Dict{Bool, MortalityForecasts}, surrender_rates::CuArray{Float32, 2}, cum_infl::CuArray{Float32, 2}, int_acc::CuArray{Float32, 2}, v::CuArray{Float32, 2})
        return new(nsims, proj, mortality, surrender_rates, cum_infl, int_acc, v)
    end
end
