BigProbabilityDict = Dict{Contingency, Matrix{Float64}}


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
