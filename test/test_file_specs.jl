testfile_specs = Dict(EvenTimeSeries =>
                      [Dict("fname" => "./test-files/delta-etime.sac",
                            "data1" => begin x = zeros(Float32, 100); x[50] = 1.0; x; end,
                            "ascii" => false),
                       Dict("fname" => "./test-files/be-delta-etime.sac",
                            "data1" => begin x = zeros(Float32, 100); x[50] = 1.0; x; end,
                            "ascii" => false)],
                      UnevenTimeSeries =>
                      [Dict("fname" => "./test-files/delta-utime.sac",
                            "data1" => begin x = zeros(Float32, 100); x[50] = 1; x; end,
                            "data2" => log(Float32[1:100;]),
                            "ascii" => false)],
                      AmplitudeSpectrum =>
                      [Dict("fname" => "./test-files/delta-amph.sac",
                            "data1" => ones(Float32, 128),
                            "data2" => zeros(Float32, 128),
                            "ascii" => false)],
                      ComplexSpectrum =>
                      [Dict("fname" => "./test-files/delta-rlim.sac",
                            "data1" => fill(1+0im, 128),
                            "ascii" => false)],
                      GeneralXY =>
                      [Dict("fname" => "./test-files/delta-xy.sac",
                            "data1" => begin x = zeros(Float32, 100); x[50] = 1.0; x; end,
                            "data2" => log(Float32[1:100;]),
                            "ascii" => false)])
