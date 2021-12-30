module Lives

include("set_globals.jl"), export setMAX_AGE, MAX_AGE

export Life, SingleLife, WholeLife, TermLife
include("lives\\life.jl")
include("lives\\wholelife.jl")
include("lives\\termlife.jl")

end
