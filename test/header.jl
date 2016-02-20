module TestHeaders
using Base.Test
using SACFiles
import Utils

# Test enums are defined correctly.
ids = vcat(-12345, 1:50, 52:97, 103)
enums = instances(SACHeaderEnum) # This feels dirty. Is instances guaranteed to return the Enums in order?
map(ids, enums) do id, enum
    @test SACHeaderEnum(id) == enum
end

# Make sure we're reading the whole header
open("./test-files/test-seismo.sac", "r") do f
    _ = readsachdr(f)
    @test position(f) == 632
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

# Test header reading on a synthetic seismogram
open("./test-files/test-seismo.sac", "r") do f
    inhdr = readsachdr(f)
    testhdr = Utils.make_test_seismo_hdr()

    for val in SACFiles.sacheader_variables
        if val == :UNUSED || val == :INTERNAL
            continue
        end

        if typeof(testhdr.(val)) == Float32
            @test_approx_eq inhdr.(val) testhdr.(val)
        else
            @test inhdr.(val) == testhdr.(val)
        end
    end
end

end
