function Base.:*(y::Union{(Float64, Int64)}, x::Cashflow)::Cashflow
    if hasfield(typeof(x), :amount)
        if x != 0
            return @set x.amount = y .* x.amount
        else
            return ZeroCashflow(x.name)
        end
    elseif x isa ZeroCashflow
        return x
    end
end
