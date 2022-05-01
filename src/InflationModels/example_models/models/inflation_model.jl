using Distributions

struct RegWithArimaErrors1 <: InflationModel
    # regression parameters
    reg_factors::Vector{String} # [infl.l1, int.l0, int.l1]
    β::Vector{Float64} # regression parameters [infl.l1, int.l0, int.l1]
    e::Vector{Float64} # last 12 regression errors

    # SARIMA101 parameters
    Φ::Float64
    Θ::Float64
    σ::Float64
    ε::Vector{Float64} # last 12 SARIMA1010 errors
end


function simulate_inflation(infl_start::Float64, infl_model::RegWithArimaErrors1, int::Matrix{Float64}, nsims::Int64, proj::Int16)::Matrix{Float64}
    β, e, Φ, Θ, σ, ε = infl_model.β, infl_model.e, infl_model.Φ, infl_model.Θ, infl_model.σ, infl_model.ε

    e = simulate_SARIMA101(e, ε, Φ, Θ, σ, nsims, proj)
    infl = Matrix{Float64}(undef, nsims, proj+1)
    infl[:, 1] .= infl_start

    for t in 2:(proj+1)
        @views x = hcat(infl[:, t-1], int[:, t], int[:, t-1])
        @views infl[:, t] = x*β + e[:, t]
    end

    return infl[:, 2:(proj+1)]
end


function forecast_inflation(infl_start::Float64, infl_model::RegWithArimaErrors1, int::Matrix{Float64}, proj::Int16)::Matrix{Float64}
    β, e, Φ, Θ, ε = infl_model.β, infl_model.e, infl_model.Φ, infl_model.Θ, infl_model.ε

    e = forecast_SARIMA101(e, ε, Φ, Θ, proj)
    infl = Matrix{Float64}(undef, 1, proj+1)
    infl[:, 1] .= infl_start

    for t in 2:(proj+1)
        @views x = hcat(infl[:, t-1], int[:, t], int[:, t-1])
        @views infl[:, t] = x*β + e[:, t]
    end

    return infl[:, 2:(proj+1)]
end


# first column is the last value in ys
function simulate_SARIMA101(ys::Vector{Float64}, es::Vector{Float64}, Φ::Float64, Θ::Float64, σ::Float64, nsims::Int64, proj::Int16)::Matrix{Float64}
    y = Matrix{Float64}(undef, nsims, proj+12)
    e = hcat(Matrix{Float64}(undef, nsims, 12), rand(Normal(0, σ), nsims, proj))
    for i in 1:nsims
        y[i, 1:12] = ys
        e[i, 1:12] = es
    end

    for t in 13:(proj+12)
        @views y[:, t] = Φ.*y[:, t-12] .+ e[:, t] .+ Θ.*e[:, t-12]
    end
    return y[:, 12:(proj+12)]
end


function forecast_SARIMA101(ys::Vector{Float64}, es::Vector{Float64}, Φ::Float64, Θ::Float64, proj::Int16)::Matrix{Float64}
    y = Matrix{Float64}(undef, 1, proj+12)
    e = hcat(Matrix{Float64}(undef, 1, 12), zeros(1, proj))
    y[1, 1:12] = ys
    e[1, 1:12] = es

    for t in 13:(proj+12)
        @views y[:, t] = Φ.*y[:, t-12] .+ e[:, t] .+ Θ.*e[:, t-12]
    end
    return y[:, 12:(proj+12)]
end
