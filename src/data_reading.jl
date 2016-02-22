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

"Read the SAC file stream `f`. Returns a subtype of `AbstractSACData` determined
using the file's header's `iftype` and `leven` variables. Note that this
function isn't type-stable and so shouldn't be used in performance sensitive
code."
readsac(fname::AbstractString) = open(readsac, fname)
function readsac(f::IOStream)
    hdr = readsachdr(f)

    if hdr.iftype == itime && hdr.leven == true
        readsac_eventime(f, hdr)
    elseif hdr.iftype == itime && hdr.leven == false
        readsac_uneventime(f, hdr)
    elseif hdr.iftype == irlim
        readsac_rlim(f, hdr)
    elseif hdr.iftype == iamph
        readsac_amph(f, hdr)
    elseif hdr.iftype == ixy
        readsac_xy(f, hdr)
    end
end

"Read an evenly spaced time series SAC file from the stream `f`. Returns an
instance of `SACEvenTimeSeries`."
readsac_eventime(f::IOStream) = readsac_eventime(f, readsachdr(f))
function readsac_eventime(f::IOStream, hdr::SACDataHeader)
end

"Read an unevenly spaced time series SAC file from the stream `f`. Returns an
instance of `SACUnevenTimeSeries`."
readsac_uneventime(f::IOStream) = readsac_uneventime(f, readsachdr(f))
function readsac_uneventime(f::IOStream, hdr::SACDataHeader)
end

"Read an amplitude/phase SAC file from the stream `f`. Returns an instance of
`SACAmplitudeSpectrum`."
readsac_amph(f::IOStream) = readsac_amph(f, readsachdr(f))
function readsac_amph(f::IOStream, hdr::SACDataHeader)
end

"Read a complex/imaginary SAC file from the stream `f`. Returns an instance of
`SACComplexSpectrum`."
readsac_rlim(f::IOStream) = readsac_rlim(f, readsachdr(f))
function readsac_rlim(f::IOStream, hdr::SACDataHeader)
end

"Read a general XY sac file from the stream `f`. Returns an instance of
`SACGenrealXY`."
readsac_xy(f::IOStream) = readsac_xy(f, readsachdr(f))
function readsac_xy(f::IOStream, hdr::SACDataHeader)
end
