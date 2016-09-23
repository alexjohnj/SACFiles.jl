    using SACFiles
using SACFiles.parsetext

@testset "IO" begin
    @testset "Binary Data Decoding" begin
        @testset "Float32" begin
            let testnums = Float32[-12345:12345;]
                decnums = SACFiles.decodesacbytes(Float32, reinterpret(UInt8, testnums))
                @test isapprox(testnums, decnums)

                decnums = SACFiles.decodesacbytes(Float32, reinterpret(UInt8, map(bswap, testnums)), true)
                @test isapprox(testnums, decnums)
            end
        end

        @testset "Int32" begin
            let testnums = Int32[-12345:12345;]
                decnums = SACFiles.decodesacbytes(Int32, reinterpret(UInt8, testnums))
                @test testnums == decnums

                decnums = SACFiles.decodesacbytes(Int32, reinterpret(UInt8, map(bswap, testnums)), true)
                @test testnums == decnums
            end
        end

        @testset "Bool" begin
            # Testing Bools which are just encoded as Int32s
            let testnums = rand(Int32[1, 0], 1000)
                decnums = SACFiles.decodesacbytes(Bool, reinterpret(UInt8, testnums))
                @test testnums == decnums

                decnums = SACFiles.decodesacbytes(Bool, reinterpret(UInt8, map(bswap, testnums)), true)
                @test testnums == decnums

                # Test that -12345 -> true, or anything else for that matter
                # (because that's what SAC does)
                testnums = Int32[1, 0, -12345]
                decnums = SACFiles.decodesacbytes(Bool, reinterpret(UInt8, testnums))
                @test [true, false, true] == decnums

                decnums = SACFiles.decodesacbytes(Bool, reinterpret(UInt8, map(bswap, testnums)), true)
                @test [true, false, true] == decnums
            end
        end

        @testset "Enums" begin
            let testnums = collect(instances(HeaderEnum))
                decnums = SACFiles.decodesacbytes(HeaderEnum, reinterpret(UInt8, testnums))
                @test testnums == decnums

                decnums = SACFiles.decodesacbytes(HeaderEnum,
                                                  reinterpret(UInt8, map((e)->bswap(Int32(e)), testnums)),
                                                  true)
                @test testnums == decnums
            end
        end

        @testset "Strings" begin
            let teststrings = String["hello", "world"]
                # Test 2 word strings
                map!((s) -> rpad(s, 8, ' '), teststrings)
                bs = convert(Array{UInt8}, string(teststrings...))
                decstrings = SACFiles.decodesacbytes(String, bs, 8)
                @test teststrings == decstrings

                # Test 4 word strings
                map!((s) -> rpad(s, 16, ' '), teststrings)
                bs = convert(Array{UInt8}, string(teststrings...))
                decstrings = SACFiles.decodesacbytes(String, bs, 16)
                @test teststrings == decstrings

                # Test decoding into a single string
                decstrings = SACFiles.decodesacbytes(String, bs, 32)
                @test string(teststrings...) == decstrings[1]
            end
        end

        @testset "Endianness Tests" begin
            let endianness = ENDIAN_BOM == 0x04030201 ? :le : :be
                if endianness == :le
                    open("./test-files/test-seismo.sac") do f
                        @test SACFiles.isalienend(f) == false
                    end
                    open("./test-files/be-test-seismo.sac") do f
                        @test SACFiles.isalienend(f) == true
                    end
                else
                    open("./test-files/test-seismo.sac") do f
                        @test SACFiles.isalienend(f) == true
                    end
                    open("./test-files/be-test-seismo.sac") do f
                        @test SACFiles.isalienend(f) == false
                    end
                end
            end
            open("./test-files/test-seismo.sac") do f
                seek(f, 42)
                SACFiles.isalienend(f)
                @test position(f) == 42
            end
        end
    end

    @testset "ASCII Text Parsing" begin
        @testset "Float32" begin
            testnums = Float32[-12345, 12345, 3.14159, 2.71]
            teststring = @sprintf("%15.7f%15.7f\n%15.7f%15.7f", testnums...)
            decnums = parsetext(Float32, teststring)
            @test isapprox(testnums, decnums)
        end

        @testset "Int32" begin
            testnums = Int32[-12345, 12345, 42, 1337]
            teststring = @sprintf("%10d%10d\n%10d%10d", testnums...)
            decnums = parsetext(Int32, teststring)
            @test testnums == decnums
        end

        @testset "Bool" begin
            testnums = [true, false, true, false]
            teststring = @sprintf("%10d%10d\n%10d%10d", testnums...)
            decnums = parsetext(Bool, teststring)
            @test testnums == decnums

            testnums = Int32[1, 0, 1, -12345]
            teststring = @sprintf("%10d%10d\n%10d%10d", testnums...)
            decnums = parsetext(Bool, teststring)
            @test [true, false, true, true] == decnums
        end

        @testset "Enums" begin
            testnums = [SACFiles.itime, SACFiles.iday, SACFiles.icaltech,
                        SACFiles.undefined, SACFiles.ios]
            teststring = @sprintf("%10d%10d%10d\n%10d%10d", reinterpret(Int32, testnums)...)
            decnums = parsetext(HeaderEnum, teststring)
            @test testnums == decnums
        end

        @testset "Strings" begin
            teststrings = ["hello", "world", "this", "is", "a", "test!"]
            teststring = @sprintf("%8s%8s\n%8s%8s%8s%8s", teststrings...)
            decstrings = parsetext(String, teststring, 8)
            @test teststrings == decstrings
        end
    end

