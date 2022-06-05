"""
Sets calculations to be computed on the GPU.
"""
function setGPU()
    global useGPU = true
end


"""
Sets calculations to be computed on the CPU.
"""
function setCPU()
    global useGPU = false
end

setGPU()
