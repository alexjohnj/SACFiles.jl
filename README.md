# SACFiles.jl

[![Build Status](https://travis-ci.org/alexjohnj/SACFiles.jl.svg?branch=master)](https://travis-ci.org/alexjohnj/SACFiles.jl)

A Julia package for working with binary SAC ([Seismic Analysis Code][sac-site])
files. It supports reading data in little-endian format. One day it'll support
writing data too.

[sac-site]: http://ds.iris.edu/ds/nodes/dmc/software/downloads/sac/

## Installation

To install just run

``` julia
Pkg.clone("https://github.com/alexjohnj/SACFiles.jl.git")
```

from the Julia REPL.

## Quickstart

`SACFiles.jl` defines a type hierarchy for the different types of SAC files
(even time series, uneven time series, complex spectrum etc.) as well as a bunch
of different methods for reading files. If all you want to do is read and plot a
seismogram though, here's what you'd do:

``` julia
using SACFiles
using Gadfly

s = readsac("seismo.sac")
t = collect(s.hdr.b:s.hdr.delta:s.hdr.e) # beginning-time:sampling-rate:end-time
plot(x=t, y=s.data, Geom.line)
```

Substitute Gadfly for your plotting package of choice.

The `hdr::Header` field is the file's header and its fields are the same
as the header variable names in SAC (in lowercase). All the fields have
docstrings so you can do something like `?Header.b` in the REPL to
find out what some of the more cryptic fields are.

## Usage

### Reading Files

`SACFiles.jl` provides the methods `readsac(fname::AbstractString)` and
`readsac(f::IOStream)` for reading binary SAC files. These return a subtype of
`AbstractSACData`. The concrete type returned is determined from the header of
the SAC file. See the section on types for the possibilities.

The `readsac` function isn't type-stable. `SACFiles.jl` provides the type-stable
functions `readsac_eventime`, `readsac_uneventime`, `readsac_amph`,
`readsac_rlim` and `readsac_xy` if you need type stability. Use these for
performance sensitive code.

The function `readsachdr` reads just the header from a SAC file, returning an
instance of `Header`.

### Types

SAC files can store several different types of data, some of which are related,
so `SACFiles` defines a type-hierarchy to represent this. The two root types are
`Header` and `AbstractSACData`. `Header` is a concrete type that
contains the header of a file. Its fields are the header variables with the same
names as in SAC. Enumerations are defined in `HeaderEnum` and have the same
names as in SAC.

`AbstractSACData` is an abstract type that represents some SAC file. It has
several subtypes that represent the different types of data SAC files can
contain. All the subtypes have a field called `hdr::Header` through which
you can access the header for a file. They also have one or two fields that
contain the data in the SAC file. The types are as follows:

- `EvenTimeSeries <: AbstractTimeSeries <: AbstractSACData`: An evenly
  sampled time series. Data is stored in the `data` field.
- `UnevenTimeSeries <: AbstractTimeSeries <: AbstractSACData`: An unevenly
  sampled time series. The independent variable is stored in the `idata` field
  and the dependant variable is stored in the `ddata` field.
- `ComplexSpectrum <: AbstractSpectrum <: AbstractSACData`: Spectral data
  stored in real and imaginary form. The data is accessible via the
  `data::Vector{Complex{Float32}}` field.
- `AmplitudeSpectrum <: AbstractSpectrum <: AbstractSACData`: Spectral
  data stored in amplitude and phase form. The amplitude data is stored in the
  `ampdata` field and the phase data is stored in the `phasedata` field.
- `SACGeneralXY <: AbstractSACData`: General X vs. Y data. The x variable's data
  is stored in the `x` field and the y variable's is stored in the `y` field.

The SAC binary format stores data as 32-bit floats and integers so the
corresponding fields of these types are vectors of `Float32`s (or
`Complex{Float32}`s). If you see conversion errors from Julia, you might need to
do some explicit casting to and from `Float32`.

[sac-file-format-docs]: http://ds.iris.edu/files/sac-manual/manual/file_format.html
