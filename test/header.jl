module TestHeaders
using Base.Test
using SACFiles
import Utils

# Test enums are defined correctly.
ids = vcat(-12345, 1:50, 52:97, 103)
enums = instances(HeaderEnum) # This feels dirty. Is instances guaranteed to return the Enums in order?
map(ids, enums) do id, enum
    @test HeaderEnum(id) == enum
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
                                      HeaderEnum => SACFiles.inucl,
                                      ASCIIString   => ascii("BLEEPBLO"),
                                      Bool          => true)
    testhdr = Header()

    map(fieldnames(Header), Header.types) do field, T
        if field == :kevnm
            testhdr.(field) = ascii("BLEEPBLOOPBLEEPS")
        else
            testhdr.(field) = hdr_hexedvalues[T]
        end
        @test inhdr.(field) == testhdr.(field)
    end
end

# Test header reading functions on a synthetic SAC generated seismogram
testhdr = Utils.make_test_seismo_hdr()
open("./test-files/test-seismo.sac", "r") do f
    inhdr = readsachdr(f)
    Utils.testhdrequal(inhdr, testhdr)
end
Utils.testhdrequal(readsachdr("./test-files/test-seismo.sac"), testhdr)

end
