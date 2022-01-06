function start_end_reserves(reserves::CuArray{Float64, 2}, new::Bool)::CompleteCashflows
    nsims = size(reserves, 1)
    if new
        @views start_res_amount = hcat(CUDA.zeros(nsims), reserves[:, 2:end]) # new contracts need to set up reserves
    else
        @views start_res_amount = reserves
    end

    @views end_res_amount = hcat(reserves[:, 2:end], CUDA.zeros(nsims))
    start_res = ParallelVectorCashflow("start reserves", start_res_amount, false, InForce())
    end_res = ParallelVectorCashflow("end reserves", -end_res_amount, true, InForce())
    return [start_res, end_res]
end

function start_end_reserves(reserves::CuArray{Float64, 1}, new::Bool)::CompleteCashflows
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


function profit(policy::StandardPolicy, basis::ProductBasis, reserves::Union{CuArray{Float64, 1}, CuArray{Float64, 2}, Matrix{Float64}, Vector{Float64}}, rdr::Float64)::CuArray{Float64, 1}
    pb = PolicyBasis(policy.life, basis)
    cfs = complete_inflate(policy.expenses, vcat(policy.premiums, policy.benefits, policy.penalties), pb.cum_infl, pb.proj_max)
    cfs = vcat(cfs, start_end_reserves(reserves, policy.life.term_if==0))
    prob = dependent_probabilities(pb)
    profit = calc_profit(cfs, prob, pb, 1/(1+rdr)^(1/12))
    return profit
end


function profit(policies::Vector{StandardPolicy}, rbasis::ProductBasis, pbasis::ProductBasis, rdr::Float64, exp_fact::Float64)
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


function calc_profit(cfs::CompleteCashflows, prob::BigProbabilityDictGPU, pb::PolicyBasis, rdf::Float64)::CuArray{Float64, 1}
    return calc(cfs, prob, pb.int_acc, rdf, pb.nsims, pb.proj_max)
end
