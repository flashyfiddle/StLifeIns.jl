__precompile__()

module StLifeIns

using CUDA
using DataStructures: OrderedDict
using Setfield: @set


include(joinpath(@__DIR__, "InflationModels\\InflationModels.jl")); using .InflationModels
export InflationModel, RegWithArimaErrors1, simulate_inflation,
forecast_inflation#, inflmodel_dict, infl_start

include(joinpath(@__DIR__, "InterestModels\\InterestModels.jl")); using .InterestModels
export InterestModel, CIR, Vasicek, simulate_interest, forecast_interest#,
# intmodel_dict, int_start

include(joinpath(@__DIR__, "LifeContingencies\\LifeContingencies.jl"));
using .LifeContingencies: Arima, FittedArima, ConstructedArima, simulate_arima,
forecast_arima, Life, SingleLife, WholeLife, TermLife, setYEAR_MON, setMAX_AGE,
YEAR_MON, MAX_AGE, MortalityModel, GAPC, LeeCarter, Plat, MortalityForecasts,
simulate_mortality, forecast_mortality, empty_mortality_forecast, *, getindex,
vcat, Contingency, Definite, Indefinite, Decrement, InForce, OnDeath,
OnTermination, create_surrender_rates, mortality_lens, BigProbabilityDict,
BigRealisedProbabilityDict, MortalityLengths#, mortmodel_dict

export Arima, FittedArima, ConstructedArima, simulate_arima,
forecast_arima, Life, SingleLife, WholeLife, TermLife, setYEAR_MON, setMAX_AGE,
YEAR_MON, MAX_AGE, MortalityModel, GAPC, LeeCarter, Plat, MortalityForecasts,
simulate_mortality, forecast_mortality, empty_mortality_forecast, *, getindex,
vcat, Contingency, Definite, Indefinite, Decrement, InForce, OnDeath,
OnTermination, create_surrender_rates, mortality_lens, mortmodel_dict

export setGPU, setCPU
include(joinpath(@__DIR__, "StLifeIns\\setProcessor.jl"))

# replacements for LifeContingencies with GPU
import .LifeContingencies: lookup_mortality, lookup_surrender, dependent_probabilities, simulate_life
export MortalityForecastsGPU, lookup_mortality, lookup_surrender
include(joinpath(@__DIR__, "StLifeIns\\replacement_functions\\lookup_mortality.jl"))
include(joinpath(@__DIR__, "StLifeIns\\replacement_functions\\lookup_surrender.jl"))


export Basis, ProductBasis, StProductBasis, PolicyBasis, combine_bases, getindex
include(joinpath(@__DIR__, "StLifeIns\\LifeBasis\\LifeBasis.jl"))

export Cashflow, Cashflows, CompleteCashflow, SimpleCashflow, ParallelCashflow,
CompleteCashflows, ZeroCashflow, PointCashflow, VectorCashflow,
ParallelPointCashflow, ParallelVectorCashflow, RecurringCashflow,
AnyTimeCashflow, complete, mult_link, complete_inflate, *
include(joinpath(@__DIR__, "StLifeIns\\LifeCashflows\\LifeCashflows.jl"))

export Policy, StandardPolicy, factor_expenses
include(joinpath(@__DIR__, "StLifeIns\\LifePolicies\\LifePolicies.jl"))

# replacements for LifeContingencies with GPU
export dependent_probabilities, simulate_life, BigProbabilityDictGPU,
BigRealisedProbDictGPU, *, getindex, vcat
include(joinpath(@__DIR__, "StLifeIns\\replacement_functions\\probabilities.jl"))
include(joinpath(@__DIR__, "StLifeIns\\replacement_functions\\simulate_lives.jl"))
include(joinpath(@__DIR__, "StLifeIns\\replacement_functions\\other_operations.jl"))

export indices
include(joinpath(@__DIR__, "StLifeIns\\indices.jl"))

export StochasticReserveCalcs, annuity, price, profit, reserves
export iterate_reserves, iterate_calc, calc, value, get_totals, annuity,
start_end_reserves
include(joinpath(@__DIR__, "StLifeIns\\valuations\\calc.jl"))
include(joinpath(@__DIR__, "StLifeIns\\valuations\\price.jl"))
include(joinpath(@__DIR__, "StLifeIns\\valuations\\profit.jl"))
include(joinpath(@__DIR__, "StLifeIns\\valuations\\reserve.jl"))

export SimulatedLossFunding, simulate_loss, simulate_profit
export iterate_simloss, calc_simprofit, sim_calc, iterate_sim_calc,
get_definite_totals
include(joinpath(@__DIR__, "StLifeIns\\simvaluations\\simlife_calc.jl"))
include(joinpath(@__DIR__, "StLifeIns\\simvaluations\\simulate_loss.jl"))
include(joinpath(@__DIR__, "StLifeIns\\simvaluations\\simulate_profit.jl"))

# export simulate_model_combinations, forecast_model_combinations,
# simulate_model_combinations_adj, forecast_model_combinations_adj,
# mean_model_forecast, mean_model_forecast_adj, simulate_int_infl,
# forecast_int_infl
# include("model_combo.jl")

end
