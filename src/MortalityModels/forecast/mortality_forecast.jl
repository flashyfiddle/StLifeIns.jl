MortalityForecasts = OrderedDict{Int8, Matrix{Float64}}


"""
    empty_mortality_forecast(mortmodel::Dict{Bool, GAPC}, skip_extra=true::Bool)::Dict{Bool, MortalityForecasts}

Provides an empty `MortalityForecasts` object with all ages and dimensions
required for each age to reach `MAX_AGE`.

Useful as a starting point for concatenating several MortalityForecasts.
"""
function empty_mortality_forecast(mortmodel::Dict{Bool, GAPC}, skip_extra=true::Bool)::Dict{Bool, MortalityForecasts}
    if skip_extra
        low_age = first(mortmodel[true].x)
        uxd = OrderedDict{Int8, Matrix{Float64}}()
        t = 1
        for x in low_age:(MAX_AGE-1)
            uxd[x] = Matrix{Float64}(undef, 0, t)
            t += 1
        end
        return Dict(true=>uxd, false=>uxd)

    else
        empty = Dict{Bool, OrderedDict{Int8, Matrix{Float64}}}()
        for gender in [0, 1]
            model = mortmodel[gender]
            extra = ceil(Int8, YEAR_MON - last(model.t))-1
            low_age = first(model.x)
            uxd = OrderedDict{Int8, Matrix{Float64}}()
            t = extra+1
            for x in low_age:(MAX_AGE-1)
                uxd[x] = Matrix{Float64}(undef, 0, t)
                t += 1
            end
            empty[gender] = uxd
        end
        return empty
    end
end


"""
    simulate_mortality(mf_mortmodel::Dict{Bool, GAPC}, nsims::Int64, skip_extra=true::Bool)::Dict{Bool, MortalityForecasts}

Simulates `nsims` of both the male and female [`GAPC`](@ref) [`MortalityModel`]s
providing simulations of mortality for each age until that age reaches `MAX_AGE`
(see [`setMAX_AGE`](@ref)).

`skip_extra` can be used to simulate and skip the gap between the last fitted
data and the current date. If `false`, mortality data will still be simulated,
but will also be included in output. Default is `skip_extra=true`.
"""
function simulate_mortality(mf_mortmodel::Dict{Bool, GAPC}, nsims::Int64, skip_extra=true::Bool)::Dict{Bool, MortalityForecasts}
    return Dict(gender => simulate_mortality(mf_mortmodel[gender], nsims, skip_extra) for gender in [true, false])
end


"""
    forecast_mortality(mf_mortmodel::Dict{Bool, GAPC}, skip_extra=true::Bool)::Dict{Bool, MortalityForecasts}

Forecasts the expected value of both the male and female [`GAPC`](@ref) [`MortalityModel`]s
providing a forecast of mortality for each age until that age reaches `MAX_AGE`
(see [`setMAX_AGE`](@ref)).

`skip_extra` can be used to forecast and skip the gap between the last fitted
data and the current date. If `false`, mortality data will still be forecasted,
but will also be included in output. Default is `skip_extra=true`.
"""
function forecast_mortality(mf_mortmodel::Dict{Bool, GAPC}, skip_extra=true::Bool)::Dict{Bool, MortalityForecasts}
    return Dict(gender => forecast_mortality(mf_mortmodel[gender], skip_extra) for gender in [true, false])
end
