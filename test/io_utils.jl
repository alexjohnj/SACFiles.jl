using SACFiles

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
    end
end
