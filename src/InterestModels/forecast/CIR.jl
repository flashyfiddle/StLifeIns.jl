# first column is the last known interest rate
function simulate_interest(start::Float64, model::CIR, nsims::Int64, proj::Int16, dt::Float64)::Matrix{Float64}
    α, β, σ = model.α, model.β, model.σ

    r = Matrix{Float64}(undef, nsims, proj+1)
    r[:, 1] .= start
    v = 4*α*β/σ^2
    ϕ = exp(-α*dt)
    ω = σ^2*(1-ϕ)/(4*α)

    for t in 2:(proj+1)
        @views x = r[:, t-1]./ω
        D = x .* ϕ
        @views r[:, t] = ω .* rand.(NoncentralChisq.(v, D))
    end
    r = (1 .+ r/100).^(1/12) .- 1
    return r[:, 1:(proj+1)]
end


function forecast_interest(start::Float64, model::CIR, proj::Int16, dt::Float64)::Matrix{Float64}
    int = (1+model.β/100)^(1/12) - 1
    return int .* ones(Float64, 1, proj+1)
end
