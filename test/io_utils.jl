using SACFiles
using SACFiles.parsetext

@testset "IO Utilities Tests" begin
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
            let teststrings = ASCIIString["hello", "world"]
                # Test 2 word strings
                map!((s) -> rpad(s, 8, ' '), teststrings)
                bs = convert(Array{UInt8}, string(teststrings...))
                decstrings = SACFiles.decodesacbytes(ASCIIString, bs, 8)
                @test teststrings == decstrings

                # Test 4 word strings
                map!((s) -> rpad(s, 16, ' '), teststrings)
                bs = convert(Array{UInt8}, string(teststrings...))
                decstrings = SACFiles.decodesacbytes(ASCIIString, bs, 16)
                @test teststrings == decstrings

                # Test decoding into a single string
                decstrings = SACFiles.decodesacbytes(ASCIIString, bs, 32)
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
            decstrings = parsetext(ASCIIString, teststring, 8)
            @test teststrings == decstrings
        end
    end
end
