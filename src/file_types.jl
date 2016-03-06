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
