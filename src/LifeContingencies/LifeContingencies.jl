module LifeContingencies

include("..\\MortalityModels\\MortalityModels.jl"); using .MortalityModels
export Arima, FittedArima, ConstructedArima, simulate_arima, forecast_arima,
Life, SingleLife, WholeLife, TermLife, setYEAR_MON, setMAX_AGE, YEAR_MON,
MAX_AGE, MortalityModel, GAPC, LeeCarter, Plat, MortalityForecasts,
simulate_mortality, forecast_mortality, empty_mortality_forecast, *, getindex,
vcat, lookup_mortality, mortality_lens, MortalityLengths, mortmodel_dict

export Contingency, Definite, Indefinite, Decrement
export InForce, OnDeath, OnTermination
export create_surrender_rates, lookup_surrender

include(joinpath(@__DIR__, "contingencies\\contingencies.jl"))
include(joinpath(@__DIR__, "surrender_rates.jl"))

export BigProbabilityDict, BigRealisedProbDict, dependent_probabilities,
simulate_lives
include(joinpath(@__DIR__, "probabilities.jl"))
include(joinpath(@__DIR__, "simulate_lives.jl"))

end
