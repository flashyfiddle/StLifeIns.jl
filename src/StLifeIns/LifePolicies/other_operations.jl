"""
    factor_expenses(policy::StandardPolicy, fact::Union{Int64, Float64})

Returns the provided `policy` with expenses factored by `fact`.
"""
function factor_expenses(policy::StandardPolicy, fact::Union{Int64, Float64})
    policy = @set policy.expenses = fact*policy.expenses
    return policy
end
