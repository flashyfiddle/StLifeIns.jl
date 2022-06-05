BigRealisedProbabilityDict = Dict{Contingency, Matrix{Bool}}


"""
    simulate_life(probabilities::BigProbabilityDict, nsims::Integer, proj_max::Integer)::BigRealisedProbabilityDict

Returns a [`BigRealisedProbDict`](@ref), where probabilities are realised and
replaced by simulated `Bool` values.

Also see [`BigProbabilityDict`](@ref), [`dependent_probabilities`](@ref).

"""
function simulate_life(probabilities::BigProbabilityDict, nsims::Integer, proj_max::Integer)::BigRealisedProbabilityDict
    inforce_prob = probabilities[InForce()]
    death_prob = probabilities[OnDeath()]

    inforce = ones(Bool, nsims, proj_max)
    dead = zeros(Bool, nsims, proj_max)
    terminated = zeros(Bool, nsims, proj_max)

    which_inforce = [i for i in 1:nsims]
    i = 0
    while (length(which_inforce) > 0) & (i < proj_max)
        i += 1
        @inbounds @views sim_inforce = inforce_prob[which_inforce, i] .>= rand(length(which_inforce)) # long vectors
        which_!inforce = which_inforce[findall(.!sim_inforce)] # which died or terminated
        if length(which_!inforce) > 0
            @inbounds @views sim_death = (death_prob[which_!inforce, i] ./ (1 .- inforce_prob[which_!inforce, i])) .>= rand(length(which_!inforce))  # most are smaller vectors
            which_died = which_!inforce[sim_death]
            which_terminated = which_!inforce[.!sim_death]
            if length(which_died) > 0
                @inbounds inforce[which_died, i:proj_max] .= false
                @inbounds dead[which_died, i] .= true
            end
            if length(which_terminated) > 0
                @inbounds inforce[which_terminated, i:proj_max] .= false
                @inbounds terminated[which_terminated, i] .= true
            end
        end
        which_inforce = which_inforce[sim_inforce] # which are still in force
    end

    return BigRealisedProbabilityDict(InForce() => inforce, OnDeath() => dead, OnTermination() => terminated)
end
