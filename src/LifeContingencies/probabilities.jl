BigProbabilityDict = Dict{Contingency, Matrix{Float64}}


function dependent_probabilities(μ::Matrix{Float64}, σ::Matrix{Float64}, proj_max::Int16, whole_life::Bool)::BigProbabilityDict
    apx = exp.(-(μ .+ σ))
    aqxd = μ ./(μ .+ σ) .*(1 .- apx)

    if all(μ[:, proj_max] == Inf) # unless σ[:, proj_max] = Inf in which case chaos
        aqxd[:, proj_max] .= 1
    end

    aqxw = 1 .- apx .- aqxd

    return Dict(InForce() => apx, OnDeath() => aqxd, OnTermination() => aqxw)
end
