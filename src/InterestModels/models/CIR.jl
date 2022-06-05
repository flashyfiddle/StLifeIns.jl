"""
    CIR(t::StepRangeLen, α::Float64, β::Float64, σ::Float64)

Cox–Ingersoll–Ross [`InterestModel`](@ref) fitted over time `t` with speed of
adjustment `α` to the mean `β` and with volatility parameter `σ`.

See also [`simulate_interest`](@ref), [`forecast_interest`](@ref),
[`Vasicek`](@ref).
"""
struct CIR <: InterestModel
    t::StepRangeLen
    α::Float64
    β::Float64
    σ::Float64
end
