module InterestModels

using Distributions: Normal, NoncentralChisq

export InterestModel, CIR, Vasicek
include("models\\interest_model.jl")
include("models\\CIR.jl")
include("models\\Vasicek.jl")

export simulate_interest, forecast_interest
include("forecast\\CIR.jl")
include("forecast\\Vasicek.jl")

end
