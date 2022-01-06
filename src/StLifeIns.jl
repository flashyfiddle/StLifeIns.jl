module StLifeIns

using CUDA
using DataStructures: OrderedDict
using Setfield: @set

include("InflationModels\\InflationModels.jl"); export InflationModel

include("InterestModels\\InterestModels.jl"); using .InterestModels
export InterestModel, CIR, Vasicek, simulate_interest, forecast_interest

include("LifeContingencies\\LifeContingencies.jl");
using .LifeContingencies: Arima, FittedArima, ConstructedArima, simulate_arima,
forecast_arima, Life, SingleLife, WholeLife, TermLife, setYEAR_MON, setMAX_AGE,
YEAR_MON, MAX_AGE, MortalityModel, GAPC, LeeCarter, Plat, MortalityForecasts,
simulate_mortality, forecast_mortality, empty_mortality_forecast, *, getindex,
vcat, Contingency, Definite, Indefinite, Decrement, InForce, OnDeath,
OnTermination, create_surrender_rates, mortality_lens, BigProbabilityDict,
BigRealisedProbabilityDict, MortalityLengths

export Arima, FittedArima, ConstructedArima, simulate_arima,
forecast_arima, Life, SingleLife, WholeLife, TermLife, setYEAR_MON, setMAX_AGE,
YEAR_MON, MAX_AGE, MortalityModel, GAPC, LeeCarter, Plat, MortalityForecasts,
simulate_mortality, forecast_mortality, empty_mortality_forecast, *, getindex,
vcat, Contingency, Definite, Indefinite, Decrement, InForce, OnDeath,
OnTermination, create_surrender_rates, mortality_lens

# replacements for LifeContingencies with GPU
import .LifeContingencies: lookup_mortality, lookup_surrender
export MortalityForecastsGPU, lookup_mortality, lookup_surrender
include("StLifeIns\\replacement_functions\\lookup_mortality.jl")
include("StLifeIns\\replacement_functions\\lookup_surrender.jl")

export Basis, ProductBasis, StProductBasis, PolicyBasis, combine_bases, getindex
include("StLifeIns\\LifeBasis\\LifeBasis.jl")

export Cashflow, Cashflows, CompleteCashflow, SimpleCashflow, ParallelCashflow,
CompleteCashflows, ZeroCashflow, PointCashflow, VectorCashflow,
ParallelPointCashflow, ParallelVectorCashflow, RecurringCashflow,
AnyTimeCashflow, complete, mult_link, complete_inflate, *
include("StLifeIns\\LifeCashflows\\LifeCashflows.jl")

export Policy, StandardPolicy, factor_expenses
include("StLifeIns\\LifePolicies\\LifePolicies.jl")

# replacements for LifeContingencies with GPU
export dependent_probabilities, simulate_lives, BigProbabilityDictGPU,
BigRealisedProbDictGPU, *, getindex, vcat
include("StLifeIns\\replacement_functions\\probabilities.jl")
include("StLifeIns\\replacement_functions\\simulate_lives.jl")
include("StLifeIns\\replacement_functions\\other_operations.jl")

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
