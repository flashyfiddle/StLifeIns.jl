"""
    value(cfs::CompleteCashflows, prob::Union{BigProbabilityDict, BigProbabilityDictGPU}, pb::PolicyBasis)::Union{Vector{Float64}, CuArray{Float64, 1}}

Returns time 0 valuations of a set of cashflows for each simulation.
"""
function value(cfs::CompleteCashflows, prob::Union{BigProbabilityDict, BigProbabilityDictGPU}, pb::PolicyBasis)::Union{Vector{Float64}, CuArray{Float64, 1}}
    return calc(cfs, prob, pb.int_acc, pb.v, pb.nsims, pb.proj_max)
end


"""
    calc(cfs::CompleteCashflows, prob::Union{BigProbabilityDict, BigProbabilityDictGPU}, int_acc::Union{Matrix{Float64}, CuArray{Float32, 2}}, v::Union{Float64, Matrix{Float64}, CuArray{Float32, 2}}, nsims::Int64, proj_max::Int16)::Union{Vector{Float64}, CuArray{Float64, 1}}

Returns time 0 valuations of a set of cashflows for each simulation.
"""
function calc(cfs::CompleteCashflows, prob::Union{BigProbabilityDict, BigProbabilityDictGPU}, int_acc::Union{Matrix{Float64}, CuArray{Float32, 2}}, v::Union{Float64, Matrix{Float64}, CuArray{Float32, 2}}, nsims::Int64, proj_max::Int16)::Union{Vector{Float64}, CuArray{Float64, 1}}
    return iterate_calc(cfs, prob, int_acc, v, nsims, proj_max)[:, 1]
end


"""
    iterate_calc(cfs::CompleteCashflows, prob::Union{BigProbabilityDict, BigProbabilityDictGPU}, int_acc::Union{Matrix{Float64}, CuArray{Float32, 2}}, v::Union{Matrix{Float64}, CuArray{Float32, 2}}, nsims::Int64, proj_max::Int16)::Union{Matrix{Float64}, CuArray{Float64, 2}}

Returns a matrix of valuations for each simulation at each month. The valuation
at each month assumes that the policy is still in force.
"""
function iterate_calc(cfs::CompleteCashflows, prob::Union{BigProbabilityDict, BigProbabilityDictGPU}, int_acc::Union{Matrix{Float64}, CuArray{Float32, 2}}, v::Union{Matrix{Float64}, CuArray{Float32, 2}}, nsims::Int64, proj_max::Int16)::Union{Matrix{Float64}, CuArray{Float64, 2}}
    totals = get_totals(cfs, prob, int_acc, nsims, proj_max)
    inforce = prob[InForce()]

    if useGPU
        val = CuArray{Float64, 2}(undef, nsims, Int64(proj_max))
    else
        val = Matrix{Float64}(undef, nsims, Int64(proj_max))
    end

    @views val[:, proj_max] = totals[:, proj_max] .* v[:, proj_max]
    for i in reverse(2:(proj_max-1))
        @inbounds @views val[:, i] = (val[:, i+1] .* inforce[:, i] .+ totals[:, i]) .* v[:, i]
    end
    @views val[:, 1] = (val[:, 2] .* inforce[:, 1] + totals[:, 1]) .* v[:, 1]
    return val
end


"""
    iterate_calc(cfs::CompleteCashflows, prob::Union{BigProbabilityDict, BigProbabilityDictGPU}, int_acc::Union{Matrix{Float64}, CuArray{Float32, 2}}, v::Float64, nsims::Int64, proj_max::Int16)::Union{Matrix{Float64}, CuArray{Float64, 2}}

Returns a matrix of valuations for each simulation at each month. The valuation
at each month assumes that the policy is still in force.

This version of the function is specifically intended for profit-testing with a
fixed risk-dicount rate.
"""
function iterate_calc(cfs::CompleteCashflows, prob::Union{BigProbabilityDict, BigProbabilityDictGPU}, int_acc::Union{Matrix{Float64}, CuArray{Float32, 2}}, v::Float64, nsims::Int64, proj_max::Int16)::Union{Matrix{Float64}, CuArray{Float64, 2}}
    totals = get_totals(cfs, prob, int_acc, nsims, proj_max)
    inforce = prob[InForce()]

    if useGPU
        val = CuArray{Float64, 2}(undef, nsims, Int64(proj_max))
    else
        val = Matrix{Float64}(undef, nsims, Int64(proj_max))
    end

    @views val[:, proj_max] = totals[:, proj_max] .* v
    for i in reverse(2:(proj_max-1))
        @inbounds @views val[:, i] = (val[:, i+1] .* inforce[:, i] .+ totals[:, i]) .* v
    end
    @views val[:, 1] = (val[:, 2] .* inforce[:, 1] + totals[:, 1]) .* v
    return val