@testset "Header File Reading" begin
    @testset "Binary Files" begin
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
                                              String => ascii("BLEEPBLO"),
                                              Bool        => true)
            testhdr = Header()

            map(fieldnames(Header), Header.types) do field, T
                if field == :kevnm
                    setfield!(testhdr, field, ascii("BLEEPBLOOPBLEEPS"))
                elseif field == :nvhdr
                    setfield!(testhdr, field, Int32(6))
                else
                    setfield!(testhdr, field, hdr_hexedvalues[T])
                end
                @test getfield(inhdr, field) == getfield(testhdr, field)
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

    @testset "ASCII Files" begin
        testhdr = SACTestUtilities.make_test_seismo_hdr()
        open("./test-files/test-seismo.txt") do f
            inhdr = readsachdr(f, ascii=true)
            @test position(f) == 1672
            SACTestUtilities.testhdrequal(inhdr, testhdr)
        end
        SACTestUtilities.testhdrequal(readsachdr("./test-files/test-seismo.txt", ascii=true), testhdr)
    end
end

@testset "Data File Reading" begin
    field_mappings = Dict(EvenTimeSeries => Dict("data1" => :data),
                          UnevenTimeSeries => Dict("data1" => :ddata, "data2" => :idata),
                          AmplitudeSpectrum => Dict("data1" => :ampdata, "data2" => :phasedata),
                          ComplexSpectrum => Dict("data1" => :data),
                          GeneralXY => Dict("data1" => :y, "data2" => :x))

    for (T, files) in testfile_specs
        data1field = field_mappings[T]["data1"]
        data2field = get(field_mappings[T], "data2", :none)

        for file in files
            # Test reading from file name
            readdata = readsac(file["fname"], ascii=file["ascii"])
            @test isapprox(getfield(readdata, data1field), file["data1"])
            if data2field != :none && haskey(file, "data2")
                @test isapprox(getfield(readdata, data2field), file["data2"])
            end

            # Test reading from IOStream
            open(file["fname"]) do f
                # Non-type stable
                readdata = readsac(f, ascii=file["ascii"])
                @test isapprox(getfield(readdata, data1field), file["data1"])
                if data2field != :none && haskey(file, "data2")
                    @test isapprox(getfield(readdata, data2field), file["data2"])
                end

                # Type stable
                readdata = readsac(T, f, ascii=file["ascii"])
                @test isapprox(getfield(readdata, data1field), file["data1"])
                if data2field != :none && haskey(file, "data2")
                    @test isapprox(getfield(readdata, data2field), file["data2"])
                end
            end
        end
    end
end
end
