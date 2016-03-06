module SACFiles

export HeaderEnum, Header, readsachdr
export AbstractSACData, AbstractSpectrum, AbstractTimeSeries
export EvenTimeSeries, UnevenTimeSeries, AmplitudeSpectrum, SACComplexSpectrum, SACGeneralXY
export readsac, readsac_eventime, readsac_uneventime, readsac_rlim, readsac_amph, readsac_xy

include("header.jl")
include("file_types.jl")
include("data_reading.jl")

end # module
