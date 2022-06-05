using Setfield: @set

# simulates scenarios with combinations of different models each with n simualtions
function simulate_model_combinations(mortmodel_names, intmodel_names, int_start, inflmodel_names, infl_start, n, proj)
    mortality = empty_mortality_forecast(mortmodel_dict[mortmodel_names[1]]) # create struct with empty arrays
    int = Matrix{Float64}(undef, 0, proj)
    infl = Matrix{Float64}(undef, 0, proj)
    for mortmodel_name in mortmodel_names
        mortmodel = mortmodel_dict[mortmodel_name]
        for intmodel_name in intmodel_names
            intmodel = intmodel_dict[intmodel_name]
            for infl_model_name in inflmodel_names
                inflmodel = inflmodel_dict[infl_model_name]
                new_mortality = simulate_mortality(mortmodel, n)
                new_int, new_infl = simulate_int_infl(int_start, intmodel, infl_start, inflmodel, n, proj, 1/12)
                mortality = vcat(mortality, new_mortality)
                int, infl = vcat(int, new_int), vcat(infl, new_infl)
            end
        end
    end
    return mortality, int, infl
end


# forecasts scenarios with combinations of different models
function forecast_model_combinations(mortmodel_names, intmodel_names, int_start, inflmodel_names, infl_start, proj)
    mortality = empty_mortality_forecast(mortmodel_dict[mortmodel_names[1]]) # create struct with empty arrays
    int = Matrix{Float64}(undef, 0, proj)
    infl = Matrix{Float64}(undef, 0, proj)
    for mortmodel_name in mortmodel_names
        mortmodel = mortmodel_dict[mortmodel_name]
        for intmodel_name in intmodel_names
            intmodel = intmodel_dict[intmodel_name]
            for infl_model_name in inflmodel_names
                inflmodel = inflmodel_dict[infl_model_name]
                new_mortality = forecast_mortality(mortmodel)
                new_int, new_infl = forecast_int_infl(int_start, intmodel, infl_start, inflmodel, proj, 1/12)
                mortality = vcat(mortality, new_mortality)
                int, infl = vcat(int, new_int), vcat(infl, new_infl)
            end
        end
    end
    return mortality, int, infl
end


# includes an interest rate adjustment before simulation
function simulate_model_combinations_adj(mortmodel_names, intmodel_names, int_start, inflmodel_names, infl_start, n, proj, int_adj)
    mortality = empty_mortality_forecast(mortmodel_dict[mortmodel_names[1]]) # create struct with empty arrays
    int = Matrix{Float64}(undef, 0, proj)
    infl = Matrix{Float64}(undef, 0, proj)
    for mortmodel_name in mortmodel_names
        mortmodel = mortmodel_dict[mortmodel_name]
        for intmodel_name in intmodel_names
            intmodel = intmodel_dict[intmodel_name]
            intmodel = @set intmodel.β = intmodel.β + int_adj
            for infl_model_name in inflmodel_names
                inflmodel = inflmodel_dict[infl_model_name]
                new_mortality = simulate_mortality(mortmodel, n)
                new_int, new_infl = simulate_int_infl(int_start, intmodel, infl_start, inflmodel, n, proj, 1/12)
                mortality = vcat(mortality, new_mortality)
                int, infl = vcat(int, new_int), vcat(infl, new_infl)
            end
        end
    end
    return mortality, int, infl
end


# includes an interest rate adjustment before simulation
function forecast_model_combinations_adj(mortmodel_names, intmodel_names, int_start, inflmodel_names, infl_start, proj, int_adj)
    mortality = empty_mortality_forecast(mortmodel_dict[mortmodel_names[1]]) # create struct with empty arrays
    int = Matrix{Float64}(undef, 0, proj)
    infl = Matrix{Float64}(undef, 0, proj)
    for mortmodel_name in mortmodel_names
        mortmodel = mortmodel_dict[mortmodel_name]
        for intmodel_name in intmodel_names
            intmodel = intmodel_dict[intmodel_name]
            intmodel = @set intmodel.β = intmodel.β + int_adj
            for infl_model_name in inflmodel_names
                inflmodel = inflmodel_dict[infl_model_name]
                new_mortality = forecast_mortality(mortmodel)
                new_int, new_infl = forecast_int_infl(int_start, intmodel, infl_start, inflmodel, proj, 1/12)
                mortality = vcat(mortality, new_mortality)
                int, infl = vcat(int, new_int), vcat(infl, new_infl)
            end
        end
    end
    return mortality, int, infl
end


function mean_model_forecast(mortmodel_names, intmodel_names, int_start, inflmodel_names, infl_start, proj)
    mortality, int, infl = forecast_model_combinations(mortmodel_names, intmodel_names, int_start, inflmodel_names, infl_start, proj)
    mean_mortality, mean_int, mean_infl = get_means(mortality, int, infl)

    return mean_mortality, mean_int, mean_infl
end


function mean_model_forecast_adj(mortmodel_names, intmodel_names, int_start, inflmodel_names, infl_start, proj, int_adj)
    mortality, int, infl = forecast_model_combinations_adj(mortmodel_names, intmodel_names, int_start, inflmodel_names, infl_start, proj, int_adj)
    mean_mortality, mean_int, mean_infl = get_means(mortality, int, infl)

    return mean_mortality, mean_int, mean_infl
end

function get_means(mortality, int, infl)
    mean_int, mean_infl = mean.(eachcol(int)), mean.(eachcol(infl))

    mean_int = convert(Matrix{Float64}, transpose(mean_int[:, :]))
    mean_infl = convert(Matrix{Float64}, transpose(mean_infl[:, :]))

    mean_mortality = Dict(g => MortalityForecasts(age => transpose(mean.(eachcol(mortality[g][age]))) for age in keys(mortality[g])) for g in [true, false])

    return mean_mortality, mean_int, mean_infl
end


function mean(x)
    return sum(x)/length(x)
end


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
