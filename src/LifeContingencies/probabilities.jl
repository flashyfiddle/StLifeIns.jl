BigProbabilityDict = Dict{Contingency, Matrix{Float64}}

"""
    dependent_probabilities(μ::Matrix{Float64}, σ::Matrix{Float64}, proj_max::Int16, whole_life::Bool)

Returns the dependent probabilities relating to each [`Contingency`](@ref).

This calculates and returns the dependent decrement probabilities where death
and termination are competing decrements. Provided forces of transition should
be monthly rates and should be provided for each month.

...
# Arguments
- `μ::Matrix{Float64}`: each row contains the monthly forces of mortality provided for all months for a simulation.
- `σ::Matrix{Float64}`: each row contains the monthly surrender transition rate provided for all months for a simulation.
- `proj_max::Int16`: the number of months forward for which probabilities are requierd.
- `whole_life::Bool`: an indication of whether death should be guaranteed in the last month (if so then `true`).
...
"""
function dependent_probabilities(μ::Matrix{Float64}, σ::Matrix{Float64}, proj_max::Int16, whole_life::Bool)::BigProbabilityDict
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
