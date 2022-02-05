"""
    PolicyBasis(life::life, basis::ProductBasis)

All the basis information relating to a specific [`Life`](@ref) derived from the
[`StProductBasis`](@ref).

Includes mortality, surrender, interest and inflation rates.
"""
struct PolicyBasis <: Basis
    nsims::Int64
    proj_max::Int16
    whole_life::Bool
    μ::Union{Matrix{Float64}, CuArray{Float32, 2}}
    σ::Union{Matrix{Float64}, CuArray{Float32, 2}}
    cum_infl::Union{Matrix{Float64}, CuArray{Float32, 2}}
    int_acc::Union{Matrix{Float64}, CuArray{Float32, 2}}
    v::Union{Matrix{Float64}, CuArray{Float32, 2}}
    function PolicyBasis(life::SingleLife, basis::StProductBasis)
        proj_max = life.proj_max
        whole_life = life isa WholeLife
        μ = lookup_mortality(life, basis.mortality, basis.nsims, proj_max)
        σ = lookup_surrender(life, basis.surrender_rates)
        @views cum_infl, int_acc, v = basis.cum_infl[:, 1:proj_max],
                                      int_acc = basis.int_acc[:, 1:proj_max],
                                      v = basis.v[:, 1:proj_max]
        return new(basis.nsims, proj_max, whole_life, μ, σ, cum_infl, int_acc, v)
    end
end
