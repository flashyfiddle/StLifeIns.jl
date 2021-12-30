function forecast_mortality(mortmodel::LeeCarter)::MortalityForecasts
    extra = ceil(Int8, YEAR_MON - last(mortmodel.t))-1
    low_age = first(mortmodel.x)
    n = MAX_AGE-low_age+1+extra
    κt = forecast_arima(mortmodel.κt, n)

    uxd = OrderedDict{Int8, Matrix{Float64}}()
    for x in low_age:(MAX_AGE-1)
        j = x-low_age+1
        t = (extra+1):(x-low_age+1+extra)
        @views uxd[x] = exp.(mortmodel.αx[j] .+ mortmodel.βx[j]*κt[:, t])/12
    end

    return uxd
end


function simulate_mortality(mortmodel::LeeCarter, nsims::Int64)::MortalityForecasts
    extra = ceil(Int8, YEAR_MON - last(mortmodel.t))-1
    low_age = first(mortmodel.x)
    n = MAX_AGE-low_age+1+extra
    κt = simulate_arima(mortmodel.κt, n, nsims)

    uxd = OrderedDict{Int8, Matrix{Float64}}()
    for x in low_age:(MAX_AGE-1)
        j = x-low_age+1
        t = (extra+1):(x-low_age+1+extra)
        @views uxd[x] = exp.(mortmodel.αx[j] .+ mortmodel.βx[j]*κt[:, t])/12
    end

    return uxd
end
