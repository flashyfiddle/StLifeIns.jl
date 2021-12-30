function factor_expenses(x::StandardPolicy, y::Union{Int64, Float64})
    x = @set x.expenses = y*x.expenses
    return x
end
