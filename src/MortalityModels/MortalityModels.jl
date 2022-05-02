module MortalityModels

using DataStructures: OrderedDict
include("..\\ARIMA\\ARIMA.jl"); using .ARIMA
export Arima, FittedArima, ConstructedArima, simulate_arima, forecast_arima

include("..\\Lives\\Lives.jl"); using .Lives
export Life, SingleLife, WholeLife, TermLife, setMAX_AGE, MAX_AGE

include("set_globals.jl"); export setYEAR_MON, YEAR_MON

export MortalityModel, GAPC, LeeCarter, Plat
export MortalityForecasts, simulate_mortality, forecast_mortality, empty_mortality_forecast
export *, getindex, vcat
export lookup_mortality, mortality_lens, MortalityLengths

include("models\\mortality_model.jl")
include("models\\LeeCarter.jl")
include("models\\Plat.jl")

include("forecast\\mortality_forecast.jl")
include("forecast\\other_operations.jl")
include("forecast\\models\\LeeCarter.jl")
include("forecast\\models\\Plat.jl")

include("lookup_mortality.jl")

using JLD2
mortmodel_dict = load(pwd()*"\\src\\MortalityModels\\example_models\\mortmodel_dict.jld2")["mortmodel_dict"]
export mortmodel_dict

end
