"""
    Plat(x::UnitRange{Int8}, t::UnitRange{Int16}, c::UnitRange{Int16}, αx::Vector{Float64}, κt::Vector{Arima}, γc::Arima)

The Plat [`GAPC`](@ref) (Generalised Age-Period-Cohort)
[`MortalityModel`](@ref) fitted for ages `x` over time/years `t` with cohorts
`c` with static parameters `αx` as well as [`Arima`](@ref) models for the `κt `
parameters and an [`Arima`](@ref) model for the `γc`.

`Plat` can be used to define either the partial or full Plat model, depending on
the number of [`Arima`](@ref) models provided in the `Vector` for field `κt`
(either 2 or 3).

The recommended model for `κt`(1) in the Plat model is an ARIMA(0, 1, 0)/
Random walk with drift.

The recommended models for `κt`(2) and `κt`(3) in the Plat model is an
ARIMA(1, 0, 0).

See also [`simulate_mortality`](@ref), [`forecast_mortality`](@ref),
[`LeeCarter`](@ref), [`FittedArima`](@ref), [`ConstructedArima`](@ref).
"""
struct Plat <: GAPC
    x::UnitRange{Int8} # fitted ages
    t::UnitRange{Int16} # fitted years
    c::UnitRange{Int16} # cohorts
    αx::Vector{Float64}
    κt::Vector{Arima} # contains κt1, κt2 and κt3
    γc::Arima
end
