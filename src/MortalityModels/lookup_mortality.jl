"""
    lookup_mortality(life::SingleLife, mortmodel_forecasts_dict::Dict{Bool, MortalityForecasts}, nsims::Int64, proj_max::Int16)::Matrix{Float64}

Returns a monthly mortality `Matrix{Float64}` applicable to a
[`SingleLife`](@ref) with each row denoting a different simulation and each
column representing the mortality applicable at that time.

The lookup of mortality is based on the [`mortality_lens`](@ref) function which
provides the number of months spent at each age in each year - sufficient
information for [`GAPC`](@ref) (Generalised Age-Period-Cohort) models.

Note that a constant force of mortality is assumed at every unique combination
of age and year. There is no smoothing. Hence, mortality will be seen to jump
every time age, year or both change.

See also [`MortalityForecasts`](@ref), [`MortalityLengths`](@ref)
"""
function lookup_mortality(life::SingleLife, mortmodel_forecasts_dict::Dict{Bool, MortalityForecasts}, nsims::Int64, proj_max::Int16)::Matrix{Float64}
    mortmodel_forecasts = mortmodel_forecasts_dict[life.male]
    year_age_len = mortality_lens(life)
    μ = Matrix{Float64}(undef, nsims, Int64(proj_max))
    k = 0
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

"""
    mortality_lens(life::SingleLife)::MortalityLengths

Returns a [`MortalityLengths`](@ref) object containing the number of months
spent at each age in each year for a [`SingleLife`](@ref).

See also [`lookup_mortality`](@ref).
"""
function mortality_lens(life::SingleLife)::MortalityLengths
    time_ahead = YEAR_MON - floor(round(YEAR_MON, digits=7))
    first_year = 1
    last_year = ceil(Int8, round(time_ahead + life.proj_max/12, digits=7))
    year_age_len = OrderedDict(i=>OrderedDict{Int8, Int8}() for i in first_year:last_year)

    current_age = floor(Int8, round(life.age, digits=7))
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
