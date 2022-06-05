struct StProductBasis <: ProductBasis
    nsims::Int64
    proj::Int16
    mortality::Union{(Dict{Bool, MortalityForecasts}, Dict{Bool, MortalityForecastsGPU})}
    surrender_rates::Union{(Matrix{Float64}, CuArray{Float32, 2})}
    cum_infl::Union{(Matrix{Float64}, CuArray{Float32, 2})}
    int_acc::Union{(Matrix{Float64}, CuArray{Float32, 2})}
    v::Union{(Matrix{Float64}, CuArray{Float32, 2})}
    """
        StProductBasis(nsims::Int64, proj::Int16, mortality::Dict{Bool, MortalityForecasts}, surrender_rates::Matrix{Float64}, int::Matrix{Float64}, infl::Matrix{Float64})

    Full basis information for a product. Includes mortality, surrender,
    interest and inflation rates. `int` and `infl` must be monthly effective
    rates.

    Note that proj must be at least as large as the largest `proj_max` of a
    [`Life`](@ref) on further use.
    """
    function StProductBasis(nsims::Int64, proj::Int16, mortality::Dict{Bool, MortalityForecasts}, surrender_rates::Matrix{Float64}, int::Matrix{Float64}, infl::Matrix{Float64})
        int_acc = 1 .+ int
        cum_infl = mapslices(cumprod, 1 .+ infl, dims=2)
        v = 1 ./(int_acc)

        if useGPU
            mortality = convert(Dict{Bool, MortalityForecastsGPU}, mortality)
            surrender_rates = convert(CuArray{Float32, 2}, surrender_rates)
            cum_infl = convert(CuArray{Float32, 2}, cum_infl)
            int_acc = convert(CuArray{Float32, 2}, int_acc)
            v = convert(CuArray{Float32, 2}, v)
        end

        return new(nsims, proj, mortality, surrender_rates, cum_infl, int_acc, v)
    end

    function StProductBasis(nsims::Int64, proj::Int16, mortality::Dict{Bool, MortalityForecastsGPU}, surrender_rates::CuArray{Float32, 2}, cum_infl::CuArray{Float32, 2}, int_acc::CuArray{Float32, 2}, v::CuArray{Float32, 2})
        return new(nsims, proj, mortality, surrender_rates, cum_infl, int_acc, v)
    end

    function StProductBasis(nsims::Int64, proj::Int16, mortality::Dict{Bool, MortalityForecasts}, surrender_rates::Matrix{Float64}, cum_infl::Matrix{Float64}, int_acc::Matrix{Float64}, v::Matrix{Float64})
        return new(nsims, proj, mortality, surrender_rates, cum_infl, int_acc, v)
    end
end