end


"""
    get_totals(cfs::CompleteCashflows, prob::Union{BigProbabilityDict, BigProbabilityDictGPU}, int_acc::Union{Matrix{Float64}, CuArray{Float32, 2}}, nsims::Int64, proj_max::Int16)::Union{Matrix{Float64}, CuArray{Float64, 2}}

Returns a `Matrix` containing the net expected cashflows for each month in each
simulation. Each cashflow is adjusted for by its probability and interest
applicable for that month only, i.e. conditional on survival to start of month.

"""
function get_totals(cfs::CompleteCashflows, prob::Union{BigProbabilityDict, BigProbabilityDictGPU}, int_acc::Union{Matrix{Float64}, CuArray{Float32, 2}}, nsims::Int64, proj_max::Int16)::Union{Matrix{Float64}, CuArray{Float64, 2}}
    if useGPU
        totals = CUDA.zeros(Float64, nsims, proj_max)
    else
        totals = zeros(Float64, nsims, proj_max)
    end

    for cf in cfs
        cf isa ZeroCashflow && break
        if cf.arrears
            amounts = apply_probability(cf, prob)
        else
            amounts = bring_to_end(cf, int_acc)
        end

        if cf isa Union{PointCashflow, ParallelPointCashflow}
            @inbounds totals[:, cf.time] += amounts
        else
            @inbounds totals += amounts
        end
    end
    return totals
end


# ---------------------------------------------------------------------------- #
# apply_probability applies the relevant probability to cashflows in arrears.
# bring_to_end adds interest to cashflows in advance

# CompleteCashflow

function apply_probability(cf::VectorCashflow, prob::Union{BigProbabilityDict, BigProbabilityDictGPU})::Union{Matrix{Float64}, CuArray{Float64, 2}}
    return transpose(cf.amount) .* prob[cf.contingency]
end

function apply_probability(cf::PointCashflow, prob::Union{BigProbabilityDict, BigProbabilityDictGPU})::Union{Vector{Float64}, CuArray{Float64, 1}}
    return cf.amount .* @view(prob[cf.contingency][:, cf.time])
end

function bring_to_end(cf::VectorCashflow, int_acc::Union{Matrix{Float64}, CuArray{Float32, 2}})::Union{Matrix{Float64}, CuArray{Float64, 2}}
    return transpose(cf.amount) .* int_acc
end

function bring_to_end(cf::PointCashflow, int_acc::Union{Matrix{Float64}, CuArray{Float32, 2}})::Union{Vector{Float64}, CuArray{Float64, 1}}
    return cf.amount .*  @view(int_acc[:, cf.time])
end

# ParallelCashflow

function apply_probability(cf::ParallelVectorCashflow, prob::Union{BigProbabilityDict, BigProbabilityDictGPU})::Union{Matrix{Float64}, CuArray{Float64, 2}}
    return cf.amount .* prob[cf.contingency]
end

function apply_probability(cf::ParallelPointCashflow, prob::Union{BigProbabilityDict, BigProbabilityDictGPU})::Union{Vector{Float64}, CuArray{Float64, 1}}
    return cf.amount .* prob[cf.contingency][:, cf.time]
end

function bring_to_end(cf::ParallelVectorCashflow, int_acc::Union{Matrix{Float64}, CuArray{Float32, 2}})::Union{Matrix{Float64}, CuArray{Float64, 2}}
    return cf.amount .* int_acc
end

function bring_to_end(cf::ParallelPointCashflow, int_acc::Union{Matrix{Float64}, CuArray{Float32, 2}})::Union{Vector{Float64}, CuArray{Float64, 1}}
    return cf.amount .* @view(int_acc[:, cf.time])
end

# ---------------------------------------------------------------------------- #
