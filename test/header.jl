@testset "Header Tests" begin
    @testset "Header Enums" begin
        let
            ids = vcat(-12345, 1:50, 52:97, 103)
            enums = collect(instances(HeaderEnum))
            @test enums == map(HeaderEnum, ids)
        end
    end

    @testset "Header Reading" begin
        # Make sure we're reading the whole header
        open("./test-files/test-seismo.sac", "r") do f
            _ = readsachdr(f)
            @test position(f) == 632
        end

        # Test header reading on a hexed file.
        open("./test-files/test-hexed-header.sac", "r") do f
            inhdr = readsachdr(f)
            hdr_hexedvalues = Dict{Type, Any}(Float32     => Float32(1337.0),
                                              Int32       => Int32(1337),
                                              HeaderEnum  => SACFiles.inucl,
                                              ASCIIString => ascii("BLEEPBLO"),
                                              Bool        => true)
            testhdr = Header()

            map(fieldnames(Header), Header.types) do field, T
                if field == :kevnm
                    testhdr.(field) = ascii("BLEEPBLOOPBLEEPS")
                elseif field == :nvhdr
                    testhdr.(field) = 6
                else
                    testhdr.(field) = hdr_hexedvalues[T]
                end
                @test inhdr.(field) == testhdr.(field)
            end
        end

        # Test header reading functions on a synthetic SAC generated seismogram
        testhdr = SACTestUtilities.make_test_seismo_hdr()
        open("./test-files/test-seismo.sac", "r") do f
            inhdr = readsachdr(f)
            SACTestUtilities.testhdrequal(inhdr, testhdr)
        end
        SACTestUtilities.testhdrequal(readsachdr("./test-files/test-seismo.sac"), testhdr)
        SACTestUtilities.testhdrequal(readsachdr("./test-files/be-test-seismo.sac"), testhdr)
    end
end
