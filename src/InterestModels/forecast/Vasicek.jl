function simulate_interest(start::Float64, model::Vasicek, nsims::Int64, proj::Int16, dt::Float64)::Matrix{Float64}
    α, β, σ = model.α, model.β, model.σ

    r = Matrix{Float64}(undef, nsims, proj+1)
    r[:, 1] .= start
    ϕ = exp(-α*dt)
    vol = σ * sqrt((1-ϕ^2)/(2*α))

    for t in 2:(proj+1)
        @views r[:, t] = β .+ ϕ.*(r[:, t-1] .- β) .+ vol .* rand(Normal(0, 1), nsims)
    end
    r = (1 .+ r/100).^(1/12) .- 1
    return r[:, 1:(proj+1)]
end

function forecast_interest(start::Float64, model::Vasicek, proj::Int16, dt::Float64)::Matrix{Float64}
    int = (1+model.β/100)^(1/12) - 1
    return int .* ones(Float64, 1, proj+1)
end
