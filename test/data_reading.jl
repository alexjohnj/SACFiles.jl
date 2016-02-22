module TestDataReading
using Base.Test
using SACFiles
# Test reading an even time series file.
expected_data = zeros(Float32, 100);expected_data[50] = 1.0
@test_approx_eq open(readsac_eventime, "./test-files/delta-etime.sac").data expected_data
@test_approx_eq readsac("./test-files/delta-etime.sac").data expected_data
@test_approx_eq open(readsac, "./test-files/delta-etime.sac").data expected_data

# Test reading an unevenly spaced time series file.
expected_ddata = zeros(Float32, 100); expected_ddata[50] = 1.0
expected_idata = log(collect(Float32(1):Float32(100)))
@test_approx_eq open(readsac_uneventime, "./test-files/delta-utime.sac").ddata expected_ddata
@test_approx_eq open(readsac_uneventime, "./test-files/delta-utime.sac").idata expected_idata
@test_approx_eq readsac("./test-files/delta-utime.sac").ddata expected_ddata
@test_approx_eq readsac("./test-files/delta-utime.sac").idata expected_idata
@test_approx_eq open(readsac, "./test-files/delta-utime.sac").ddata expected_ddata
@test_approx_eq open(readsac, "./test-files/delta-utime.sac").idata expected_idata

# readsac_amph
# Test reading a spectral file with amplitude/phase data
expected_ampdata = ones(Float32, 128)
expected_phasedata = zeros(Float32, 128)
@test_approx_eq open(readsac_amph, "./test-files/delta-amph.sac").ampdata expected_ampdata
@test_approx_eq open(readsac_amph, "./test-files/delta-amph.sac").phasedata expected_phasedata
@test_approx_eq readsac("./test-files/delta-amph.sac").ampdata expected_ampdata
@test_approx_eq readsac("./test-files/delta-amph.sac").phasedata expected_phasedata
@test_approx_eq open(readsac, "./test-files/delta-amph.sac").ampdata expected_ampdata
@test_approx_eq open(readsac, "./test-files/delta-amph.sac").phasedata expected_phasedata

end
