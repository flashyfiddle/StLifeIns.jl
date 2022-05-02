struct StochasticReserveCalcs
    policy::StandardPolicy
    policy_basis::PolicyBasis
    prob::Union{BigProbabilityDict, BigProbabilityDictGPU}
    cfs::CompleteCashflows
    reserves::Union{Matrix{Float64}, CuArray{Float64, 2}}
end

"""
    reserves(policies::Vector{StandardPolicy}, basis::ProductBasis)::Union{Matrix{Float64}, CuArray{Float64, 2}}

Returns a `CuArray{Float64, 2}` of the collective expected reserve to be held
over the provided policies for each basis simulation at the start of each month.
Rows represent simulations and columns represent months.

The `ProductBasis` will operate on all provided `policies`. Where different
products require separate bases, `reserves` should be called
separately for these products.

"""
function reserves(policies::Vector{StandardPolicy}, basis::ProductBasis)::Union{Matrix{Float64}, CuArray{Float64, 2}}
    nsims, mproj_max = basis.nsims, basis.proj

    if useGPU
        res = CUDA.zeros(Float64, nsims, mproj_max)
    else
        res = zeros(Float64, nsims, mproj_max)
    end

    if useGPU
        res = CUDA.zeros(Float64, nsims, mproj_max)
        for policy in policies
            res_calc = reserves(policy, basis)
            x = res_calc.reserves
            @inbounds res[indices(x)...] += x
        end
    else
        res = zeros(Float64, nsims, mproj_max)
        Threads.@threads for policy in policies
            res_calc = reserves(policy, basis)
            x = res_calc.reserves
            @inbounds res[indices(x)...] += x
        end
    end

    return res
end


"""
    reserves(policy::StandardPolicy, basis::ProductBasis)

Returns a `StochasticReserveCalcs` which contains completed intermediary
calculations alongside the expected reserves for each basis simulation at the
start of each month. Rows represent simulations and columns represent months.

"""
function reserves(policy::StandardPolicy, basis::ProductBasis)::StochasticReserveCalcs
    pb = PolicyBasis(policy.life, basis)
    cfs = complete_inflate(policy.expenses, vcat(policy.premiums, policy.benefits, policy.penalties), pb.cum_infl, pb.proj_max)
    prob = dependent_probabilities(pb)
    reserves = iterate_reserves(cfs, prob, pb)
    return StochasticReserveCalcs(policy, pb, prob, cfs, reserves)
end

"""
    iterate_reserves(cfs::CompleteCashflows, prob::Union{BigProbabilityDict, BigProbabilityDictGPU}, pb::PolicyBasis)::Union{Matrix{Float64}, CuArray{Float64, 2}}

Returns a matrix of expected reserves for each simulation at each month. The
reserve at each month assumes that the policy is still in force.
"""
function iterate_reserves(cfs::CompleteCashflows, prob::Union{BigProbabilityDict, BigProbabilityDictGPU}, pb::PolicyBasis)::Union{Matrix{Float64}, CuArray{Float64, 2}}
    reserves = -iterate_calc(cfs, prob, pb.int_acc, pb.v, pb.nsims, pb.proj_max)
    return reserves
end
