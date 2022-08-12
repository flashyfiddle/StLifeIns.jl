function survived(policy::StandardPolicy, months=1::Int)
    life = survived(policy.life, months)

    premiums = survived.(policy.premiums)
    benefits = survived.(policy.benefits)
    expenses = survived.(policy.expenses)
    penalties = survived.(policy.penalties)

    return StandardPolicy(policy.product, life, premiums, benefits, expenses, penalties)
end


function survived(cf::Union{PointCashflow, ParallelPointCashflow}, months=1::Int)
    time = cf.time - months
    if time<=0
        return ZeroCashflow(cf.name)
    else
        return PointCashflow(cf.name, cf.amount, time, cf.arrears, cf.contingency)
    end
end


function survived(cf::Union{ZeroCashflow, AnyTimeCashflow, RecurringCashflow}, months=1::Int)
    return cf
end


function survived(cf::VectorCashflow, months=1::Int)
    amount = cf.amount[(months+1):end]
    return VectorCashflow(cf.name, amount, cf.arrears, cf.contingency)
end


function survived(cf::ParallelVectorCashflow, months=1::Int)
    amount = cf.amount[:, (months+1):end]
    return ParallelVectorCashflow(cf.name, amount, cf.arrears, cf.contingency)
end


function survived(life::WholeLife, months=1::Int)
    age = life.age + months/12
    term_if = life.term_if + months

    return WholeLife(life.id, life.male, age, term_if, life.max_age)
end


function survived(life::TermLife, months=1::Int)
    age = life.age + months/12
    term_if = life.term_if + months

    return TermLife(life.id, life.male, age, life.term, term_if, life.max_age)
end
