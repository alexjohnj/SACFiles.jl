module TestDataReading
using Base.Test
using SACFiles

# Test reading an even time series file.
let expected_data = zeros(Float32, 100)
    expected_data[50] = 1.0
    @test_approx_eq readsac("./test-files/delta-etime.sac").data expected_data
    open("./test-files/delta-etime.sac") do f
        @test_approx_eq readsac(f).data expected_data
        @test_approx_eq readsac(EvenTimeSeries, f).data expected_data
    end
end

# Test reading an unevenly spaced time series file.
let
    expected_ddata = zeros(Float32, 100); expected_ddata[50] = 1.0
    expected_idata = log(collect(Float32(1):Float32(100)))

    open("./test-files/delta-utime.sac") do f
        @test_approx_eq readsac(f).ddata expected_ddata
        @test_approx_eq readsac(f).idata expected_idata
        @test_approx_eq readsac(UnevenTimeSeries, f).ddata expected_ddata
        @test_approx_eq readsac(UnevenTimeSeries, f).idata expected_idata
    end
    @test_approx_eq readsac("./test-files/delta-utime.sac").ddata expected_ddata
    @test_approx_eq readsac("./test-files/delta-utime.sac").idata expected_idata
end

# Test reading a spectral file with amplitude/phase data
let
    expected_ampdata = ones(Float32, 128)
    expected_phasedata = zeros(Float32, 128)

    open("./test-files/delta-amph.sac") do f
        @test_approx_eq readsac(f).ampdata expected_ampdata
        @test_approx_eq readsac(f).phasedata expected_phasedata
        @test_approx_eq readsac(AmplitudeSpectrum, f).ampdata expected_ampdata
        @test_approx_eq readsac(AmplitudeSpectrum, f).phasedata expected_phasedata
    end
    @test_approx_eq readsac("./test-files/delta-amph.sac").ampdata expected_ampdata
    @test_approx_eq readsac("./test-files/delta-amph.sac").phasedata expected_phasedata
end

# Test reading a spectral file with real/imaginary data
let expected_rlimdata = fill(1+0im, 128)
    open("./test-files/delta-rlim.sac") do f
        @test_approx_eq readsac(f).data expected_rlimdata
        @test_approx_eq readsac(ComplexSpectrum, f).data expected_rlimdata
    end

    @test_approx_eq readsac("./test-files/delta-rlim.sac").data expected_rlimdata
end

# Test reading a general x vs. y file
let
    expected_xdata = log(collect(Float32(1):Float32(100)))
    expected_ydata = zeros(Float32, 100); expected_ydata[50] = 1.0

    open("./test-files/delta-xy.sac") do f
        @test_approx_eq readsac(f).x expected_xdata
        @test_approx_eq readsac(f).y expected_ydata
        @test_approx_eq readsac(GeneralXY, f).x expected_xdata
        @test_approx_eq readsac(GeneralXY, f).y expected_ydata
    end

    @test_approx_eq readsac("./test-files/delta-xy.sac").x expected_xdata
    @test_approx_eq readsac("./test-files/delta-xy.sac").y expected_ydata
end

# Make sure the type-stable functions don't try and read data they shouldn't.
let rs(f) = readsac(EvenTimeSeries, f)
    @test_throws ErrorException open(rs, "./test-files/delta-utime.sac")
    @test_throws ErrorException open(rs, "./test-files/delta-amph.sac")
    @test_throws ErrorException open(rs, "./test-files/delta-rlim.sac")
    @test_throws ErrorException open(rs, "./test-files/delta-xy.sac")
end

let rs(f) = readsac(UnevenTimeSeries, f)
    @test_throws ErrorException open(rs, "./test-files/delta-etime.sac")
    @test_throws ErrorException open(rs, "./test-files/delta-amph.sac")
    @test_throws ErrorException open(rs, "./test-files/delta-rlim.sac")
    @test_throws ErrorException open(rs, "./test-files/delta-xy.sac")
end

let rs(f) = readsac(ComplexSpectrum, f)
    @test_throws ErrorException open(rs, "./test-files/delta-etime.sac")
    @test_throws ErrorException open(rs, "./test-files/delta-utime.sac")
    @test_throws ErrorException open(rs, "./test-files/delta-amph.sac")
    @test_throws ErrorException open(rs, "./test-files/delta-xy.sac")
end

let rs(f) = readsac(AmplitudeSpectrum, f)
    @test_throws ErrorException open(rs, "./test-files/delta-etime.sac")
    @test_throws ErrorException open(rs, "./test-files/delta-utime.sac")
    @test_throws ErrorException open(rs, "./test-files/delta-rlim.sac")
    @test_throws ErrorException open(rs, "./test-files/delta-xy.sac")
end

let rs(f) = readsac(GeneralXY, f)
    @test_throws ErrorException open(rs, "./test-files/delta-etime.sac")
    @test_throws ErrorException open(rs, "./test-files/delta-utime.sac")
    @test_throws ErrorException open(rs, "./test-files/delta-rlim.sac")
    @test_throws ErrorException open(rs, "./test-files/delta-amph.sac")
end

end
