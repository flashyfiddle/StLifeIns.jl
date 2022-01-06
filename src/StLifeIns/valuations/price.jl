function annuity(cf::Vector{Cashflow}, pb::PolicyBasis, prob::BigProbabilityDictGPU)::CuArray{Float64, 1}
    completecfs = convert(CompleteCashflows, complete.(cf, pb.proj_max))
    val = value(completecfs, prob, pb)
    return val
end


function price(policy::StandardPolicy, basis::ProductBasis, profit_margin::Float64)::CuArray{Float64, 1}
    pb = PolicyBasis(policy.life, basis)
    prob = dependent_probabilities(pb)
    ann = annuity(policy.premiums, pb, prob)
    ben_exp = complete_inflate(policy.expenses, vcat(policy.benefits, policy.penalties), pb.cum_infl, pb.proj_max)
    cost = value(ben_exp, prob, pb)
    return -cost./((1-profit_margin).*ann)
end

#=
# example
life = WholeLife(1, true, 20, 12)
premiums = [RecurringCashflow("premiums", 1, 0, 1, 12, false, InForce())] # amount = 1
benefits = [AnyTimeCashflow("death benefit", -1000000, 0, true, OnDeath())]
policy = StandardPolicy("Whole Life Assurance", life, premiums, benefits, [], [])
# remember to run the wla_basis
@btime price(policy, wla_basis)
=#

#=
life = WholeLife(1, true, 44, 0)
premiums = [RecurringCashflow("premiums", 1, 0, 1, 12, false, InForce())] # amount = 1
benefits = [AnyTimeCashflow("death benefit", -1.19*10^6, 0, true, OnDeath())]
expenses = [RecurringCashflow("premiums", -57, 0, 1, 12, true, InForce())]
policy = StandardPolicy("wla", life, premiums, benefits, expenses, [])

nsims = 1
proj = life.proj_max
max_term = 12*MAX_AGE

int = 0.1*ones(nsims, proj)
mon_int = (1 .+ int).^(1/12) .- 1
infl = 0.045*ones(nsims, proj)
mon_infl = (1 .+ infl).^(1/12) .- 1

mortality = simulate(mortmodel_dict["Lee-Carter Negative Binomial"], nsims)
wla_surr = [0.1 => 12, 0.05 => 12, 0.04 => 12, 0.03 => 12, 0.02 => 12, 0.01 => Inf]
wla_surr = create_surrender_rates(wla_surr, nsims, max_term)

basis = ProductBasis(nsims, proj, mortality, wla_surr, mon_int, mon_infl)

price(policy, basis, 0.1)
=#
