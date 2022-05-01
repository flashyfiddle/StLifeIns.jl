PLATs = @suppress_err load(pwd()*"\\src\\MortalityModels\\example_models\\Plat\\PLAT.RData")

function read_PLAT(y)
    x = [parse(Int, i) for i in keys(y["ax"])]
    x = minimum(x):maximum(x) # ages fitted
    t = [parse(Int, i) for i in keys(y["kt"][1]["y"])]
    t = minimum(t):maximum(t) # years fitted
    c = [parse(Int, i) for i in keys(y["gc"]["y"])]
    c = minimum(c):maximum(c) # cohorts fitted
    αx = values(y["ax"])
    κt = [read_Arima(y["kt"][i]) for i in 1:3]
    γc = read_Arima(y["gc"])
    return Plat(x, t, c, αx, κt, γc)
end


function read_Arima(x)
    order = x["order"]
    y = values(x["y"])
    e = values(x["e"])
    φ = ifelse(x["phi"] == 0, [], values(x["phi"]))
    θ = ifelse(x["theta"] == 0, [], values(x["theta"]))
    if typeof(φ) == Float64
        φ = [φ]
    end
    if typeof(θ) == Float64
        θ = [θ]
    end
    μ = x["mu"]
    σ = x["sigma"]
    return FittedArima(order, y, e, φ, θ, μ, σ)
end

mortmodel_dict["Plat Poisson"] = Dict(true => read_PLAT(PLATs["PLATM"]), false => read_PLAT(PLATs["PLATF"]))
