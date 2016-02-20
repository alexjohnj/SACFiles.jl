# Header variables in the order they appear in the data files. Excluding
# alphanumeric variables (that start with a K), each variable is 1 word (4 B)
# long. Alphanumeric variables are 2 words (8 B) long except for "KENVM" which
# is 4 words (16 B) long. The total length of the header is 158 words (632 B)
# with 133 defined and undefined variables. For a description of these fields
# see: http://ds.iris.edu/files/sac-manual/manual/file_format.html
const sacheader_variables = [
# Float32 variables
:DELTA, :DEPMIN, :DEPMAX, :SCALE, :ODELTA,
:B, :E, :O, :A, :INTERNAL,
:T0, :T1, :T2, :T3, :T4,
:T5, :T6, :T7, :T8, :T9,
:F, :RESP0, :RESP1, :RESP2, :RESP3,
:RESP4, :RESP5, :RESP6, :RESP7, :RESP8,
:RESP9,	:STLA,	:STLO,	:STEL,	:STDP,
:EVLA,	:EVLO,	:EVEL,	:EVDP,	:MAG,
:USER0,	:USER1,	:USER2,	:USER3,	:USER4,
:USER5,	:USER6,	:USER7,	:USER8,	:USER9,
:DIST, :AZ, :BAZ, :GCARC, :INTERNAL,
:INTERNAL, :DEPMEN,	:CMPAZ,	:CMPINC,	:XMINIMUM,
:XMAXIMUM,	:YMINIMUM,	:YMAXIMUM,	:UNUSED,	:UNUSED,
:UNUSED,	:UNUSED,	:UNUSED,	:UNUSED,	:UNUSED,
# End of Floats. Start (word 70) of integers and enumerations
:NZYEAR,	:NZJDAY,	:NZHOUR,	:NZMIN,	:NZSEC,
:NZMSEC, :NVHDR,  :NORID,	:NEVID,	:NPTS,
:INTERNAL, :NWFID,	:NXSIZE,	:NYSIZE,	:UNUSED,
:IFTYPE,  :IDEP,	:IZTYPE,	:UNUSED,	:IINST,
:ISTREG,  :IEVREG,	:IEVTYP,	:IQUAL,	:ISYNTH,
:IMAGTYP,	:IMAGSRC,	:UNUSED,	:UNUSED,	:UNUSED,
:UNUSED,	:UNUSED,	:UNUSED,	:UNUSED,	:UNUSED,
# End of integers and enumerations. Start (word 105) of logical variables.
:LEVEN,	:LPSPOL,	:LOVROK,	:LCALDA,	:UNUSED,
# End of logical variables. Start of alphanumeric variables. All are 2 words long
# except KEVNM which is four words long.
:KSTNM,	:KEVNM,
:KHOLE,	:KO, :KA,
:KT0,	:KT1,	:KT2,
:KT3,	:KT4,	:KT5,
:KT6,	:KT7,	:KT8,
:KT9,	:KF,	:KUSER0,
:KUSER1,	:KUSER2,	:KCMPNM,
:KNETWK,	:KDATRD,	:KINST]

"""
Enumerations for, well, SAC header enumerations. Names are the same as those
defined in the SAC manual. See
<http://ds.iris.edu/files/sac-manual/manual/file_format.html> for details on
each enum. For a list of values, run `instances(SACHeaderEnum)`.
"""
@enum(SACHeaderEnum, undefined=-12345, itime=1, irlim, iamph, ixy, iunkn, idisp, ivel, iacc, ib,
      iday, io, ia, it0, it1, it2, it3, it4, it5, it6, it7, it8, it9, iradnv,
      itannv, iradev, itanev, inorth, ieast, ihorza, idown, iup, illlbb, iwwsn1,
      iwwsn2, ihglp, isro, inucl, ipren, ipostn, iquake, ipreq, ipostq, ichem,
      iother, igood, iglch, idrop, ilowsn, irldta, ivolts, imb=52, ims, iml, imw,
      imd, imx, ineic, ipdeq, ipdew, ipde, iisc, ireb, iusgs, ibrk, icaltech,
      illnl, ievloc, ijsop, iuser, iunknown, iqb, iqb1, iqb2, iqbx, iqmt, ieq,
      ieq1, ieq2, ime, iex, inu, inc, io_, il, ir, it, iu, ieq3, ieq0, iex0,
      iqc, iqb0, igey, ilit, imet, iodor, ios=103)

