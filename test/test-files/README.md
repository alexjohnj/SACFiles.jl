# Test Files

SAC files used for unit tests. Files prefixed with `be` are big
endian. Everything else is little endian.

## `test-hexed-header.sac`

This file is used for testing header reading. It has been hex edited so all
header variables of the same type are set to the same value. As a result, it's
completely invalid and can't be read into SAC. The variables are set as follows:

| Type         | Value        |
|--------------|--------------|
| Float        | 1337.0       |
| Integer      | 1337         |
| Enumeration  | 37 (`inucl`) |
| Logical      | `true`       |
| Alphanumeric | "BLEEPBLO"   |

The variable `KEVNM` is set to "BLEEPBLOOPBLEEPS" because its longer than the
other alphanumeric variables. The header version (`NVHDR`) is set to 6, the only
valid field. The data section is simply 100 zero values.

## `test-seismo.sac`

A synthetic seismogram generated using `funcgen seismo` in SAC. Used to test
header reading on a non hex edited file.

## `delta-etime.sac`

An evenly spaced time series file with 100 points at a spike at t=50.

## `delta-utime.sac`

An unevenly spaced time series file with x and y variables. The x variable is
`log(1:100)` while the y variable is 0 except at x=50 where it is 1.

## `delta-amph.sac`

A spectral file containing 128 amplitude and phase data points. It's the
spectrum of a spike at t=1 so the expected amplitude is a constant 1 and the
phase should be zero.
