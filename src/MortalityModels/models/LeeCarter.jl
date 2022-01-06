struct LeeCarter <: GAPC
    x::UnitRange{Int8} # fitted ages
    t::UnitRange{Int16} # fitted years
    αx::Vector{Float64}
    βx::Vector{Float64}
    κt::Arima
end