# Undefined values for different data types, as given in the SAC manual.
const sacheader_undefinedvars = Dict{Type,Any}(
                                               Float32       => Float32(-12345.0),
                                               Int32         => Int32(-12345),
                                               SACHeaderEnum => Int32(-12345),
                                               Bool          => false,
                                               ASCIIString   => "-12345  " :: ASCIIString)

const sac_wordsize = 4
const sachdr_nwords = 158

"""
Construct fields of the same type for a composite type from a splat of
symbols. `T` is the type and `fields...` is a splat of symbols to use for the
fields. This macro explicitly checks if any of the symbols are `:UNUSED:` or
`:INTERNAL` and avoids generating fields for these.
"""
macro makefields(T, fields...)
    exp = :(begin end)
    # Expand the fields arg from a tuple of expressions into a tuple of symbols.
    p = eval(Expr(:call, :tuple, fields...))
    for field in p
        if field != :UNUSED && field != :INTERNAL
            push!(exp.args, :($(field)::$(T)))
        end
    end
    return exp
end

"""
Description
===========

`SACDataHeader` represents the header of a SAC file. Fields are initialised with
the default undefined values for Floats, Ints, Enumerations, Bools and Strings
as described in the SAC manual.

Fields
======

Fields have the same name as their header variables in SAC. See
<http://ds.iris.edu/files/sac-manual/manual/file_format.html> for details on
each one. The different header types become the following Julia types:

- Floating     => Float32
- Integer      => Int32
- Enumerated   => SACHeaderEnum
- Logical      => Bool
- Alphanumeric => ASCIIString

Constructors
============

The best way to create a new header is to use:

`SACDataHeader(npts::Int32, beginning::Float32, ending::Float32, ftype::SACHeaderEnum, even::Bool, delta::Float32; version::Int32=Int32(6))`

This will create a *valid* SAC header with the required fields initialised and
other fields set to their undefined values. You can create an empty header using
`SACDataHeader()` but required fields will be initialised to their undefined
values so the header will be invalid.

See Also
========

`SACHeaderEnum` for information on the possible enumerated values.
"""
type SACDataHeader
    @makefields(Float32, sacheader_variables[1:69]...)
    @makefields(Int32, sacheader_variables[70:84]...)
    @makefields(SACHeaderEnum, sacheader_variables[85:104]...)
    @makefields(Bool, sacheader_variables[105:109]...)
    @makefields(ASCIIString, sacheader_variables[110:end]...)


    function SACDataHeader(npts::Int32, beginning::Float32, ending::Float32,
                           ftype::SACHeaderEnum, even::Bool, delta::Float32;
                           version::Int32=Int32(6))
        hdr = SACDataHeader()
        hdr.NPTS = npts
        hdr.B = beginning
        hdr.E = ending
        hdr.IFTYPE = ftype
        hdr.LEVEN = even
        hdr.DELTA = delta
        hdr.NVHDR = version

        return hdr
    end

    SACDataHeader() = (hdr = new(); set_undefinedvars!(hdr))
end

"""
Set all the fields of `hdr::SACDataHeader` to their undefined values as
specified in the SAC manual.
"""
function set_undefinedvars!(hdr::SACDataHeader)
    map(fieldnames(hdr)) do field
        # Accessing undefined ASCIIString fields produces an exception so here
        # we check for a string by looking at the first character of the
        # symbol. According to the SAC docs, if the first character is 'K' then
        # its an alphanumeric variable.
        if string(field)[1] == 'K'
            hdr.(field) = sacheader_undefinedvars[ASCIIString]
        else
            hdr.(field) = sacheader_undefinedvars[typeof(hdr.(field))]
        end
    end
    return hdr
end

"Read the header data (first 158 words) from the stream `f` returning a
`SACDataHeader` instance constructed from it."
function readsachdr(f::IOStream)
    bs = readbytes(f, sac_wordsize * sachdr_nwords)
    hdr = SACDataHeader()

    decode_floats!(hdr, bs)
    decode_integers!(hdr, bs)
    decode_enumerations!(hdr, bs)
    decode_logicals!(hdr, bs)
    decode_alphanumerics!(hdr, bs)

    return hdr
