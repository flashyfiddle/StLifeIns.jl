module StLifeIns

using CUDA: CuArray
using DataStructures: OrderedDict
using Setfield: @set

include("InflationModels\\InflationModels.jl"); export InflationModel

include("InterestModels\\InterestModels.jl"); using .InterestModels
export InterestModel, CIR, Vasicek, simulate_interest, forecast_interest

include("LifeContingencies\\LifeContingencies.jl"); using .LifeContingencies
export Arima, FittedArima, ConstructedArima, simulate_arima, forecast_arima, Life,
SingleLife, WholeLife, TermLife, setYEAR_MON, setMAX_AGE, YEAR_MON, MAX_AGE,
MortalityModel, LeeCarter, Plat, MortalityForecasts, simulate_mortality,
forecast_mortality, empty_mortality_forecast, *, getindex, vcat,
lookup_mortality, Contingency, Definite, Indefinite, Decrement, InForce,
OnDeath, OnTermination, create_surrender_rates, lookup_surrender,
dependent_probabilities

include("StLifeIns\\LifeBasis\\LifeBasis.jl")
export Basis, ProductBasis, PolicyBasis, combine_bases, getindex

include("StLifeIns\\LifeCashflows\\LifeCashflows.jl")
export Cashflow, Cashflows, CompleteCashflow, SimpleCashflow, ParallelCashflow,
CompleteCashflows, mult_link, complete_inflate, *

include("StLifeIns\\LifePolicies\\LifePolicies.jl")
export Policy, StandardPolicy, factor_expenses

export dependent_probabilities, simulate_lives, BigProbabilityDict, BigRealisedProbDict # replacements for LifeContingencies with GPU
include("StLifeIns\\replacement_functions\\probabilities.jl")
include("StLifeIns\\replacement_functions\\simulate_lives.jl")

export StochasticReserveCalcs, annuity, price, profit, reserves
include("StLifeIns\\valuations\\calc.jl")
include("StLifeIns\\valuations\\price.jl")
include("StLifeIns\\valuations\\profit.jl")
include("StLifeIns\\valuations\\reserve.jl")

export SimulatedLossFunding, simulate_loss, simulate_profit
include("StLifeIns\\simvaluations\\simlife_calc.jl")
include("StLifeIns\\simvaluations\\simulate_loss.jl")
include("StLifeIns\\simvaluations\\simulate_profit.jl")

end
