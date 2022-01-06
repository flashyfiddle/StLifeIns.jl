function simulate_profit(policy::StandardPolicy, basis::ProductBasis, reserves::Union{CuArray{Float64, 1}, CuArray{Float64, 2}, Matrix{Float64}, Vector{Float64}}, rdr::Float64)::CuArray{Float64, 1}
    pb = PolicyBasis(policy.life, basis)
    cfs = complete_inflate(policy.expenses, vcat(policy.premiums, policy.benefits, policy.penalties), pb.cum_infl, pb.proj_max)
    cfs = vcat(cfs, start_end_reserves(reserves, policy.life.term_if==0))
    prob = dependent_probabilities(pb)
    realised_probs = simulate_life(prob, pb)
    funding_levels = calc_simprofit(cfs, realised_probs, pb, 1/(1+rdr)^(1/12))
    return funding_levels
end


function simulate_profit(policies::Vector{StandardPolicy}, rbasis::ProductBasis, pbasis::ProductBasis, rdr::Float64, exp_fact::Float64)
    nsims, mproj_max = pbasis.nsims, pbasis.proj
    total_profit = CUDA.zeros(Float64, nsims)
    for policy in policies
        res_calc = reserves(policy, rbasis)
        res = res_calc.reserves[:] # converts to 1 dimensional array
        red_exp_policy = factor_expenses(policy, exp_fact)
        pol_profit = simulate_profit(red_exp_policy, pbasis, res, rdr)
        total_profit += pol_profit
    end

    return total_profit
end


function calc_simprofit(cfs::CompleteCashflows, prob::BigRealisedProbDictGPU, pb::PolicyBasis, rdf::Float64)::CuArray{Float64, 1}
    return sim_calc(cfs, prob, pb.int_acc, rdf, pb.nsims, pb.proj_max)
end
