using StLifeIns
using Test

@testset "StLifeIns.jl" begin
    @test true
end

#=
arima101 = FittedArima([0, 1, 0], [1, 1, 1, 1], [0.1, 0.2, -0.1, -0.2], [], [], 1, 0.2)
simulate_arima(arima101, 2, 10)

lc = LeeCarter(19:120, 1900:2000, collect(19:120), collect(19:120), arima101)

simulate_mortality(lc, 20)
=#
