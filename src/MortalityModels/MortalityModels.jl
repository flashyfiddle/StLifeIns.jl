module MortalityModels

using DataStructures: OrderedDict
include("..\\ARIMA\\ARIMA.jl"); using .ARIMA
export Arima, FittedArima, ConstructedArima, simulate_arima, forecast_arima

include("..\\Lives\\Lives.jl"); using .Lives
export Life, SingleLife, WholeLife, TermLife, setMAX_AGE, MAX_AGE

include(joinpath(@__DIR__, "set_globals.jl")); export setYEAR_MON, YEAR_MON

export MortalityModel, GAPC, LeeCarter, Plat
export MortalityForecasts, simulate_mortality, forecast_mortality, empty_mortality_forecast
export *, getindex, vcat
export lookup_mortality, mortality_lens, MortalityLengths

include(joinpath(@__DIR__, "models\\mortality_model.jl"))
include(joinpath(@__DIR__, "models\\LeeCarter.jl"))
include(joinpath(@__DIR__, "models\\Plat.jl"))

include(joinpath(@__DIR__, "forecast\\mortality_forecast.jl"))
include(joinpath(@__DIR__, "forecast\\other_operations.jl"))
include(joinpath(@__DIR__, "forecast\\models\\LeeCarter.jl"))
include(joinpath(@__DIR__, "forecast\\models\\Plat.jl"))

include(joinpath(@__DIR__, "lookup_mortality.jl"))

# using JLD2
# global mortmodel_dict = load(joinpath(@__DIR__, "example_models\\mortmodel_dict.jld2"))["mortmodel_dict"]
# export mortmodel_dict

end
