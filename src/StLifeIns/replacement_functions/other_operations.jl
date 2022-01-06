function Base.:*(y::Union{Float64, Int64}, x::Dict{Bool, MortalityForecastsGPU})::Dict{Bool, MortalityForecastsGPU}
    return Dict(g => OrderedDict{Int8, Matrix{Float64}}(i => y*x[g][i] for i in keys(x[g])) for g in keys(x))
end


function Base.getindex(x::Dict{Bool, MortalityForecastsGPU}, i::Union{Int64, UnitRange, Colon}, j::Union{Int64, UnitRange, Colon})
    if i isa Int64
        i = i:i
    end

    if j isa Int64
        j = j:j
    end

    return Dict(g => OrderedDict(age => x[g][age][i, j] for age in keys(x[g])) for g in [true, false])
end


function Base.vcat(x::Dict{Bool, MortalityForecastsGPU}...)::Dict{Bool, MortalityForecastsGPU}
    vcatted = x[1]
    for i in 2:length(x)
        new = x[i]
        vcatted = Dict{Bool, MortalityForecastsGPU}(g => MortalityForecastsGPU(age => vcat(vcatted[g][age], new[g][age]) for age in keys(vcatted[g])) for g in keys(vcatted))
    end
    return vcatted
end
