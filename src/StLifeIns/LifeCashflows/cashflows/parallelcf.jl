"""
    ParallelPointCashflow(name, amount, time, arrears, contingency)

Returns the equivalent `Cashflow` of a `PointCashflow` across parallel
simulations.

Each payment in `amount` is the amount payable in a separate simulation.
"""
struct ParallelPointCashflow <: ParallelCashflow
    name::String
    amount::Union{(Vector{Float64}, CuArray{Float64, 1})}
    time::Int16
    arrears::Bool
    contingency::Contingency
    function ParallelPointCashflow(name, amount, time, arrears, contingency)
        if all(amount .== 0)
            return ZeroCashflow(name)
        else
            useGPU && (amount = CuArray{Float64, 1}(amount))
            return new(name, amount, time, arrears, contingency)
        end
    end
end


"""
    ParallelVectorCashflow(name, amount, arrears, contingency)

Returns the equivalent `Cashflow` of a `VectorCashflow` across parallel
simulations.

Each row in `amount` represents the amounts payable in a separate simulation.
"""
struct ParallelVectorCashflow <: ParallelCashflow
    name::String
    amount::Union{(Matrix{Float64}, CuArray{Float64, 2})}
    arrears::Bool
    contingency::Contingency
    function ParallelVectorCashflow(name, amount, arrears, contingency)
        if all(amount .== 0)
            return ZeroCashflow(name)
        else
            useGPU && (amount = CuArray{Float64, 2}(amount))
            return new(name, amount, arrears, contingency)
        end
    end
end


"""
    complete(cf::ParallelCashflow, proj_max::Int16)

Returns the `ParallelCashflow` provided.

A ParallelCashflow does not need to be "completed".
"""
function complete(cf::ParallelCashflow, proj_max::Int16)::ParallelCashflow
    return cf
end
