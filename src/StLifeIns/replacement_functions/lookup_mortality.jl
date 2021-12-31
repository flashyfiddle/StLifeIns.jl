MortalityForecasts = OrderedDict{Int8, CuArray{Float32, 2}}

function lookup_mortality(life::Life, mortmodel_forecasts_dict::Dict{Bool, MortalityForecasts}, nsims::Int64, proj_max::Int16)::CuArray{Float32, 2}
    mortmodel_forecasts = mortmodel_forecasts_dict[life.male]
    year_age_len = mortality_lens(life)
    μ = CuArray{Float32, 2}(undef, nsims, Int64(proj_max))
    k=0
    for (year, age_len) in year_age_len
        for (age, len) in age_len
            @views mort = mortmodel_forecasts[age][:, year]
            for i in (k+1):(k+len)
                @inbounds μ[:, i] = mort
            end
            k += len
        end
    end
    return μ
end
