"""
    ParallelPointCashflow(name, amount, time, arrears, contingency)

Returns the equivalent `Cashflow` of a `PointCashflow` across parallel
simulations.

Each payment in `amount` is the amount payable in a separate simulation.
"""
struct ParallelPointCashflow <: ParallelCashflow
    name::String
    amount::CuArray{Float64, 1}
    time::Int16
    arrears::Bool
    contingency::Contingency
end


"""
    ParallelVectorCashflow(name, amount, arrears, contingency)

Returns the equivalent `Cashflow` of a `VectorCashflow` across parallel
simulations.

Each row in `amount` represents the amounts payable in a separate simulation.
"""
struct ParallelVectorCashflow <: ParallelCashflow
    name::String
    amount::CuArray{Float64, 2}
    arrears::Bool
    contingency::Contingency
end


"""
    complete(cf::ParallelCashflow, proj_max::Int16)

Returns the `ParallelCashflow` provided.

A ParallelCashflow does not need to be "completed".
"""
function complete(cf::ParallelCashflow, proj_max::Int16)::ParallelCashflow
    return cf
end
