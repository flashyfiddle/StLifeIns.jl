struct Plat <: MortalityModel
    x::UnitRange{Int8} # fitted ages
    t::UnitRange{Int16} # fitted years
    c::UnitRange{Int16} # cohorts
    αx::Vector{Float64}
    κt::Vector{Arima} # contains κt1, κt2 and κt3
    γc::Arima
end
