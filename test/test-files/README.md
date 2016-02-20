# Test Files

SAC files used for unit tests.

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
other alphanumeric variables. The data section is simply 100 zero values.
