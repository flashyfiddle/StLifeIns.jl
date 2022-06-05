function forecast_mortality(mortmodel::LeeCarter, skip_extra=false::Bool)::MortalityForecasts
    extra = ceil(Int8, YEAR_MON - last(mortmodel.t))-1
    low_age, high_age = first(mortmodel.x), last(mortmodel.x)
    n = high_age-low_age+1+extra
    κt = forecast_arima(mortmodel.κt, n)

    uxd = OrderedDict{Int8, Matrix{Float64}}()
    for x in low_age:(high_age-1)
        j = x-low_age+1
        t = ifelse(skip_extra, (extra+1):(x-low_age+1+extra), 1:(x-low_age+1+extra))
        @views uxd[x] = exp.(mortmodel.αx[j] .+ mortmodel.βx[j]*κt[:, t])/12
    end

    return uxd
end


function simulate_mortality(mortmodel::LeeCarter, nsims::Int64, skip_extra=false::Bool)::MortalityForecasts
    extra = ceil(Int8, YEAR_MON - last(mortmodel.t))-1
    low_age, high_age = first(mortmodel.x), last(mortmodel.x)
    n = high_age-low_age+1+extra
    κt = simulate_arima(mortmodel.κt, n, nsims)

    uxd = OrderedDict{Int8, Matrix{Float64}}()
    for x in low_age:(high_age-1)
        j = x-low_age+1
        t = ifelse(skip_extra, (extra+1):(x-low_age+1+extra), 1:(x-low_age+1+extra))
        @views uxd[x] = exp.(mortmodel.αx[j] .+ mortmodel.βx[j]*κt[:, t])/12
    end

    return uxd
end
