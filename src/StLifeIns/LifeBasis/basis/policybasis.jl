"""
    PolicyBasis(life::life, basis::ProductBasis)

All the basis information relating to a specific `Life` derived from the `ProductBasis`.

Includes mortality, surrender, interest and inflation rates.
"""
struct PolicyBasis <: Basis
    nsims::Int64
    proj_max::Int16
    μ::CuArray{Float32, 2}
    σ::CuArray{Float32, 2}
    cum_infl::CuArray{Float32, 2}
    int_acc::CuArray{Float32, 2}
    v::CuArray{Float32, 2}
    function PolicyBasis(life::Life, basis::StProductBasis)
        proj_max = life.proj_max
        μ = lookup_mortality(life, basis.mortality, basis.nsims, proj_max)
        σ = lookup_surrender(life, basis.surrender_rates)
        cum_infl = @view(basis.cum_infl[:, 1:proj_max])
        int_acc = @view(basis.int_acc[:, 1:proj_max])
        v = @view(basis.v[:, 1:proj_max])
        return new(basis.nsims, proj_max, μ, σ, cum_infl, int_acc, v)
    end
end
