MortalityForecasts = OrderedDict{Int8, Matrix{Float64}}


function empty_mortality_forecast(mortmodel::Dict{Bool, GAPC}, skip_extra=true::Bool)::Dict{Bool, MortalityForecasts}
    extra = ceil(Int8, YEAR_MON - last(mortmodel.t))-1
    low_age = first(mortmodel[true].x)

    uxd = OrderedDict{Int8, Matrix{Float64}}()
    t = ifelse(skip_extra, 1, extra+1)
    for x in low_age:(MAX_AGE-1)
        uxd[x] = Matrix{Float64}(undef, 0, t)
        t += 1
    end

    return Dict(true=>uxd, false=>uxd)
end


function simulate_mortality(mf_mortmodel::Dict{Bool, GAPC}, nsims::Int64, skip_extra=true::Bool)::Dict{Bool, MortalityForecasts}
    return Dict(gender => simulate_mortality(mf_mortmodel[gender], nsims, skip_extra) for gender in [true, false])
end


function forecast_mortality(mf_mortmodel::Dict{Bool, GAPC}, skip_extra=true::Bool)::Dict{Bool, MortalityForecasts}
    return Dict(gender => forecast_mortality(mf_mortmodel[gender], skip_extra) for gender in [true, false])
end
