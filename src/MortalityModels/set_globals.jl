"""
    setYEAR_MON(x::Int8)

Sets the current date, `global YEAR_MON`, used in determining the additional
period for which models must be simulated and forecasted to reach the current
date. Particularly, we point out `simulate_mortality` and `forecast_mortality`.

It is recommended to set the date immediately. `YEAR_MON=2022` by default.

# Examples
```julia-repl
julia> YEAR_MON
2022
julia> setYEAR_MON(2030) # start of January 2030
2030.0
julia> YEAR_MON
2030
```
"""
function setYEAR_MON(x)::Float64
    global YEAR_MON = x
end

setYEAR_MON(2022)
