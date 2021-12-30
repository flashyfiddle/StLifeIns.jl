function combine_bases(bases::ProductBasis...)::ProductBasis
    nsims = bases[1].nsims
    proj = bases[1].proj
    mortality = bases[1].mortality
    surrender_rates = bases[1].surrender_rates
    for i in 2:length(bases)
        nsims += bases[i].nsims
        bases[i].proj != proj && error("Bases of different projections")
        mortality = vcat(mortality, bases[i].mortality)
        surrender_rates = vcat(surrender_rates, bases[i].surrender_rates)
    end
    return ProductBasis(nsims, proj, mortality, surrender_rates)
end


function Base.getindex(basis::ProductBasis, i::Union{Int64, UnitRange})::ProductBasis
    if i isa Int64
        i= i:i
    end

    return ProductBasis(length(i), basis.proj, basis.mortality[i, :],
    basis.surrender_rates[i, :])
end
