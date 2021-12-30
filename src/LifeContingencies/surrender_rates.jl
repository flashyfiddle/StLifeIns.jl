function create_surrender_rates(per_len, nsims::Int64, proj::Int64)::Matrix{Float64}
    surrender_rates = Vector{Float64}(undef, proj)
    k = 0
    for i in eachindex(per_len)
        per, len = per_len[i]
        rate = -log(1-per)/12
        if len == Inf
            surrender_rates[(k+1):proj] .= rate
        else
            len = convert(Int64, len)
            surrender_rates[(k+1):(k+len)] .= rate
            k += len
        end
    end

    surrender_rates = transpose(hcat([surrender_rates for i in 1:nsims]...))

    return surrender_rates
end

function lookup_surrender(life::SingleLife, surrender_rates::Matrix{Float64})::Matrix{Float64}
    term = (1:proj_max) .+ life.term_if
    return @view(surrender_rates[:, term])
end
