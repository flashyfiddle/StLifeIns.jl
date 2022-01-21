"""
    TermLife(id, male, age, term, term_if, max_age=MAX_AGE)

Returns a [`SingleLife`](@ref) that ends at the end of a term or the earlier
death or termination of the life.

This type of [`Life`](@ref) would be used for a term assurance or endowment
assurance contract.

...
# Arguments
- `id::Int64`: an identifier of the life.
- `male::Bool`: gender indicator (`true` = male, `false` = female).
- `age::Float64`: exact age to month, e.g. 40 and 2 months = 40+2/12.
- `term::Int16`: the term lifetime in months defined at inception before which
or at which the life must end.
- `term_if::Int16`: number of months that have already passed sinced initial
inception.
- `max_age::Int8`: the age before which the life must die (else guaranteed to
die).
...
"""
struct TermLife <: SingleLife
    id::Int64
    male::Bool
    age::Float64
    term::Int16
    term_if::Int16
    max_age::Int8
    proj_max::Int16
    function TermLife(id, male, age, term, term_if, max_age=MAX_AGE)
        proj_max = Int16(max(term-term_if, 0))
        if proj_max > round(Int16, 12(max_age - age))
            return WholeLife(id, male, age, term_if, max_age)
        else
            return new(id, male, age, term, term_if, max_age, proj_max)
        end
    end
end
