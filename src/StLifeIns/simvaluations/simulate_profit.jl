"""
    simulate_profit(policy::StandardPolicy, basis::ProductBasis, reserves::Union{(CuArray{Float64, 1}, CuArray{Float64, 2}, Matrix{Float64}, Vector{Float64})}, rdr::Float64)::Union{(Vector{Float64}, CuArray{Float64, 1})}

Returns the simulated remaining profit of each basis-simulation of a `policy`
based on held `reserves`, a profit-`basis` (different from basis used for
calculating reserves) and a risk-discount rate `rdr`.

Expenses need to be adjusted manually before using this function.

Lives are simulated and the emerging profit is given.

"""
function simulate_profit(policy::StandardPolicy, basis::ProductBasis, reserves::Union{(CuArray{Float64, 1}, CuArray{Float64, 2}, Matrix{Float64}, Vector{Float64})}, rdr::Float64)::Union{(Vector{Float64}, CuArray{Float64, 1})}
    pb = PolicyBasis(policy.life, basis)
    cfs = complete_inflate(policy.expenses, vcat(policy.premiums, policy.benefits, policy.penalties), pb.cum_infl, pb.proj_max)
    cfs = vcat(cfs, start_end_reserves(reserves, policy.life.term_if==0))
    prob = dependent_probabilities(pb)
    realised_probs = simulate_life(prob, pb)
    funding_levels = calc_simprofit(cfs, realised_probs, pb, 1/(1+rdr)^(1/12))
    return funding_levels
end


"""
    simulate_profit(policies::Vector{StandardPolicy}, rbasis::ProductBasis, pbasis::ProductBasis, rdr::Float64, exp_fact::Float64)

Returns the simulated remaining profit of each basis-simulation of a set of
`policies` based on a reserving-`rbasis`, a profit-`pbasis` (different from basis used for
calculating reserves) and a risk-discount rate `rdr`.

`exp_fact` is used to factor all the expenses of the policies provided.

Lives are simulated and the emerging profit is given.

"""
function simulate_profit(policies::Vector{StandardPolicy}, rbasis::ProductBasis, pbasis::ProductBasis, rdr::Float64, exp_fact::Float64)::Union{(Vector{Float64}, CuArray{Float64, 1})}
    nsims= pbasis.nsims
    mproj_max = maximum([policy.life.proj_max for policy in policies])

    if useGPU
        total_profit = CUDA.zeros(Float64, nsims)
        for policy in policies
            res_calc = reserves(policy, rbasis)
            res = res_calc.reserves[:] # converts to 1 dimensional array
            red_exp_policy = factor_expenses(policy, exp_fact)
            pol_profit = simulate_profit(red_exp_policy, pbasis, res, rdr)
            total_profit += pol_profit
        end
    else
        total_profit = zeros(Float64, nsims)
        Threads.@threads for policy in policies
            res_calc = reserves(policy, rbasis)
            res = res_calc.reserves[:] # converts to 1 dimensional array
            red_exp_policy = factor_expenses(policy, exp_fact)
            pol_profit = simulate_profit(red_exp_policy, pbasis, res, rdr)
            total_profit += pol_profit
        end
    end

    return total_profit
end


function calc_simprofit(cfs::CompleteCashflows, prob::Union{(BigRealisedProbabilityDict, BigRealisedProbDictGPU)}, pb::PolicyBasis, rdf::Float64)::Union{(Vector{Float64}, CuArray{Float64, 1})}
    return sim_calc(cfs, prob, pb.int_acc, rdf, pb.nsims, pb.proj_max)
end