end

"Read the header data (first 158 words) from the file at path `fname` returning
a `SACDataHeader` instance constructed from it."
function readsachdr(fname::AbstractString)
    return open(readsachdr, fname, "r")
end

"Decode the floating type header variables from the header bytes `bs` and set
the appropriate fields in `hdr`. Returns an `Array{Float32,1}` of decoded
floats."
function decode_floats!(hdr::SACDataHeader, bs::Vector{UInt8})
    # Floats take up words 0 through 69 of the header
    hdr_floats = reinterpret(Float32, bs[1:sac_wordsize * (69+1)])
    for idx in eachindex(hdr_floats)
        val = sacheader_variables[idx]
        if val == :INTERNAL || val == :UNUSED
            continue
        end
        hdr.(val) = hdr_floats[idx]
    end
    return hdr_floats
end

"Decode the integer type header variables from the header bytes `bs` and set the
appropriate fields in `hdr`. Returns an `Array{Int32,1}` of decoded integers."
function decode_integers!(hdr::SACDataHeader, bs::Vector{UInt8})
    # Integers take up words 70 through 84 of the header
    hdr_integers = reinterpret(Int32, bs[sac_wordsize * 70 + 1 : sac_wordsize * (84+1)])
    for idx in eachindex(hdr_integers)
        val = sacheader_variables[idx + 70]
        if val == :INTERNAL || val == :UNUSED
            continue
        end
        hdr.(val) = hdr_integers[idx]
    end

    return hdr_integers
end

"Decode the enumeration type header variables from the header bytes `bs` and set
the appropriate fields in `hdr`. Returns an `Array{SACHeaderEnum,1}` of decoded
enumerations."
function decode_enumerations!(hdr::SACDataHeader, bs::Vector{UInt8})
    # Enumerations take up words 85 through 104 of the header
    hdr_enumerations = reinterpret(SACHeaderEnum, bs[sac_wordsize * 85 + 1 : sac_wordsize * (104+1)])
    for idx in eachindex(hdr_enumerations)
        val = sacheader_variables[idx + 85]
        if val == :INTERNAL || val == :UNUSED
            continue
        end
        hdr.(val) = hdr_enumerations[idx]
    end
    return hdr_enumerations
end

"Decode the logical type header variables from the header bytes `bs` and set the
appropriate fields in `hdr`. Returns an `Array{Bool,1}` of decoded bools.`"
function decode_logicals!(hdr::SACDataHeader, bs::Vector{UInt8})
    # Logicals take up words 105 to 109 of the header. They're 4 bytes long so
    # we convert them to Int32s first and then to Bools.
    hdr_logicals = map(Bool, reinterpret(Int32, bs[sac_wordsize * 105 + 1 : sac_wordsize * (109+1)]))
    for idx in eachindex(hdr_logicals)
        val = sacheader_variables[idx + 105]
        if val == :INTERNAL || val == :UNUSED
            continue
        end
        hdr.(val) = hdr_logicals[idx]
    end
    return hdr_logicals
end

"Decode the alphanumeric type header variables from the header bytes `bs` ans
set the appropriate fields in `hdr`. Returns `nothing`."
function decode_alphanumerics!(hdr::SACDataHeader, bs::Vector{UInt8})
    # Alphanumeric variables take up words 110 through 157 of the header. With
    # the exception of "KENVM", they're all two words (8 characters) long. That
    # one's four words (16 characters) long.

    alpha_bs = bs[sac_wordsize * 110 + 1 : sac_wordsize * (157+1)]
    hdr.KSTNM = ascii(alpha_bs[1:sac_wordsize * 2]) # First two words of alphanumeric header
    hdr.KEVNM = ascii(alpha_bs[sac_wordsize * 2 + 1 : sac_wordsize * (7-1)]) # Next four words of alphanumeric header

    rel_word = 6 # Up to word six
    while rel_word <= 46 # Remaining words to read
        val = sacheader_variables[113 + div(rel_word-6, 2)] # Starting from the 113th variable, KHOLE
        hdr.(val) = ascii(alpha_bs[sac_wordsize * rel_word + 1 : sac_wordsize * (rel_word + 2)])
        rel_word += 2
    end

    return nothing
end
