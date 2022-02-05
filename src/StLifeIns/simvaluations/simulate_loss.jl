struct SimulatedLossFunding
    policy::StandardPolicy
    policy_basis::PolicyBasis
    prob::Union{BigProbabilityDict, BigProbabilityDictGPU}
    realised_probs::Union{BigRealisedProbabilityDict, BigRealisedProbDictGPU}
    cfs::CompleteCashflows
    funding_levels::Union{Matrix{Foat64}, CuArray{Float64, 2}}
end


"""
    simulate_loss(policy::StandardPolicy, basis::ProductBasis)

Returns a `Matrix` of the collective funding levels of a loss for each month
under each simulation.

Lives are simulated at the start based on their probabilities such that the loss
of each simulation is exactly known at the start and can be funded for exactly
in each month.

Note that reserves such as those obtained with `stochastic_reserves` are based
on the assumption that the `Life` is still in force at the start of the period.
In contrast, `simulate_loss` simulates lives once at the start such that funding
levels in each month depend on this single simulation. Lives that have
terminated or died after some point will require no funding.

"""
function simulate_loss(policies::Vector{StandardPolicy}, basis::ProductBasis)::Union{Matrix{Float64}, CuArray{Float64, 2}}
    nsims, mproj_max = basis.nsims, basis.proj
    loss = ifelse(useGPU, CUDA.zeros(Float64, nsims, mproj_max), zeros(Float64, nsims, mproj_max))
    for policy in policies
        res_calc = simulate_loss(policy, basis)
        x = res_calc.funding_levels
        @inbounds loss[indices(x)...] += x
    end

    return loss
end

"""
    simulate_loss(policy::StandardPolicy, basis::ProductBasis)

returns a `SimulatedLossFunding` which contains completed intermediary
calculations alongside the loss funding levels.

Lives are simulated at the start based on their probabilities such that the loss
of each simulation is exactly known at the start and can be funded for exactly
in each month.

Note that reserves such as those obtained with `stochastic_reserves` are based
on the assumption that the `Life` is still in force at the start of the period.
In contrast, `simulate_loss` simulates lives once at the start such that funding
levels in each month depend on this single simulation. Lives that have
terminated or died after some point will require no funding.

...
# Arguments
- `policy::StandardPolicy`: a single policy.
- `basis::ProductBasis`: a product basis relating to the provided policy.
...
"""
function simulate_loss(policy::StandardPolicy, basis::ProductBasis)
    pb = PolicyBasis(policy.life, basis)
    cfs = complete_inflate(policy.expenses, vcat(policy.premiums, policy.benefits, policy.penalties), pb.cum_infl, pb.proj_max)
    prob = dependent_probabilities(pb)
    realised_probs = simulate_life(prob, pb)
    funding_levels = iterate_simloss(cfs, realised_probs, pb)
    return SimulatedLossFunding(policy, pb, prob, realised_probs, cfs, funding_levels)
end


function iterate_simloss(cfs::CompleteCashflows, prob::Union{BigRealisedProbabilityDict, BigRealisedProbDictGPU}, pb::PolicyBasis)::Union{Matrix{Float64}, CuArray{Float64, 2}}
    return -iterate_sim_calc(cfs, prob, pb.int_acc, pb.v, pb.nsims, pb.proj_max)
end
