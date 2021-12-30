"""
    StandardPolicy(product, life, premiums, benefits, expenses, penalties)

Returns a conventional `Policy` with cashflows contingent on events of a `Life`.

...
# Arguments
- `product::String`: a character string name.
- `life::Life`: the life to which the policy applies. A life can be `WholeLife` or 'TermLife'.
- `premiums::Cashflows`: a vector of premium cashflows (must have all positive `amount`).
- `benefits::Cashflows`: a vector of benefits cashflows (must have all negative `amount`).
- `expenses::Cashflows`: a vector of expenses cashflows (must have all positive `amount`).
- `penalties::Cashflows`: a vector of penalties cashflows (must have all negative `amount`).
...


# Example
Endowment assurance:
* of a man currently aged 40 exactly
* with full term of 25 years
* and which has been in force for 20 months

with:
* a death benefit of 100 000 payable at the end of the month of death
* a survival benefit of 50 000 payable at the end of the term of the contract
* premiums of 200 payable monthly in advance
* monthly recurring expenses of 10 paid in arrears
* a claim expense of 500 incurred alongside payment of the death benefit or survival benefit
```jldoctest
life = TermLife(10101, true, 40, 25*12, 20)

premiums = [RecurringCashflow("premiums", 200, 0, 1, 12, false, InForce())]
benefits = [AnyTimeCashflow("death benefits", -100000, 0, true, OnDeath()),
            PointCashflow("survival benefit", -50000, life.proj_max, true, InForce())]
expenses = [AnyTimeCashflow("death claim expense", -500, 0, true, OnDeath()),
            PointCashflow("survival claim expense", -500, life.proj_max, true, InForce())]
penalties = Cashflows()

StandardPolicy("Endowment Assurance", life, premiums, benefits, expenses, penalties)
```
"""
struct StandardPolicy <: Policy
    product::String
    life::Life
    premiums::Cashflows
    benefits::Cashflows
    expenses::Cashflows
    penalties::Cashflows
    function StandardPolicy(product, life, premiums, benefits, expenses, penalties)
        check_cashflows(premiums, benefits, expenses, penalties)
        return new(product, life, premiums, benefits, expenses, penalties)
    end
end
