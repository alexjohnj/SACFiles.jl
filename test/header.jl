module TestHeaders
using Base.Test
using SACFiles

# Test enums are defined correctly.
ids = vcat(-12345, 1:50, 52:97, 103)
enums = instances(SACHeaderEnum) # This feels dirty. Is instances guaranteed to return the Enums in order?
map(ids, enums) do id, enum
    @test SACHeaderEnum(id) == enum
end

end
