function forecast_mortality(mortmodel::Plat)::MortalityForecasts
    extra = ceil(Int8, YEAR_MON - last(mortmodel.t))-1
    low_age = first(mortmodel.x)
    n = MAX_AGE-low_age+1+extra
    κt1, κt2, κt3 = forecast_arima.(mortmodel.κt, n)
    γc = forecast_arima(mortmodel.γc, extra+1, true)
    m = size(γc, 2)

    xbar = mean(mortmodel.x)
    βx2 = xbar .- mortmodel.x
    βx3 = max.(xbar .- mortmodel.x, 0)

    uxd = OrderedDict{Int8, Matrix{Float64}}()
    for x in low_age:(MAX_AGE-1)
        j = x-low_age+1
        t = (extra+1):(x-low_age+1+extra)
        k = (m+low_age-x):m
        @views uxd[x] = exp.(mortmodel.αx[j] .+ κt1[:, t] .+ βx2[j]*κt2[:, t] .+ βx3[j]*κt3[:, t] .+ γc[:, k])/12
    end

    return uxd
end


function simulate_mortality(mortmodel::Plat, nsims::Int64)::MortalityForecasts
    extra = ceil(Int8, YEAR_MON - last(mortmodel.t))-1
    low_age = first(mortmodel.x)
    n = MAX_AGE-low_age+1+extra
    κt1, κt2, κt3 = simulate_arima.(mortmodel.κt, n, nsims)
    γc = simulate_arima(mortmodel.γc, extra+1, nsims, true)
    m = size(γc, 2)

    xbar = mean(mortmodel.x)
    βx2 = xbar .- mortmodel.x
    βx3 = max.(xbar .- mortmodel.x, 0)

    uxd = OrderedDict{Int8, Matrix{Float64}}()
    for x in low_age:(MAX_AGE-1)
        j = x-low_age+1
        t = (extra+1):(x-low_age+1+extra)
        k = (m+low_age-x):m
        @views uxd[x] = exp.(mortmodel.αx[j] .+ κt1[:, t] .+ βx2[j]*κt2[:, t] .+ βx3[j]*κt3[:, t] .+ γc[:, k])/12
    end

    return uxd
end
