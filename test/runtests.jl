using SACFiles
if VERSION >= v"0.5-"
    using Base.Test
else
    using BaseTestNext
    const Test = BaseTestNext
end

include("utils.jl")
include("header.jl")
include("data.jl")
