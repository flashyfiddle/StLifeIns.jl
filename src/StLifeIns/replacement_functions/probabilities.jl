BigProbabilityDictGPU = Dict{Contingency, CuArray{Float32, 2}}


"""
    dependent_probabilities(μ::CuArray{Float32, 2}, σ::CuArray{Float32, 2}, proj_max::Int16, whole_life::Bool)::BigProbabilityDictGPU

Returns the dependent probabilities relating to each [`Contingency`](@ref).

This calculates and returns the dependent decrement probabilities where death
and termination are competing decrements. Provided forces of transition should
be monthly rates and should be provided for each month.

Rates are Float32 to save memory on the GPU. Mortality rates from mortality
tables don't tend to have more than 7 decimals, so this shouldn't be reducing
accuracy.

...
# Arguments
- `μ::CuArray{Float32, 2}`: each row contains the monthly forces of mortality provided for all months for a simulation.
- `σ::CuArray{Float32, 2}`: each row contains the monthly surrender transition rate provided for all months for a simulation.
- `proj_max::Int16`: the number of months forward for which probabilities are requierd.
- `whole_life::Bool`: an indication of whether death should be guaranteed in the last month (if so then `true`).
...
"""
function dependent_probabilities(μ::CuArray{Float32, 2}, σ::CuArray{Float32, 2}, proj_max::Int16, whole_life::Bool)::BigProbabilityDictGPU
    apx = exp.(-(μ .+ σ))
    aqxd = μ ./(μ .+ σ) .*(1 .- apx)
    aqxw = 1 .- apx .- aqxd

    if whole_life
        apx[:, proj_max] .= 0
        aqxd[:, proj_max] .= 1
        aqxw[:, proj_max] .= 0
    end


    return Dict(InForce() => apx, OnDeath() => aqxd, OnTermination() => aqxw)
end


"""
    dependent_probabilities(pb::PolicyBasis)::Union{(BigProbabilityDict, BigProbabilityDictGPU)}

Returns the dependent probabilities relating to each [`Contingency`](@ref).

This calculates and returns the dependent decrement probabilities where death
and termination are competing decrements. Provided forces of transition should
be monthly rates and should be provided for each month.

Rates are Float32 to save memory on the GPU. Mortality rates from mortality
tables don't tend to have more than 7 decimals, so this shouldn't be reducing
accuracy.

"""
function dependent_probabilities(pb::PolicyBasis)::Union{(BigProbabilityDict, BigProbabilityDictGPU)}
    return dependent_probabilities(pb.μ, pb.σ, pb.proj_max, pb.whole_life)
end
