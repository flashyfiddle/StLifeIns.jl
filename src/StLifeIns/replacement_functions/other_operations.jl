function Base.:*(y::Union{Float64, Int64}, x::Union{Dict{Bool, MortalityForecasts}, Dict{Bool, MortalityForecastsGPU}})::Union{Dict{Bool, MortalityForecasts}, Dict{Bool, MortalityForecastsGPU}}
    if useGPU
        return Dict{Bool, MortalityForecastsGPU}(g => MortalityForecastsGPU(i => y*x[g][i] for i in keys(x[g])) for g in keys(x))
    else
        return Dict{Bool, MortalityForecasts}(g => MortalityForecasts(i => y*x[g][i] for i in keys(x[g])) for g in keys(x))
    end
end


function Base.getindex(x::Union{Dict{Bool, MortalityForecasts}, Dict{Bool, MortalityForecastsGPU}}, i::Union{Int64, UnitRange, Colon}, j::Union{Int64, UnitRange, Colon})::Union{Dict{Bool, MortalityForecasts}, Dict{Bool, MortalityForecastsGPU}}
    if i isa Int64
        i = i:i
    end

    if j isa Int64
        j = j:j
    end

    if useGPU
        return Dict{Bool, MortalityForecastsGPU}(g => MortalityForecastsGPU(age => x[g][age][i, j] for age in keys(x[g])) for g in [true, false])
    else
        return Dict{Bool, MortalityForecasts}(g => MortalityForecasts(age => x[g][age][i, j] for age in keys(x[g])) for g in [true, false])
    end
end


function Base.vcat(x::Union{Dict{Bool, MortalityForecasts}, Dict{Bool, MortalityForecastsGPU}}...)::Union{Dict{Bool, MortalityForecasts}, Dict{Bool, MortalityForecastsGPU}}
    vcatted = x[1]

    if useGPU
        for i in 2:length(x)
            new = x[i]
            vcatted = Dict{Bool, MortalityForecastsGPU}(g => MortalityForecastsGPU(age => vcat(vcatted[g][age], new[g][age]) for age in keys(vcatted[g])) for g in keys(vcatted))
        end
        return vcatted
    else
        for i in 2:length(x)
            new = x[i]
            vcatted = Dict{Bool, MortalityForecasts}(g => MortalityForecasts(age => vcat(vcatted[g][age], new[g][age]) for age in keys(vcatted[g])) for g in keys(vcatted))
        end
        return vcatted
    end
end
