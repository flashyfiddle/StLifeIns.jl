"""
    start_end_reserves(reserves::CuArray{Float64, 2}, new::Bool)::CompleteCashflows

Converts reserves matrix into [`ParallelVectorCashflow`](@ref)s for start of
month and end of month reserves.

...
# Arguments
- `reserves::CuArray{Float64, 2}`: matrix of reserves applicable at start of each month, conditional on prior survival.
- `new::Bool`: whether or not it is a new policy with no prior reserves.
...
"""
function start_end_reserves(reserves::Union{Matrix{Float64}, CuArray{Float64, 2}}, new::Bool)::CompleteCashflows
    nsims = size(reserves, 1)
    buffer = ifelse(useGPU, CUDA.zeros(nsims), zeros(nsims))

    if new
        @views start_res_amount = hcat(buffer, reserves[:, 2:end]) # new contracts need to set up reserves
    else
        @views start_res_amount = reserves
    end

    @views end_res_amount = hcat(reserves[:, 2:end], buffer)
    start_res = ParallelVectorCashflow("start reserves", start_res_amount, false, InForce())
    end_res = ParallelVectorCashflow("end reserves", -end_res_amount, true, InForce())
    return [start_res, end_res]
end


"""
    start_end_reserves(reserves::Union{Vector{Float64}, CuArray{Float64, 1}}, new::Bool)::CompleteCashflows

Converts reserves vector into [`VectorCashflow`](@ref)s for start of
month and end of month reserves.

...
# Arguments
- `reserves::Union{Vector{Float64}, CuArray{Float64, 1}}`: vector of reserves applicable at start of each month, conditional on prior survival.
- `new::Bool`: whether or not it is a new policy with no prior reserves.
...
"""
function start_end_reserves(reserves::Union{Vector{Float64}, CuArray{Float64, 1}}, new::Bool)::CompleteCashflows
    if new
        @views start_res_amount = vcat(0, reserves[2:end])
    else
        @views start_res_amount = reserves
    end

    @views end_res_amount = vcat(reserves[2:end], 0)
    start_res = VectorCashflow("start reserves", start_res_amount, false, InForce())
    end_res = VectorCashflow("end reserves", -end_res_amount, true, InForce())
    return [start_res, end_res]
end


"""
    profit(policy::StandardPolicy, basis::ProductBasis, reserves::Union{CuArray{Float64, 1}, CuArray{Float64, 2}, Matrix{Float64}, Vector{Float64}}, rdr::Float64)::Union{Vector{Float64}, CuArray{Float64, 1}}

Returns the expected remaining profit of each basis-simulation of a `policy`
based on held `reserves`, a profit-`basis` (different from basis used for
calculating reserves) and a risk-discount rate `rdr`.

"""
function profit(policy::StandardPolicy, basis::ProductBasis, reserves::Union{CuArray{Float64, 1}, CuArray{Float64, 2}, Matrix{Float64}, Vector{Float64}}, rdr::Float64)::Union{Vector{Float64}, CuArray{Float64, 1}}
    pb = PolicyBasis(policy.life, basis)
    cfs = complete_inflate(policy.expenses, vcat(policy.premiums, policy.benefits, policy.penalties), pb.cum_infl, pb.proj_max)
    cfs = vcat(cfs, start_end_reserves(reserves, policy.life.term_if==0))
    prob = dependent_probabilities(pb)
    profit = calc_profit(cfs, prob, pb, 1/(1+rdr)^(1/12))
    return profit
end


"""
    function profit(policies::Vector{StandardPolicy}, rbasis::ProductBasis, pbasis::ProductBasis, rdr::Float64, exp_fact::Float64)::Union{Vector{Float64}, CuArray{Float64, 1}}

Returns the total expected remaining profit of each basis-simulation of a group
of `policies`.

...
# Arguments
- `policies::Vector{StandardPolicy}`: set of policies that are valued together.
- `rbasis::ProductBasis`: reserving basis (should typically only have 1 simulation)
- `pbasis::ProductBasis`: profit-test basis
- `rdr::Float64`: risk-discount rate
- `exp_fact::Float64`: factor with which expenses need to be adjusted (from what is applicable to reserving)
...

"""
function profit(policies::Vector{StandardPolicy}, rbasis::ProductBasis, pbasis::ProductBasis, rdr::Float64, exp_fact::Float64)::Union{Vector{Float64}, CuArray{Float64, 1}}
    nsims, mproj_max = pbasis.nsims, pbasis.proj
    total_profit = CUDA.zeros(Float64, nsims)
    for policy in policies
        res_calc = reserves(policy, rbasis)
        res = res_calc.reserves[:] # converts to 1 dimensional array
        red_exp_policy = factor_expenses(policy, exp_fact)
        pol_profit = profit(red_exp_policy, pbasis, res, rdr)
        total_profit += pol_profit
    end

    return total_profit
end


function calc_profit(cfs::CompleteCashflows, prob::Union{BigProbabilityDict, BigProbabilityDictGPU}, pb::PolicyBasis, rdf::Float64)::Union{Vector{Float64}, CuArray{Float64, 1}}
    return calc(cfs, prob, pb.int_acc, rdf, pb.nsims, pb.proj_max)
end
