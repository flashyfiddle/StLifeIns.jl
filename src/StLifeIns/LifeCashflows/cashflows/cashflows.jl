abstract type Cashflow end
abstract type CompleteCashflow <: Cashflow end # a fully extended cashflow where cashflows amounts at each time are known
abstract type SimpleCashflow <: Cashflow end # a simplified means to specify some cashflows (which will be "completed")
abstract type ParallelCashflow <: Cashflow end # contains cashflows from a single source under several scenarios (e.g. under different inflation rates)

Cashflows = Vector{Cashflow}
CompleteCashflows = Vector{Union{(CompleteCashflow, ParallelCashflow)}}
