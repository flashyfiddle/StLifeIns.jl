module ARIMA

using Distributions: Normal

export Arima, FittedArima, ConstructedArima, simulate_arima, forecast_arima

include("simulate.jl")

end
