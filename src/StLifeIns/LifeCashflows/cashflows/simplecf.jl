"""
    RecurringCashflow(name, amount, esc, start, freq, arrears, contingency)

Returns a `Cashflow` which is payable at regular intervals on some contingency.

This type of `Cashflow` is used as a simple definition for cashflows such as
premiums and expenses which are regular. The only allowable contingency at the
moment is `InForce()`.

...
# Arguments
- `name::String`: a character string name.
- `amount::Float64`: a vector of amounts payable where position in vector indicates month of payment (note that it is required to specify incoming cashflows as positive and outgoing cashflows as negative)
- `esc::Float64`: the yearly growth rate of payments, otherwise can be set to 0.
- `start::Int16`: the month in which the first payment is made. The first possible start is 1.
- `freq::Int16`: the frequency with which payments are made in a year (monthly = 12 & yearly = 1). freq must be a factor of 12.
- `arrears::Bool`: whether or not payments are made in arrears (true) or in advance (false).
- `contingency::Contingency`: the event on which payment is contingent.
...

# Example
```jldoctest
RecurringCashflow("premiums", 100, 0.01, 1, 12, true, InForce())
```
"""
struct RecurringCashflow <: SimpleCashflow
    name::String
    amount::Float64
    esc::Float64
    start::Int16
    freq::Int8
    arrears::Bool
    contingency::Contingency
    function RecurringCashflow(name, amount, esc, start, freq, arrears, contingency=InForce())
        !(contingency isa InForce) && @error("RecurringCashflow only specified for contingency:: InForce")
        if amount == 0
            return ZeroCashflow(name)
        else
            return new(name, amount, esc, start, freq, arrears, contingency)
        end
    end
end


"""
    complete(cf::RecurringCashflow, months::Int16)

Returns the equivalent `VectorCashflow` with full payment horizon of `months`.
"""
function complete(cf::RecurringCashflow, months::Int16)::CompleteCashflow
    interval = Int8(12/cf.freq)
    amounts = zeros(Float64, months)
    amounts[cf.start] = cf.amount
    for i in (cf.start+interval):interval:months
        @inbounds amounts[i] = amounts[i-interval]*(1+cf.esc)^(interval/12)
    end
    return VectorCashflow(cf.name, amounts, cf.arrears, cf.contingency)
end

# ---------------------------------------------------------------------------- #
"""
    AnyTimeCashflow(name, amount, esc, arrears, contingency)

Returns a `Cashflow` where only one payment is made and of which the time of payment is unknown.

This type of `Cashflow` is used as a simple definition of a decrement payment on
death or termination. The contingency must be a decrement. This may include a
death benefit or claim expense, else possibly an expense or penalty on
termination.

...
# Arguments
- `name::String`: a character string name.
- `amount::Float64`: a vector of amounts payable where position in vector indicates month of payment (note that it is required to specify incoming cashflows as positive and outgoing cashflows as negative)
- `esc::Float64`: the yearly growth rate of payments, otherwise can be set to 0.
- `arrears::Bool`: whether or not payments are made in arrears (true) or in advance (false).
- `contingency::Contingency`: the event on which payment is contingent.
...

# Example
```jldoctest
AnyTimeCashflow("claim expense", -500, 0.01, true, OnDeath())
```
"""
struct AnyTimeCashflow <: SimpleCashflow
    name::String
    amount::Float64
    esc::Float64
    arrears::Bool # must be true for AnyTimeCashflow
    contingency::Contingency
    function AnyTimeCashflow(name, amount, esc, arrears, contingency)
        contingency isa InForce && @error("AnyTimeCsahflow not defined for contingency: InForce()")
        arrears == false && @error("AnyTimeCashflow not defined for arrears = false")
        if amount == 0
            return ZeroCashflow(name)
        else
            return new(name, amount, esc, arrears, contingency)
        end
    end
end

"""
    complete(cf::AnyTimeCashflow, months::Int16)

Returns the equivalent `VectorCashflow` with full payment horizon of `months`.
"""
function complete(cf::AnyTimeCashflow, months::Int16)::CompleteCashflow
    amounts = zeros(Float64, months)
    amounts[1] = cf.amount
    for i in 2:months
        @inbounds amounts[i] = amounts[i-1]*(1+cf.esc)^(1/12)
    end
    return VectorCashflow(cf.name, amounts, cf.arrears, cf.contingency)
end
