BigProbabilityDictGPU = Dict{Contingency, CuArray{Float32, 2}}


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


function dependent_probabilities(pb::PolicyBasis)::BigProbabilityDictGPU
    return dependent_probabilities(pb.μ, pb.σ, pb.proj_max, pb.whole_life)
end
