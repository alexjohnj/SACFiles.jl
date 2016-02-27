const sacdata_startb = 632 # Start byte for a SAC file's data section

abstract AbstractSACData
abstract AbstractSACTimeSeries <: AbstractSACData
abstract AbstractSACSpectrum <: AbstractSACData

"""
An evenly spaced time series.

Fields
======

- `hdr::SACDatHeader` - The file's header.
- `data::Vector{Float32}` - The dependent variable.

See Also
========

- `readsac`
- `readsac_eventime`
"""
type SACEvenTimeSeries <: AbstractSACTimeSeries
    hdr::SACDataHeader
    data::Vector{Float32}
end

"""
An unevenly spaced time series.

Fields
======

- `hdr::SACDataHeader` - The file's header.
- `ddata::Vector{Float32}` - The dependent variable.
- `idata::Vector{Float32}` - The independent variable.

See Also
========

- `readsac`
- `readsac_uneventime`
"""
type SACUnevenTimeSeries <: AbstractSACTimeSeries
    hdr::SACDataHeader
    ddata::Vector{Float32} # Dependent variable
    idata::Vector{Float32} # Independent variable
end

"""
Spectral data in complex form.

Fields
======

- `hdr::SACDataHeader` - The file's header.
- `data::Vector{Complex{Float32}}` - The spectral data.

See Also
========

- `readsac`
- `readsac_rlim`
"""
type SACComplexSpectrum <: AbstractSACSpectrum
    hdr::SACDataHeader
    data::Vector{Complex{Float32}}
end

"""
Spectral data in amplitude and phase form.

Fields
======

- `hdr::SACDataHeader` - The file's header.
- `ampdata::Vector{Float32}` - The amplitude data.
- `phasedata::Vector{Float32}` - The phase data.

See Also
========

- `readsac`
- `readsac_amph`
"""
type SACAmplitudeSpectrum <: AbstractSACSpectrum
    hdr::SACDataHeader
    ampdata::Vector{Float32}
    phasedata::Vector{Float32}
end

"""
General x vs. y data.

Fields
======

- `hdr::SACDataHeader` - The file's header.
- `x::Vector{Float32}` - The x variable's data.
- `y::Vector{Float32}` - The y variable's data.

See Also
========

- `readsac`
- `readsac_xy`
"""
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

    if hdr.iftype == itime && hdr.leven
        readsac_eventime(f, hdr)
    elseif hdr.iftype == itime && !hdr.leven
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
    if hdr.iftype != itime || !hdr.leven
        error("File's header indicates it is not an even time series.")
    end
    SACEvenTimeSeries(hdr, readsac_data(f, hdr.npts)[1])
end

"Read an unevenly spaced time series SAC file from the stream `f`. Returns an
instance of `SACUnevenTimeSeries`."
readsac_uneventime(f::IOStream) = readsac_uneventime(f, readsachdr(f))
function readsac_uneventime(f::IOStream, hdr::SACDataHeader)
    if hdr.iftype != itime || hdr.leven
        error("File's header indicates it is not an uneven time series.")
    end
    SACUnevenTimeSeries(hdr, readsac_data(f, hdr.npts)...)
end

"Read an amplitude/phase SAC file from the stream `f`. Returns an instance of
`SACAmplitudeSpectrum`."
readsac_amph(f::IOStream) = readsac_amph(f, readsachdr(f))
function readsac_amph(f::IOStream, hdr::SACDataHeader)
    if hdr.iftype != iamph
        error("File's header indicates it is not an amplitude/phase spectrum.")
    end
    SACAmplitudeSpectrum(hdr, readsac_data(f, hdr.npts)...)
end

"Read a complex/imaginary SAC file from the stream `f`. Returns an instance of
`SACComplexSpectrum`."
readsac_rlim(f::IOStream) = readsac_rlim(f, readsachdr(f))
function readsac_rlim(f::IOStream, hdr::SACDataHeader)
    if hdr.iftype != irlim
        error("File's header indicates it is not a real/imaginary spectrum.")
    end
    SACComplexSpectrum(hdr, complex(readsac_data(f, hdr.npts)...))
end

"Read a general XY sac file from the stream `f`. Returns an instance of
`SACGenrealXY`."
readsac_xy(f::IOStream) = readsac_xy(f, readsachdr(f))
function readsac_xy(f::IOStream, hdr::SACDataHeader)
    if hdr.iftype != ixy
        error("File's header indicates it is not a general x vs. y file.")
    end
    SACGeneralXY(hdr, reverse(readsac_data(f, hdr.npts))...)
end

"Reads the data section from a file and returns a tuple containing the first and
second data (might be empty) sections. Return type `Tuple{Array{Float32,1},
Array{Float32,1}}."
function readsac_data(f::IOStream, npts::Int32)
    seek(f, sacdata_startb)
    data1 = reinterpret(Float32, readbytes(f, sac_wordsize * npts))
    if eof(f)
        return (data1, Float32[])
    end
    data2 = reinterpret(Float32, readbytes(f, sac_wordsize * npts))

    return (data1, data2)
end
