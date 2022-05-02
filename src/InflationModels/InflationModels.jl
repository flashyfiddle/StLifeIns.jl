module InflationModels

abstract type InflationModel end

export InflationModel, RegWithArimaErrors1, simulate_inflation,
forecast_inflation
include("inflation_model.jl")

using JLD2
example_model_dir = joinpath(@__DIR__, "example_models\\inflmodel_dict.jld2")
global inflmodel_dict = load(example_model_dir)["inflmodel_dict"]
global infl_start = load(example_model_dir)["infl_start"]
export inflmodel_dict, infl_start

end
