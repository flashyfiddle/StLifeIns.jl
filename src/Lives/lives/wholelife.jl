"""
    WholeLife(id, male, age, term_if, max_age=MAX_AGE)

Returns a `SingleLife` that ends on death or termination.

This type of `Life` would be used for a whole life assurance or whole life
annuity.

...
# Arguments
- `id::Int64`: an identifier of the life.
- 'male::Bool': gender indicator (`true` = male, `false` = female).
- 'age::Float64': exact age to month, e.g. 40 and 2 months = 40+2/12.
- `term_if::Int16`: number of months that have already passed sinced initial inception.
- `max_age::Int8`: the age before which the life must die.
...
"""
struct WholeLife <: SingleLife
    id::Int64
    male::Bool
    age::Float64
    term_if::Int16
    max_age::Int8
    proj_max::Int16
    function WholeLife(id, male, age, term_if, max_age=MAX_AGE)
        proj_max = round(Int16, 12(max_age - age))
        return new(id, male, age, term_if, max_age, proj_max)
    end
end
