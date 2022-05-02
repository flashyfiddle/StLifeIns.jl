using XLSX: readtable
using DataFrames

intmodel_dict = Dict{String, InterestModel}()

t = 2005:1/12:2019

param = DataFrame(readtable(pwd()*"\\src\\InterestModels\\example_models\\models\\Parameters.xlsx", "Parameters", header=false)...)
param = Dict{String, Any}(param[i, 1] => param[i, 2] for i in 1:nrow(param))

intmodel_dict["CIR"] = CIR(t, param["aCIR"], param["bCIR"], param["sigmaCIR"])
intmodel_dict["Vasicek"] = Vasicek(t, param["aVas"], param["bVas"], param["sigmaVas"])

int_start = param["EndValue"]
