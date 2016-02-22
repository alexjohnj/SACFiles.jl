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

end
