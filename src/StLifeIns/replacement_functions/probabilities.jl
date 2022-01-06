BigProbabilityDictGPU = Dict{Contingency, CuArray{Float32, 2}}


function dependent_probabilities(μ::CuArray{Float32, 2}, σ::CuArray{Float32, 2}, proj_max::Int16)::BigProbabilityDictGPU
    apx = exp.(-(μ .+ σ))
    aqxd = μ ./(μ .+ σ) .*(1 .- apx)

    if all(μ[:, proj_max] == Inf) # unless σ[:, proj_max] = Inf in which case chaos
        aqxd[:, proj_max] .= 1
    end

    aqxw = 1 .- apx .- aqxd

    return Dict(InForce() => apx, OnDeath() => aqxd, OnTermination() => aqxw)
end


function dependent_probabilities(pb::PolicyBasis)::BigProbabilityDictGPU
    return dependent_probabilities(pb.μ, pb.σ, pb.proj_max)
end
