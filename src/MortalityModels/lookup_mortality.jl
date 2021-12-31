function lookup_mortality(life::SingleLife, mortmodel_forecasts_dict::Dict{Bool, MortalityForecasts}, nsims::Int64, proj_max::Int16)::Matrix{Float64}
    mortmodel_forecasts = mortmodel_forecasts_dict[life.male]
    year_age_len = mortality_lens(life)
    μ = Matrix{Float64}(undef, nsims, Int64(proj_max))
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


MortalityLengths = OrderedDict{Int8, OrderedDict{Int8, Int8}}

function mortality_lens(life::SingleLife)::MortalityLengths
    time_ahead = YEAR_MON - floor(YEAR_MON)
    first_year = 1
    last_year = ceil(Int8, time_ahead + life.proj_max/12)
    year_age_len = OrderedDict(i=>OrderedDict{Int8, Int8}() for i in first_year:last_year)

    current_age = floor(Int8, life.age)
    time_current_age = round(Int8, 12(current_age+1 - life.age))
    time_current_year = round(Int8, min(12*(first_year - time_ahead), life.proj_max))

    if time_current_age < time_current_year
        year_age_len[first_year][current_age] = time_current_age
        time_current_year -= time_current_age
        current_age, time_current_age = current_age+1, 12
    end
    year_age_len[first_year][current_age] = time_current_year
    time_current_age -= time_current_year
    time_current_year = 12
    if time_current_age == 0
        current_age, time_current_age = current_age+1, 12
    end

    if first_year != last_year
        between_years = (first_year+1):(last_year-1)
        if time_current_age == 12
            for i in between_years
                year_age_len[i][current_age] = time_current_age
                current_age += 1
            end
        else
            for i in between_years
                year_age_len[i][current_age] = time_current_age
                current_age += 1
                year_age_len[i][current_age] = 12 - time_current_age
            end
        end

        time_furthest_forecast = time_ahead + life.proj_max/12
        time_current_year = round(Int8, 12*(time_furthest_forecast-last_year+1))
        if time_current_age < time_current_year
            year_age_len[last_year][current_age] = time_current_age
            time_current_year -= time_current_age
            current_age, time_current_age = current_age+1, 12
        end
        year_age_len[last_year][current_age] = time_current_year
    end
    return year_age_len
end
