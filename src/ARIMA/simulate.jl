abstract type Arima end


"""
    FittedArima(order, y, e, φ, θ, μ, σ)

An [`Arima`](@ref) (Autoregressive integrated moving average) model which has
been fitted to actual data `y` with fitted errors `e`.

See also [`ConstructedArima`](@ref), [`simulate_arima`](@ref),
[`forecast_arima`](@ref).

...
# Arguments
- `order::Vector{Int64}`: `Vector` with length `3` denoting `p`, `d`, `q` orders
 of an `Arima` model.
- `y::Vector{Union{Missing, Float64}}`: the actual fitted data. The last `p+d`
entries cannot contain `missing`.
- `e::Vector{Union{Missing, Float64}}`: the actual fitted errors. The last `q`
entries cannot contain `missing`.
- `φ::Vector{Float64}`: `Vector` of `p` autoregressive coefficients.
- `θ::Vector{Float64}`: `Vector` of `q` moving average coefficients.
- `μ::Float64`: intercept of model.
- `σ::Float64`: standard error of model.
...
"""
struct FittedArima <: Arima
    order::Vector{Int64}
    y::Vector{Union{Missing, Float64}}
    e::Vector{Union{Missing, Float64}}
    φ::Vector{Float64}
    θ::Vector{Float64}
    μ::Float64
    σ::Float64
end


"""
    ConstructedArima(order, φ, θ, μ, σ)

An [`Arima`](@ref) (Autoregressive integrated moving average) model which has
not been fitted to actual data.

See also [`FittedArima`](@ref), [`simulate_arima`](@ref),
[`forecast_arima`](@ref).

...
# Arguments
- `order::Vector{Int64}`: `Vector` with length `3` denoting `p`, `d`, `q`
orders of an `Arima` model.
- `φ::Vector{Float64}`: `Vector` of `p` autoregressive coefficients.
- `θ::Vector{Float64}`: `Vector` of `q` moving average coefficients.
- `μ::Float64`: intercept of model.
- `σ::Float64`: standard error of model.
...
"""
struct ConstructedArima <: Arima
    order::Vector{Int64}
    φ::Vector{Float64}
    θ::Vector{Float64}
    μ::Float64
    σ::Float64
end


"""
    simulate_arima(model::FittedArima, n_ahead::Integer, nsims::Integer,
    return_original=false::Bool)

Simulates `nsims` simulations of a [`FittedArima`](@ref) time series `n_ahead`
timesteps into the future.

`return_original` can be used to return the entire time series or only the new
simulated part.

See also [`FittedArima`](@ref), [`ConstructedArima`](@ref),
[`forecast_arima`](@ref).

...
# Arguments
- `model::FittedArima`: a [`FittedArima`](@ref) object.
- `n_ahead::Integer`: how far ahead the model must be simulated.
- `nsims::Integer`: the number of simulations of the time series.
- `return_original::Bool`: whether or not simulation should include the original
fitted data. Default is `false`.
...
"""
function simulate_arima(model::FittedArima, n_ahead::Integer, nsims::Integer, return_original=false::Bool)::Matrix{Float64}
    m = maximum([model.order[1]+model.order[2], model.order[3]])
    n = n_ahead+m
    x = zeros(Union{Float64, Missing}, nsims, n)
    x[:, 1:m] .= transpose(special_diff(model.y[(end-m+1):end], model.order[2]))
    e = hcat(Matrix{Union{Float64, Missing}}(undef, nsims, m), rand(Normal(0, model.σ), nsims, n_ahead))
    e[:, 1:m] .= transpose(model.e[(end-m+1):end])


    for i in (m+1):n
        @views x[:, i] = x[:, (i-1):-1:(i-model.order[1])] * model.φ .+
                         e[:, i:-1:(i-model.order[3])] * vcat(1, model.θ) .+
                         model.μ
    end

    y = special_cumsum(x, 2, model.order[2])
    if return_original
        y = hcat(Matrix{Union{Float64, Missing}}(undef, nsims, length(model.y)-m), y)
        y[:, 1:(length(model.y)-m)] .= transpose(model.y[1:(end-m)])
        return y
    else
        y = y[:, (m+1):n]
        return y
    end
end


"""
    forecast_arima(model::FittedArima, n_ahead::Integer, return_original=false::Bool)

Forecasts the expected value of a [`FittedArima`](@ref) time series `n_ahead`
timesteps into the future.

`return_original` can be used to return the entire time series or only the new
forecasted part.

See also [`simulate_arima`](@ref), [`ConstructedArima`](@ref).

...
# Arguments
- `model::FittedArima`: a [`FittedArima`](@ref) object.
- `n_ahead::Integer`: how far ahead the model must be forecasted.
- `return_original::Bool`: whether or not forecast should include the original
fitted data. Default is `false`.
...
"""
function forecast_arima(model::FittedArima, n_ahead::Integer, return_original=false::Bool)::Matrix{Float64}
    m = maximum([model.order[1]+model.order[2], model.order[3]])
    n = n_ahead+m
    x = zeros(Union{Float64, Missing}, 1, n)
    x[:, 1:m] .= transpose(special_diff(model.y[(end-m+1):end], model.order[2]))
    e = hcat(Matrix{Union{Float64, Missing}}(undef, 1, m), zeros(Float64, 1, n_ahead))
    e[:, 1:m] .= transpose(model.e[(end-m+1):end])


    for i in (m+1):n
        @views x[:, i] = x[:, (i-1):-1:(i-model.order[1])] * model.φ .+
                         e[:, i:-1:(i-model.order[3])] * vcat(1, model.θ) .+
                         model.μ
    end

    y = special_cumsum(x, 2, model.order[2])
    if return_original
        y = hcat(Matrix{Union{Float64, Missing}}(undef, 1, length(model.y)-m), y)
        y[:, 1:(length(model.y)-m)] .= transpose(model.y[1:(end-m)])
        return y
    else
        y = y[:, (m+1):n]
        return y
    end
end

#=
function simulate_arima(model::ConstructedArima, n_ahead::Integer, nsims::Integer, burnin=100::Int64)::Matrix{Float64}
    n = n_ahead + burnin
    m = model.order[1] + model.order[2]
    e = rand(Normal(0, model.σ), nsims, n)
    x = e

    for i in (m+1):n
        @views x[:, i] = x[:, (i-1):-1:(i-model.order[1])] * model.φ .+
                         e[:, i:-1:(i-model.order[3])] * vcat(1, model.θ) .+
                         model.μ
    end

    Sx = special_cumsum(x, 2, model.order[2])
    y = Sx[:, (burnin+1):n]
    return y
end
=#

#=
function forecast_arima(model::ConstructedArima, n_ahead::Integer, burnin=100::Int64)::Matrix{Float64}
    n = n_ahead + burnin
    m = model.order[1] + model.order[2]
    e = zeros(Float64, nsims, n)
    x = e #-----------------------------------------------> don't make x zero

    for i in (m+1):n
        @views x[:, i] = x[:, (i-1):-1:(i-model.order[1])] * model.φ .+
                         e[:, i:-1:(i-model.order[3])] * vcat(1, model.θ) .+
                         model.μ
    end

    x = x[:, (burnin+1):n]
    y = special_cumsum(x, 2, model.order[2])
    return y
end
=#


function special_diff(x, times::Integer)
    for i in 1:times
        x = vcat(x[1], diff(x))
    end
    return x
end

function special_cumsum(x, dims::Integer, times::Integer)
    for i in 1:times
        x = cumsum(x, dims=dims)
    end
    return x
end
