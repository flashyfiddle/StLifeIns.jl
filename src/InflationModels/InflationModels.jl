module InflationModels

abstract type InflationModel end

export InflationModel, inflmodel_dict, infl_start, RegWithArimaErrors1,
simulate_inflation, forecast_inflation, inflmodel_dict, infl_start

include(pwd()*"\\src\\InflationModels\\example_models\\ReadInflationModels.jl")

end
