"""
    setMAX_AGE(x::Int8)

Sets the maximum age, `global MAX_AGE`, used in determining the `proj_max` of
each [`Life`](@ref). A [`Life`](@ref) is guaranteed to die upon reaching age
`global MAX_AGE`.

It is recommended to set the maximum immediately. `MAX_AGE=120` by default.
"""
function setMAX_AGE(x)
    global MAX_AGE = Int8(x)
end

setMAX_AGE(120)
