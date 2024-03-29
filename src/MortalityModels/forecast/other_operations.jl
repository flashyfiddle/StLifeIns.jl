function Base.:*(y::Union{Float64, Int64}, x::Dict{Bool, MortalityForecasts})::Dict{Bool, MortalityForecasts}
    return Dict{Bool, MortalityForecasts}(g => MortalityForecasts(i => y*x[g][i] for i in keys(x[g])) for g in keys(x))
end


"""
    getindex(x::Dict{Bool, MortalityForecasts}, i::Union{Int64, UnitRange, Colon}, j::Union{Int64, UnitRange, Colon})::Dict{Bool, MortalityForecasts}

Fetches values at indices provided for a `MortalityForecasts` object.
"""
function Base.getindex(x::Dict{Bool, MortalityForecasts}, i::Union{Int64, UnitRange, Colon}, j::Union{Int64, UnitRange, Colon})::Dict{Bool, MortalityForecasts}
    if i isa Int64
        i = i:i
    end

    if j isa Int64
        j = j:j
    end

    return Dict{Bool, MortalityForecasts}(g => MortalityForecasts(age => x[g][age][i, j] for age in keys(x[g])) for g in [true, false])
end


"""
    vcat(x::Dict{Bool, MortalityForecasts}...)::Dict{Bool, MortalityForecasts}

Concatenates several `MortalityForecasts` objects together as new simulations
(not as projected forward).
"""
function Base.vcat(x::Dict{Bool, MortalityForecasts}...)::Dict{Bool, MortalityForecasts}
    vcatted = x[1]
    for i in 2:length(x)
        new = x[i]
        vcatted = Dict{Bool, MortalityForecasts}(g => MortalityForecasts(age => vcat(vcatted[g][age], new[g][age]) for age in keys(vcatted[g])) for g in keys(vcatted))
    end
    return vcatted
end
