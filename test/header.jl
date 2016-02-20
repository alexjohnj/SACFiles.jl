module TestHeaders
using Base.Test
using SACFiles

# Test enums are defined correctly.
ids = vcat(-12345, 1:50, 52:97, 103)
enums = instances(SACHeaderEnum) # This feels dirty. Is instances guaranteed to return the Enums in order?
map(ids, enums) do id, enum
    @test SACHeaderEnum(id) == enum
end

# Test header reading on a hexed file.
open("./test-files/test-hexed-header.sac", "r") do f
    inhdr = readsachdr(f)
    hdr_hexedvalues = Dict{Type, Any}(Float32       => Float32(1337.0),
                                      Int32         => Int32(1337),
                                      SACHeaderEnum => SACFiles.inucl,
                                      ASCIIString   => ascii("BLEEPBLO"),
                                      Bool          => true)
    testhdr = SACDataHeader()

    for val in SACFiles.sacheader_variables
        if val == :UNUSED || val == :INTERNAL
            continue
        end

        if val == :KEVNM
            testhdr.(val) = ascii("BLEEPBLOOPBLEEPS")
        else
            testhdr.(val) = hdr_hexedvalues[typeof(testhdr.(val))]
        end
        @test inhdr.(val) == testhdr.(val)
    end
end

end
