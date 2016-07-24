using SACFiles
if VERSION >= v"0.5-"
    using Base.Test
else
    using BaseTestNext
    const Test = BaseTestNext
end
include("test_utilities.jl")
import SACTestUtilities

include("header.jl")
include("data_types.jl")
include("io.jl")
