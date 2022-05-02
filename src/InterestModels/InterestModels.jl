module InterestModels

using Distributions: Normal, NoncentralChisq

export InterestModel, CIR, Vasicek
include("models\\interest_model.jl")
include("models\\CIR.jl")
include("models\\Vasicek.jl")

export simulate_interest, forecast_interest
include("forecast\\CIR.jl")
include("forecast\\Vasicek.jl")

using JLD2
intmodeldict_dir = pwd()*"\\src\\InterestModels\\example_models\\intmodel_dict.jld2"
intmodel_dict = load(intmodeldict_dir)["intmodel_dict"]
int_start = load(intmodeldict_dir)["int_start"]

export intmodel_dict, int_start


end
