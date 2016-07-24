const DATA_START = 632 # Start byte for a SAC file's data section
const ASCII_DATA_START = 1672 # Start character for ASCII SAC file's data section

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

# Maps types onto their Header enums.
const FILE_TYPE_ENUMS = Dict{Type,HeaderEnum}(EvenTimeSeries    => itime,
                                              UnevenTimeSeries  => itime,
                                              AmplitudeSpectrum => iamph,
                                              ComplexSpectrum   => irlim,
                                              GeneralXY         => ixy)
