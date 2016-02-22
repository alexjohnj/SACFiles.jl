const sacdata_startb = 632 # Start byte for a SAC file's data section

abstract AbstractSACData
abstract AbstractSACTimeSeries <: AbstractSACData
abstract AbstractSACSpectrum <: AbstractSACData

type SACEvenTimeSeries <: AbstractSACTimeSeries
    hdr::SACDataHeader
    data::Vector{Float32}
end

type SACUnevenTimeSeries <: AbstractSACTimeSeries
    hdr::SACDataHeader
    ddata::Vector{Float32} # Dependent variable
    idata::Vector{Float32} # Independent variable
end

type SACComplexSpectrum <: AbstractSACSpectrum
    hdr::SACDataHeader
    data::Vector{Complex{Float32}}
end

type SACAmplitudeSpectrum <: AbstractSACSpectrum
    hdr::SACDataHeader
    ampdata::Vector{Float32}
    phasedata::Vector{Float32}
end

type SACGeneralXY <: AbstractSACData
    hdr::SACDataHeader
    x::Vector{Float32}
    y::Vector{Float32}
end
