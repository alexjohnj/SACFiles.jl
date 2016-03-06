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
- `readsac_eventime`
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
- `readsac_uneventime`
"""
type SACUnevenTimeSeries <: AbstractTimeSeries
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
- `readsac_rlim`
"""
type SACComplexSpectrum <: AbstractSpectrum
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
- `readsac_amph`
"""
type SACAmplitudeSpectrum <: AbstractSpectrum
    hdr::Header
    ampdata::Vector{Float32}
    phasedata::Vector{Float32}
end

"""
General x vs. y data.

Fields
======

- `hdr::Header` - The file's header.
- `x::Vector{Float32}` - The x variable's data.
- `y::Vector{Float32}` - The y variable's data.

See Also
========

- `readsac`
- `readsac_xy`
"""
type SACGeneralXY <: AbstractSACData
    hdr::Header
    x::Vector{Float32}
    y::Vector{Float32}
end
