MortalityForecastsGPU = OrderedDict{Int8, CuArray{Float32, 2}}

"""
    lookup_mortality(life::Life, mortmodel_forecasts_dict::Dict{Bool, MortalityForecastsGPU}, nsims::Int64, proj_max::Int16)::CuArray{Float32, 2}

Returns a monthly mortality `CuArray{Float32, 2}` applicable to a
[`SingleLife`](@ref) with each row denoting a different simulation and each
column representing the mortality applicable at that time.

The lookup of mortality is based on the [`mortality_lens`](@ref) function which
provides the number of months spent at each age in each year - sufficient
information for [`GAPC`](@ref) (Generalised Age-Period-Cohort) models.

Note that a constant force of mortality is assumed at every unique combination
of age and year. There is no smoothing. Hence, mortality will be seen to jump
every time age, year or both change.

See also [`MortalityForecastsGPU`](@ref), [`MortalityLengths`](@ref)
"""
function lookup_mortality(life::Life, mortmodel_forecasts_dict::Dict{Bool, MortalityForecastsGPU}, nsims::Int64, proj_max::Int16)::CuArray{Float32, 2}
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
