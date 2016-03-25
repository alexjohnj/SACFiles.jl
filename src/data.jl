const DATA_START = 632 # Start byte for a SAC file's data section

abstract AbstractSACData
abstract AbstractTimeSeries <: AbstractSACData
abstract AbstractSpectrum <: AbstractSACData

"""
An evenly spaced time series.

Fields
======

- `hdr::SACDatHeader` - The file's header.
- `data::Vector{Float32}` - The dependent variable.

See Also
========

- `readsac`
"""
type EvenTimeSeries <: AbstractTimeSeries
    hdr::Header
    data::Vector{Float32}
end

"""
An unevenly spaced time series.

Fields
======

- `hdr::Header` - The file's header.
- `ddata::Vector{Float32}` - The dependent variable.
- `idata::Vector{Float32}` - The independent variable.

See Also
========

- `readsac`
"""
type UnevenTimeSeries <: AbstractTimeSeries
    hdr::Header
    ddata::Vector{Float32} # Dependent variable
    idata::Vector{Float32} # Independent variable
end

"""
Spectral data in complex form.

Fields
======

- `hdr::Header` - The file's header.
- `data::Vector{Complex{Float32}}` - The spectral data.

See Also
========

- `readsac`
"""
type ComplexSpectrum <: AbstractSpectrum
    hdr::Header
    data::Vector{Complex{Float32}}
end

"""
Spectral data in amplitude and phase form.

Fields
======

- `hdr::Header` - The file's header.
- `ampdata::Vector{Float32}` - The amplitude data.
- `phasedata::Vector{Float32}` - The phase data.

See Also
========

- `readsac`
"""
type AmplitudeSpectrum <: AbstractSpectrum
    hdr::Header
    ampdata::Vector{Float32}
    phasedata::Vector{Float32}
end

"""
General x vs. y data.

Fields
======

- `hdr::Header` - The file's header.
- `y::Vector{Float32}` - The y variable's data.
- `x::Vector{Float32}` - The x variable's data.

See Also
========

- `readsac`
"""
type GeneralXY <: AbstractSACData
    hdr::Header
    y::Vector{Float32}
    x::Vector{Float32}
end

const FILE_TYPE_ENUMS = Dict{Type,HeaderEnum}(EvenTimeSeries    => itime,
                                              UnevenTimeSeries  => itime,
                                              AmplitudeSpectrum => iamph,
                                              ComplexSpectrum   => irlim,
                                              GeneralXY         => ixy)

"Read the SAC file stream `f`. Returns a subtype of `AbstractSACData` determined
using the file's header's `iftype` and `leven` variables. Note that this
function isn't type-stable and so shouldn't be used in performance sensitive
code."
readsac(fname::AbstractString; kwargs...) = open((f) -> readsac(f; kwargs...), fname)
function readsac(f::IOStream; kwargs...)
    hdr = readsachdr(f; kwargs...)

    if hdr.iftype == itime && hdr.leven
        readsac(EvenTimeSeries, f, hdr; kwargs...)
    elseif hdr.iftype == itime && !hdr.leven
        readsac(UnevenTimeSeries, f, hdr; kwargs...)
    elseif hdr.iftype == irlim
        readsac(ComplexSpectrum, f, hdr; kwargs...)
    elseif hdr.iftype == iamph
        readsac(AmplitudeSpectrum, f, hdr; kwargs...)
    elseif hdr.iftype == ixy
        readsac(GeneralXY, f, hdr; kwargs...)
    end
end

readsac{S<:AbstractSACData}(T::Type{S}, f::IOStream; kwargs...) = readsac(T, f, readsachdr(f); kwargs...)
function readsac{S<:AbstractSACData}(T::Type{S}, f::IOStream, hdr::Header; kwargs...)
    if hdr.iftype != FILE_TYPE_ENUMS[T]
        error("File's header indicates it is not a $(T)")
    end
    if T == EvenTimeSeries
        T(hdr, readsac_data(f, hdr.npts; kwargs...)[1])
    elseif T == ComplexSpectrum
        T(hdr, complex(readsac_data(f, hdr.npts; kwargs...)...))
    else
        T(hdr, readsac_data(f, hdr.npts; kwargs...)...)
    end
end

"Reads the data section from a file and returns a tuple containing the first and
second data (might be empty) sections. Return type `Tuple{Array{Float32,1},
Array{Float32,1}}."
function readsac_data(f::IOStream, npts::Int32; ascii=false)
    needswap = isalienend(f)
    seek(f, DATA_START)

    data1 = decodesacbytes(Float32, readbytes(f, SAC_WORD_SIZE * npts), needswap)
    if eof(f)
        return (data1, Float32[])
    end

    data2 = decodesacbytes(Float32, readbytes(f, SAC_WORD_SIZE * npts), needswap)
    return (data1, data2)
end
