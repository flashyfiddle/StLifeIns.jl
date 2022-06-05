"""
    ZeroCashflow(name)

A cashflow with no payments
"""
struct ZeroCashflow <: CompleteCashflow
    name::String
end


"""
    PointCashflow(name, amount, time, arrears, contingency)

Returns a `Cashflow` payable at some point in time based on a `Contingency`.

This type of `Cashflow` is particularly designed for a pure endowment benefit
where a payment can only be made at the end of some period,
i.e. payment time is known even if the actual occurence of the payment is unknown.

...
# Arguments
- `name::String`: a character string name.
- `amount::Float64`: the amount payable (note that it is required to specify incoming cashflows as positive and outgoing cashflows as negative).
- `time::Int16`: the month, from current, in which the payment is to be made. The first time possible is 1, denoting the first month.
- `arrears::Bool`: whether or not payments are made in arrears (true) or in advance (false).
- `contingency::Contingency`: the event on which payment is contingent.
...

# Example
```jldoctest
PointCashflow("survival benefit", -100, 120, true, InForce())
```
"""
struct PointCashflow <: CompleteCashflow
    name::String
    amount::Float64
    time::Int16
    arrears::Bool
    contingency::Contingency
    function PointCashflow(name, amount, time, arrears, contingency)
        if amount == 0
            return ZeroCashflow(name)
        else
            return new(name, amount, time, arrears, contingency)
        end
    end
end


"""
    VectorCashflow(name, amount, time, arrears, contingency)

Returns a `Cashflow` with several payments payable in the month indicated by their indices based on a `Contingency`.

This type of `Cashflow` allows one to specify a vector of cashflows to be paid at different times based on some contingency.

Note that GPU memory is used for this cashflow for efficient calculations.

...
# Arguments
- `name::String`: a character string name
- `amount::CuArray{Float64, 1}`: a vector of amounts payable where position in vector indicates month of payment (note that it is required to specify incoming cashflows as positive and outgoing cashflows as negative)
- `arrears::Bool`: whether or not payments are made in arrears (true) or in advance (false).
- `contingency::Contingency`: the event on which payment is contingent.
...

# Example
```jldoctest
VectorCashflow("premiums", [100, 100, 100], false, InForce())
```
"""
struct VectorCashflow <: CompleteCashflow
    name::String
    amount::Union{(Vector{Float64}, CuArray{Float64, 1})}
    arrears::Bool
    contingency::Contingency
    function VectorCashflow(name, amount, arrears, contingency)
        if all(amount .== 0)
            return ZeroCashflow(name)
        else
            useGPU && (amount = CuArray{Float64, 1}(amount))
            return new(name, amount, arrears, contingency)
        end
    end
end


"""
    complete(cf::CompleteCashflow, months::Int16)

Returns the `CompleteCashflow` provided.

A `CompleteCashflow` does not need to be "completed".
"""
function complete(cf::CompleteCashflow, months::Int16)::CompleteCashflow
    return cf
end
