using SACFiles
if VERSION >= v"0.5-"
    using Base.Test
else
    using BaseTestNext
    const Test = BaseTestNext
end

include("test_utilities.jl")
include("header.jl")
include("data.jl")
include("io_utils.jl")
