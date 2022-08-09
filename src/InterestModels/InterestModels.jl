module InterestModels

using Distributions: Normal, NoncentralChisq

export InterestModel, CIR, Vasicek
include(joinpath(@__DIR__, "models\\interest_model.jl"))
include(joinpath(@__DIR__, "models\\CIR.jl"))
include(joinpath(@__DIR__, "models\\Vasicek.jl"))

export simulate_interest, forecast_interest
include(joinpath(@__DIR__, "forecast\\CIR.jl"))
include(joinpath(@__DIR__, "forecast\\Vasicek.jl"))

# using JLD2
# intmodeldict_dir = joinpath(@__DIR__, "example_models\\intmodel_dict.jld2")
# global intmodel_dict = load(intmodeldict_dir)["intmodel_dict"]
# global int_start = load(intmodeldict_dir)["int_start"]
#
# export intmodel_dict, int_start

end
