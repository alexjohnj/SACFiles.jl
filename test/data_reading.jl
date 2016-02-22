module TestDataReading
using Base.Test
using SACFiles
# Test reading an even time series file.
expected_data = zeros(Float32, 100);expected_data[50] = 1.0
@test_approx_eq open(readsac_eventime, "./test-files/delta-etime.sac").data expected_data
@test_approx_eq readsac("./test-files/delta-etime.sac").data expected_data
@test_approx_eq open(readsac, "./test-files/delta-etime.sac").data expected_data

end
