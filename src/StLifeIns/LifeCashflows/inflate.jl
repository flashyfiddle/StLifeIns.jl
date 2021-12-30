"""
    complete_inflate(expenses::Cashflows, prem_ben_pen::Cashflows, cuminfl::CuArray{Float32}, proj_max::Int16)::CompleteCashflows

returns `CompleteCashflows` of which `expenses` have also been inflated.

...
# Arguments
- `expenses::Cashflows`: cashflows to be inflated (typically policy expenses)
- `prem_ben_pen::Cashflows`: all cashflows that do not need to be inflated (typically everything except expenses)
- `cuminfl::CuArray{Float32}`: factors to adjust expenses with at each month and simulation
- `proj_max::Int16`: the maximum remaining term of cashflows
...

"""
function complete_inflate(expenses::Cashflows, prem_ben_pen::Cashflows, cuminfl::CuArray{Float32}, proj_max::Int16)::CompleteCashflows
    new_cfs = CompleteCashflows(undef, length(expenses) + length(prem_ben_pen))
    k = 1
    for i in eachindex(expenses)
        @inbounds new_cfs[k] = mult_link(complete(expenses[i], proj_max), cuminfl)
        k += 1
    end

    for i in eachindex(prem_ben_pen)
        @inbounds new_cfs[k] = complete(prem_ben_pen[i], proj_max)
        k += 1
    end
    return new_cfs
end
