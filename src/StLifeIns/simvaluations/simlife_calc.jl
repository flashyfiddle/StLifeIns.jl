function sim_calc(cfs::CompleteCashflows, prob::Union{BigRealisedProbabilityDict, BigRealisedProbDictGPU}, int_acc::Union{Matrix{Float64}, CuArray{Float32, 2}}, v::Union{Float64, Matrix{Float64}, CuArray{Float32, 2}}, nsims::Int64, proj_max::Int16)::Union{Vector{Float64}, CuArray{Float64, 1}}
    return iterate_sim_calc(cfs, prob, int_acc, v, nsims, proj_max)[:, 1]
end


function iterate_sim_calc(cfs::CompleteCashflows, prob::Union{BigRealisedProbabilityDict, BigRealisedProbDictGPU}, int_acc::Union{Matrix{Float64}, CuArray{Float32, 2}}, v::Union{Matrix{Float64}, CuArray{Float32, 2}}, nsims::Int64, proj_max::Int16)::Union{Matrix{Float64}, CuArray{Float64, 2}}
    nsims, proj_max = nsims, proj_max
    totals = get_definite_totals(cfs, prob, int_acc, nsims, proj_max)

    if useGPU
        val = CuArray{Float64, 2}(undef, nsims, Int64(proj_max))
    else
        val = Matrix{Float64}(undef, nsims, Int64(proj_max))
    end

    @views val[:, proj_max] = totals[:, proj_max] .* v[:, proj_max]
    for i in reverse(2:(proj_max-1))
        @inbounds @views val[:, i] = (val[:, i+1] .+ totals[:, i]) .* v[:, i]
    end
    @views val[:, 1] = (val[:, 2] + totals[:, 1]) .* v[:, 1]
    return val
end


function iterate_sim_calc(cfs::CompleteCashflows, prob::Union{BigRealisedProbabilityDict, BigRealisedProbDictGPU}, int_acc::Union{Matrix{Float64}, CuArray{Float32, 2}}, v::Float64, nsims::Int64, proj_max::Int16)::Union{Matrix{Float64}, CuArray{Float64, 2}}
    nsims, proj_max = nsims, proj_max
    totals = get_definite_totals(cfs, prob, int_acc, nsims, proj_max)

    if useGPU
        val = CuArray{Float64, 2}(undef, nsims, Int64(proj_max))
    else
        val = Matrix{Float64}(undef, nsims, Int64(proj_max))
    end

    @views val[:, proj_max] = totals[:, proj_max] .* v
    for i in reverse(2:(proj_max-1))
        @inbounds @views val[:, i] = (val[:, i+1] .+ totals[:, i]) .* v
    end
    @views val[:, 1] = (val[:, 2] + totals[:, 1]) .* v
    return val
end


function get_definite_totals(cfs::CompleteCashflows, prob::Union{BigRealisedProbabilityDict, BigRealisedProbDictGPU}, int_acc::Union{Matrix{Float64}, CuArray{Float32, 2}}, nsims::Int64, proj_max::Int16)::Union{Matrix{Float64}, CuArray{Float64, 2}}
    if useGPU
        totals = CUDA.zeros(Float64, nsims, proj_max)
    else
        totals = zeros(Float64, nsims, proj_max)
    end

    for cf in cfs
        cf isa ZeroCashflow && continue
        if cf.arrears
            amounts = definite_arrears(cf, prob)
        else
            amounts = definite_advance(cf, prob, int_acc, proj_max)
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
# definite_arrears accepts all arrears cashflows that atcually occured
# definite_advance adds interest to all cashflows in advance that actually occured

# CompleteCashflow

function definite_arrears(cf::VectorCashflow, prob::Union{BigRealisedProbabilityDict, BigRealisedProbDictGPU})::Union{Matrix{Float64}, CuArray{Float64, 2}}
    return transpose(cf.amount) .* prob[cf.contingency]
end

function definite_arrears(cf::PointCashflow, prob::Union{BigRealisedProbabilityDict, BigRealisedProbDictGPU})::Union{Vector{Float64}, CuArray{Float64, 1}}
    return cf.amount .* @view(prob[cf.contingency][:, cf.time])
end

function definite_advance(cf::VectorCashflow, prob::Union{BigRealisedProbabilityDict, BigRealisedProbDictGPU}, int_acc::Union{Matrix{Float64}, CuArray{Float32, 2}}, proj_max::Int16)::Union{Matrix{Float64}, CuArray{Float64, 2}}
    amount = transpose(cf.amount) .* int_acc
    if proj_max > 1
        @views amount[:, 2:proj_max] .*= prob[cf.contingency][:, 1:(proj_max-1)]
    end
    return amount
end

function definite_advance(cf::PointCashflow, prob::Union{BigRealisedProbabilityDict, BigRealisedProbDictGPU}, int_acc::Union{Matrix{Float64}, CuArray{Float32, 2}}, proj_max::Int16)::Union{Vector{Float64}, CuArray{Float64, 1}}
    amount = cf.amount .* @view(int_acc[:, cf.time])
    if cf.time > 1
        @views amount[2:proj_max] .*= prob[cf.contingency][:, cf.time-1]
    end
    return amount
end

# ParallelCashflow

function definite_arrears(cf::ParallelVectorCashflow, prob::Union{BigRealisedProbabilityDict, BigRealisedProbDictGPU})::Union{Matrix{Float64}, CuArray{Float64, 2}}
    return cf.amount .* prob[cf.contingency]
end

function definite_arrears(cf::ParallelPointCashflow, prob::Union{BigRealisedProbabilityDict, BigRealisedProbDictGPU})::Union{Vector{Float64}, CuArray{Float64, 1}}
    return cf.amount .* prob[cf.contingency][:, cf.time]
end

function definite_advance(cf::ParallelVectorCashflow, prob::Union{BigRealisedProbabilityDict, BigRealisedProbDictGPU}, int_acc::Union{Matrix{Float64}, CuArray{Float32, 2}}, proj_max::Int16)::Union{Matrix{Float64}, CuArray{Float64, 2}}
    amount = cf.amount .* int_acc
    if proj_max > 1
        @views amount[:, 2:proj_max] .*= prob[cf.contingency][:, 1:(proj_max-1)]
    end
    return amount
end

function definite_advance(cf::ParallelPointCashflow, prob::Union{BigRealisedProbabilityDict, BigRealisedProbDictGPU}, int_acc::Union{Matrix{Float64}, CuArray{Float32, 2}}, proj_max::Int16)::Union{Vector{Float64}, CuArray{Float64, 1}}
    amount = cf.amount .* @view(int_acc[:, cf.time])
    if proj_max > 1
        @views amount[2:proj_max] .*= prob[cf.contingency][:, cf.time]
    end
    return
end

# ---------------------------------------------------------------------------- #
