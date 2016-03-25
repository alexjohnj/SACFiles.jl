@testset "Data Tests" begin
    @testset "Even Time Series" begin
        let expected_data = zeros(Float32, 100)
            expected_data[50] = 1.0
            @test isapprox(readsac("./test-files/delta-etime.sac").data, expected_data)
            open("./test-files/delta-etime.sac") do f
                @test isapprox(readsac(f).data, expected_data)
                @test isapprox(readsac(EvenTimeSeries, f).data, expected_data)
            end

            # Test on a big endian file
            @test isapprox(readsac("./test-files/be-delta-etime.sac").data, expected_data)
        end
        let rs(f) = readsac(EvenTimeSeries, f)
            @test_throws ErrorException open(rs, "./test-files/delta-amph.sac")
            @test_throws ErrorException open(rs, "./test-files/delta-rlim.sac")
            @test_throws ErrorException open(rs, "./test-files/delta-xy.sac")
        end

    end

    @testset "Uneven Time Series" begin
        let
            expected_ddata = zeros(Float32, 100); expected_ddata[50] = 1.0
            expected_idata = log(collect(Float32(1):Float32(100)))

            open("./test-files/delta-utime.sac") do f
                @test isapprox(readsac(f).ddata, expected_ddata)
                @test isapprox(readsac(f).idata, expected_idata)
                @test isapprox(readsac(UnevenTimeSeries, f).ddata, expected_ddata)
                @test isapprox(readsac(UnevenTimeSeries, f).idata, expected_idata)
            end
            @test isapprox(readsac("./test-files/delta-utime.sac").ddata, expected_ddata)
            @test isapprox(readsac("./test-files/delta-utime.sac").idata, expected_idata)
        end

        let rs(f) = readsac(UnevenTimeSeries, f)
            @test_throws ErrorException open(rs, "./test-files/delta-amph.sac")
            @test_throws ErrorException open(rs, "./test-files/delta-rlim.sac")
            @test_throws ErrorException open(rs, "./test-files/delta-xy.sac")
        end
    end

    @testset "Amplitude Phase Spectrum" begin
        let
            expected_ampdata = ones(Float32, 128)
            expected_phasedata = zeros(Float32, 128)

            open("./test-files/delta-amph.sac") do f
                @test isapprox(readsac(f).ampdata, expected_ampdata)
                @test isapprox(readsac(f).phasedata, expected_phasedata)
                @test isapprox(readsac(AmplitudeSpectrum, f).ampdata, expected_ampdata)
                @test isapprox(readsac(AmplitudeSpectrum, f).phasedata, expected_phasedata)
            end
            @test isapprox(readsac("./test-files/delta-amph.sac").ampdata, expected_ampdata)
            @test isapprox(readsac("./test-files/delta-amph.sac").phasedata, expected_phasedata)
        end

        let rs(f) = readsac(AmplitudeSpectrum, f)
            @test_throws ErrorException open(rs, "./test-files/delta-etime.sac")
            @test_throws ErrorException open(rs, "./test-files/delta-utime.sac")
            @test_throws ErrorException open(rs, "./test-files/delta-rlim.sac")
            @test_throws ErrorException open(rs, "./test-files/delta-xy.sac")
        end
    end

    @testset "Real/Imaginary Spectrum" begin
        let expected_rlimdata = fill(1+0im, 128)
            open("./test-files/delta-rlim.sac") do f
                @test isapprox(readsac(f).data, expected_rlimdata)
                @test isapprox(readsac(ComplexSpectrum, f).data, expected_rlimdata)
            end

            @test isapprox(readsac("./test-files/delta-rlim.sac").data, expected_rlimdata)
        end

        let rs(f) = readsac(ComplexSpectrum, f)
            @test_throws ErrorException open(rs, "./test-files/delta-etime.sac")
            @test_throws ErrorException open(rs, "./test-files/delta-utime.sac")
            @test_throws ErrorException open(rs, "./test-files/delta-amph.sac")
            @test_throws ErrorException open(rs, "./test-files/delta-xy.sac")
        end
    end

    @testset "General XY Data" begin
        let
            expected_xdata = log(collect(Float32(1):Float32(100)))
            expected_ydata = zeros(Float32, 100); expected_ydata[50] = 1.0

            open("./test-files/delta-xy.sac") do f
                @test isapprox(readsac(f).x, expected_xdata)
                @test isapprox(readsac(f).y, expected_ydata)
                @test isapprox(readsac(GeneralXY, f).x, expected_xdata)
                @test isapprox(readsac(GeneralXY, f).y, expected_ydata)
            end

            @test isapprox(readsac("./test-files/delta-xy.sac").x, expected_xdata)
            @test isapprox(readsac("./test-files/delta-xy.sac").y, expected_ydata)
        end

        let rs(f) = readsac(GeneralXY, f)
            @test_throws ErrorException open(rs, "./test-files/delta-etime.sac")
            @test_throws ErrorException open(rs, "./test-files/delta-utime.sac")
            @test_throws ErrorException open(rs, "./test-files/delta-rlim.sac")
            @test_throws ErrorException open(rs, "./test-files/delta-amph.sac")
        end
    end
end
