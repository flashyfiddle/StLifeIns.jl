function simulate_int_infl(int_start::Float64, int_model::InterestModel, infl_start::Float64, infl_model::InflationModel, nsims::Int64, proj::Int16, dt::Float64)::Tuple{Matrix{Float64}, Matrix{Float64}}
    extra = Int16(12*(YEAR_MON - last(int_model.t))) # last fitted time should be the same for the interest and inflation model
    int_sim = simulate_interest(int_start, int_model, nsims, proj+extra, dt)
    infl_sim = simulate_inflation(infl_start, infl_model, int_sim, nsims, proj+extra)
    return int_sim[:, (2+extra):end], infl_sim[:, (1+extra):end] # int_sim has first column as last known interest so int.l1 can be used in regression for inflation
end


function forecast_int_infl(int_start::Float64, int_model::InterestModel, infl_start::Float64, infl_model::InflationModel, proj::Int16, dt::Float64)::Tuple{Matrix{Float64}, Matrix{Float64}}
    extra = Int16(12*(YEAR_MON - last(int_model.t))) # last fitted time should be the same for the interest and inflation model
    int_sim = forecast_interest(int_start, int_model, proj+extra, dt)
    infl_sim = forecast_inflation(infl_start, infl_model, int_sim, proj+extra)
    return int_sim[:, (2+extra):end], infl_sim[:, (1+extra):end] # int_sim has first column as last known interest so int.l1 can be used in regression for inflation
end
