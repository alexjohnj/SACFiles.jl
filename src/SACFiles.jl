module SACFiles

export SACHeaderEnum, SACDataHeader, readsachdr
export AbstractSACData, AbstractSACSpectrum, AbstractSACTimeSeries
export SACEvenTimeSeries, SACUnevenTimeSeries, SACAmplitudeSpectrum, SACComplexSpectrum, SACGeneralXY

include("header.jl")
include("data_reading.jl")

end # module
