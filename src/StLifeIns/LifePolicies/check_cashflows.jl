# checks the signs of amounts of cashflows
function check_cashflows(premiums, benefits, expenses, penalties)
    for cf in premiums
        if hasproperty(cf, :amount)
            !all(cf.amount .> 0) && @warn("Negative Premium: " * cf.name)
        end
    end

    for cf in benefits
        if hasproperty(cf, :amount)
            all(cf.amount .> 0) && @warn("Positive Benefit: " * cf.name)
        end
    end

    for cf in expenses
        if hasproperty(cf, :amount)
            all(cf.amount .> 0) && @warn("Positive Expense: " * cf.name)
        end
    end

    for cf in penalties
        if hasproperty(cf, :amount)
            !all(cf.amount .> 0) && @warn("Negative Penalty: " * cf.name)
        end
    end
    return nothing
end
