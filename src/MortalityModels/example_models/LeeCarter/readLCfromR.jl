LCs = @suppress_err load(pwd()*"\\src\\MortalityModels\\example_models\\LeeCarter\\LeeCarter.RData")

function read_LC(y)
    x = [parse(Int, i) for i in keys(y["ax"])]
    x = minimum(x):maximum(x) # ages fitted
    t = [parse(Int, i) for i in keys(y["kt"]["y"])]
    t = minimum(t):maximum(t) # years fitted
    αx, βx = values(y["ax"]), values(y["bx"])
    κt = read_Arima(y["kt"])
    return LeeCarter(x, t, αx, βx, κt)
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

mortmodel_dict["Lee-Carter Poisson"] = Dict(true => read_LC(LCs["LCpoisMale"]), false => read_LC(LCs["LCpoisFemale"]))
mortmodel_dict["Lee-Carter Negative Binomial"] = Dict(true => read_LC(LCs["LCnbMale"]), false => read_LC(LCs["LCnbFemale"]))
