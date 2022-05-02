using RData: load

inflmodel_dict = Dict{String, InflationModel}()

infl_param = load(pwd()*"\\src\\InflationModels\\example_models\\models\\inflation_param.RData")["param"]

include(pwd()*"\\src\\InflationModels\\example_models\\models\\inflation_model.jl")

function convert_to_RegWithArimaErrors1(y)
    reg_factors = [i for i in keys(y["beta"])]
    β = values(y["beta"])
    e = y["reg_errors"]

    Φ = y["Phi"]["sar1"]
    Θ = y["Theta"]["sma1"]
    σ = y["sigma"]
    ε = y["arima_errors"]

    RegWithArimaErrors1(reg_factors, β, e, Φ, Θ, σ, ε)
end

inflmodel_dict["Regression with Arima Errors 1"] = convert_to_RegWithArimaErrors1(infl_param)

infl_start = infl_param["end_value"]
