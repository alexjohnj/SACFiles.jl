include("./test_file_specs.jl")

field_mappings = Dict(EvenTimeSeries => Dict("data1" => :data),
                      UnevenTimeSeries => Dict("data1" => :ddata, "data2" => :idata),
                      AmplitudeSpectrum => Dict("data1" => :ampdata, "data2" => :phasedata),
                      ComplexSpectrum => Dict("data1" => :data),
                      GeneralXY => Dict("data1" => :y, "data2" => :x))

@testset "Data Tests" begin
    for (T, files) in testfile_specs
        data1field = field_mappings[T]["data1"]
        data2field = get(field_mappings[T], "data2", :none)

        for file in files
            # Test reading from file name
            readdata = readsac(file["fname"], ascii=file["ascii"])
            @test isapprox(readdata.(data1field), file["data1"])
            if data2field != :none && haskey(file, "data2")
                @test isapprox(readdata.(data2field), file["data2"])
            end

            # Test reading from IOStream
            open(file["fname"]) do f
                # Non-type stable
                readdata = readsac(f, ascii=file["ascii"])
                @test isapprox(readdata.(data1field), file["data1"])
                if data2field != :none && haskey(file, "data2")
                    @test isapprox(readdata.(data2field), file["data2"])
                end

                # Type stable
                readdata = readsac(T, f, ascii=file["ascii"])
                @test isapprox(readdata.(data1field), file["data1"])
                if data2field != :none && haskey(file, "data2")
                    @test isapprox(readdata.(data2field), file["data2"])
                end
            end
        end
    end
end
