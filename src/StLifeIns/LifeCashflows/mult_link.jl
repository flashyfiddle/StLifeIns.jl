# some function may need specifying to apply stochastic results to a cashflow resulting in a ParallelCashflow
# inflation would only require multiplying with inflation factors; hence the mult_link below
# potentially, however, in the case of unit-linked policies, we may wish to link a cashflow after determining the unit fund value

"""
    mult_link(cf::ZeroCashflow, x::Union{(Matrix{Float64}, CuArray{Float32, 2})})

Returns the same `ZeroCashflow`.
"""
function mult_link(cf::ZeroCashflow, x::Union{(Matrix{Float64}, CuArray{Float32, 2})})::ZeroCashflow
    return cf
end

"""
    mult_link(cf::VectorCashflow, x::Union{(Matrix{Float64}, CuArray{Float32, 2})})

Returns a `ParallelVectorCashflow` which has been scaled by the factors in `x`.
"""
function mult_link(cf::VectorCashflow, x::Union{(Matrix{Float64}, CuArray{Float32, 2})})::ParallelVectorCashflow
    if cf.arrears
        amount = transpose(cf.amount) .* x
    else
        amount = transpose(cf.amount) .* x .* (1 ./@view(x[:, 1])) # effectively don't inflate a time 0 cashflow
    end

    return ParallelVectorCashflow(cf.name, amount, cf.arrears, cf.contingency)
end

"""
    mult_link(cf::PointCashflow, x::Union{(Matrix{Float64}, CuArray{Float32, 2})})

Returns a `ParallelPointCashflow` which has been scaled by the factors in `x`.
"""
function mult_link(cf::PointCashflow, x::Union{(Matrix{Float64}, CuArray{Float32, 2})})::ParallelPointCashflow
    if cf.arrears
        amount = cf.amount .* @view(x[:, cf.time])
    else
        amount = cf.amount .* @view(x[:, cf.time]) .* (1 ./@view(x[:, 1])) # effectively don't inflate a time 0 cashflow
    end

    return ParallelPointCashflow(cf.name, amount, cf.time, cf.arrears, cf.contingency)
end

"""
    mult_link(cfs::CompleteCashflows, x::Union{(Matrix{Float64}, CuArray{Float32, 2})})

returns `CompleteCashflows` where each `CompleteCashflow` has been scaled by factors in `x`.
"""
function mult_link(cfs::CompleteCashflows, x::Union{(Matrix{Float64}, CuArray{Float32, 2})})::CompleteCashflows
    n = length(cfs)
    linked_cfs = CompleteCashflows(undef, n)
    for i in 1:n
        new_cf = mult_link(cfs[i], x)
        linked_cfs[i] = new_cf
    end
    return linked_cfs
end
