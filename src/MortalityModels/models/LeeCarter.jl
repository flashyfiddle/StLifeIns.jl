"""
    LeeCarter(x::UnitRange{Int8}, t::UnitRange{Int16}, αx::Vector{Float64}, βx::Vector{Float64}, κt::Arima)

The Lee-Carter [`GAPC`](@ref) (Generalised Age-Period-Cohort)
[`MortalityModel`](@ref) fitted for ages `x` over time/years `t` with static
parameters `αx` and `βx`, as well as [`Arima`](@ref) model for `κt`.

The recommended model for `κt` in the Lee-Carter model is an ARIMA(0, 1, 0)/
Random walk with drift.

See also [`simulate_mortality`](@ref), [`forecast_mortality`](@ref),
[`LeeCarter`](@ref), [`FittedArima`](@ref), [`ConstructedArima`](@ref).
"""
struct LeeCarter <: GAPC
    x::UnitRange{Int8} # fitted ages
    t::UnitRange{Int16} # fitted years
    αx::Vector{Float64}
    βx::Vector{Float64}
    κt::Arima
end
