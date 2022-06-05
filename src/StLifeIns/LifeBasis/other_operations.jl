"""
    combine_bases(bases::StProductBasis...)::StProductBasis

Combines several [`StProductBasis`](@ref) objects into a single
[`StProductBasis`](@ref).
"""
function combine_bases(bases::StProductBasis...)::StProductBasis
    nsims = bases[1].nsims
    proj = bases[1].proj
    mortality = bases[1].mortality
    surrender_rates = bases[1].surrender_rates
    cum_infl = bases[1].cum_infl
    int_acc = bases[1].int_acc
    v =bases[1].v
    for i in 2:length(bases)
        nsims += bases[i].nsims
        bases[i].proj != proj && error("Bases of different projections")
        mortality = vcat(mortality, bases[i].mortality)
        surrender_rates = vcat(surrender_rates, bases[i].surrender_rates)
        cum_infl = vcat(cum_infl, bases[i].cum_infl)
        int_acc = vcat(int_acc, bases[i].int_acc)
        v = vcat(v, bases[i].v)
    end
    return StProductBasis(nsims, proj, mortality, surrender_rates, cum_infl,
    int_acc, v)
end


function Base.getindex(basis::StProductBasis, i::Union{(Int64, UnitRange)})::StProductBasis
    if i isa Int64
        i = i:i
    end

    nsims = length(i)
    proj = basis.proj
    mortality = basis.mortality[i, :]
    surrender_rates = basis.surrender_rates[i, :]
    cum_infl = basis.cum_infl[i, :]
    int_acc = basis.int_acc[i, :]
    v = basis.v[i, :]

    return StProductBasis(nsims, proj, mortality, surrender_rates, cum_infl,
    int_acc, v)
end
