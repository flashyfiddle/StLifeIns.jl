abstract type Contingency end
struct Definite <: Contingency end # cashflows that happen with probability 1 throughout
abstract type Indefinite <: Contingency end
abstract type Decrement <: Indefinite end

"""
    InForce()

A [`Contingency`](@ref) based on a policy being in force ([`Life`](@ref) being
alive).
"""
struct InForce <: Indefinite end


"""
    InForce()

A [`Contingency`](@ref) based on a policy ending on death of a [`Life`](@ref).
"""
struct OnDeath <: Decrement end

"""
    InForce()

A [`Contingency`](@ref) based on a policy ending on termination/surrender of a
[`Life`](@ref).    
"""
struct OnTermination <: Decrement end
