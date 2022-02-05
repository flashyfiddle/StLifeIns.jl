function annuity(cf::Vector{Cashflow}, pb::PolicyBasis, prob::Union{BigProbabilityDict, BigProbabilityDictGPU})::Union{Vector{Float64}, CuArray{Float64, 1}}
    completecfs = convert(CompleteCashflows, complete.(cf, pb.proj_max))
    val = value(completecfs, prob, pb)
    return val
end


"""
    price(policy::StandardPolicy, basis::ProductBasis, profit_margin::Float64)::Union{Vector{Float64}, CuArray{Float64, 1}}

Returns the factor with which the `policy`s set of premiums needs to be
multiplied to provide the required `profit_margin`. Multiple premium `cashflows`
are allowed, but only a single factor per simulation is returned which is
applicable to all provided `cashflows`.

To price as intended, `premiums` of the `policy` need to be specified with the
appropriate `amount`s. The simplest contracts will have `amount=1`, however,
more complex contracts are allowed.

The `ProductBasis` will operate on all provided `policies`. Where different
products require separate bases, `reserves` should be called
separately for these products.

"""
function price(policy::StandardPolicy, basis::ProductBasis, profit_margin::Float64)::Union{Vector{Float64}, CuArray{Float64, 1}}
    pb = PolicyBasis(policy.life, basis)
    prob = dependent_probabilities(pb)
    ann = annuity(policy.premiums, pb, prob)
    ben_exp = complete_inflate(policy.expenses, vcat(policy.benefits, policy.penalties), pb.cum_infl, pb.proj_max)
    cost = value(ben_exp, prob, pb)
    return -cost./((1-profit_margin).*ann)
end
