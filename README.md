# SACFiles.jl

[![Build Status](https://travis-ci.org/alexjohnj/SACFiles.jl.svg?branch=master)](https://travis-ci.org/alexjohnj/SACFiles.jl)

A Julia package for working with SAC ([Seismic Analysis Code][sac-site])
files. At the moment it's focused on binary files. **Very much a work in
progress**. Here's what is/isn't/will be implemented:

[sac-site]: http://ds.iris.edu/ds/nodes/dmc/software/downloads/sac/

- [x] Reading header variables (needs testing).
- [x] Reading first data section from time series files.
- [x] Reading amplitude/phase spectral files.
- [x] Reading real/imaginary spectral files.
- [x] Reading second data section from uneven time series files.
- [x] Reading general XY files.
- [ ] Creating and writing SAC headers.
- [ ] Creating and writing SAC data files.

## Installation

To install just run

``` julia
Pkg.clone("https://github.com/alexjohnj/SACFiles.jl.git")
```

from the Julia REPL. When more has been implemented, I'll look into registering
with `METADATA.jl`.

## Usage

Import the module using the usual `using SACFiles`. Since all that's been
implemented so far is (partial) header reading, the only function of interest is
`readsachdr(f::IOStream)`. This returns a composite type (`SACDataHeader`) which
has fields named the same as the [header variables][sac-file-format-docs] in
SAC. A minimal working example of this:

``` julia
using SACFiles

open("./seismo.sac") do f
    hdr = readsachdr(f)
    println(hdr.NPTS) # Number of points in the file (Int32)
    println(hdr.DELTA) # Sampling rate (Float32)
end
```

The types and functions are commented and have docstrings, so you can use Julia's
built in help function to get more information on them.

[sac-file-format-docs]: http://ds.iris.edu/files/sac-manual/manual/file_format.html
