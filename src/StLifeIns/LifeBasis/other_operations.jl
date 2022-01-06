function combine_bases(bases::StProductBasis...)::StProductBasis
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
    return StProductBasis(nsims, proj, mortality, surrender_rates)
end


function Base.getindex(basis::StProductBasis, i::Union{Int64, UnitRange})::StProductBasis
    if i isa Int64
        i= i:i
    end

    return StProductBasis(length(i), basis.proj, basis.mortality[i, :],
    basis.surrender_rates[i, :])
end
