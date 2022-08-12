module InflationModels

abstract type InflationModel end

export InflationModel, RegWithArimaErrors1, simulate_inflation,
forecast_inflation
include("inflation_model.jl")

end
