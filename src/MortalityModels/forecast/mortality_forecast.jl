MortalityForecasts = OrderedDict{Int8, Matrix{Float64}}


function empty_mortality_forecast(mortmodel::Dict{Bool, MortalityModel})::Dict{Bool, MortalityForecasts}
    extra = ceil(Int8, YEAR_MON - last(mortmodel.t))
    low_age = first(mortmodel[true].x)

    uxd = OrderedDict{Int8, Matrix{Float64}}()
    t = extra
    for x in low_age:(MAX_AGE-1)
        uxd[x] = Matrix{Float64}(undef, 0, t)
        t += 1
    end

    return Dict(true=>uxd, false=>uxd)
end


function simulate_mortality(mf_mortmodel::Dict{Bool, MortalityModel}, nsims::Int64)::Dict{Bool, MortalityForecasts}
    return Dict(gender => simulate(mf_mortmodel[gender], nsims) for gender in [true, false])
end


function forecast_mortality(mf_mortmodel::Dict{Bool, MortalityModel})::Dict{Bool, MortalityForecasts}
    return Dict(gender => forecast(mf_mortmodel[gender]) for gender in [true, false])
end
