# Header variables in the order they appear in the data files. Excluding
# alphanumeric variables (that start with a K), each variable is 1 word (4 B)
# long. Alphanumeric variables are 2 words (8 B) long except for "KENVM" which
# is 4 words (16 B) long. The total length of the header is 158 words (632 B)
# with 133 defined and undefined variables. For a description of these fields
# see: http://ds.iris.edu/files/sac-manual/manual/file_format.html
const sacheader_variables = [
# Float32 variables
:delta, :depmin, :depmax, :scale, :odelta,
:b, :e, :o, :a, :internal,
:t0, :t1, :t2, :t3, :t4,
:t5, :t6, :t7, :t8, :t9,
:f, :resp0, :resp1, :resp2, :resp3,
:resp4, :resp5, :resp6, :resp7, :resp8,
:resp9,	:stla,	:stlo,	:stel,	:stdp,
:evla,	:evlo,	:evel,	:evdp,	:mag,
:user0,	:user1,	:user2,	:user3,	:user4,
:user5,	:user6,	:user7,	:user8,	:user9,
:dist, :az, :baz, :gcarc, :internal,
:internal, :depmen,	:cmpaz,	:cmpinc,	:xminimum,
:xmaximum,	:yminimum,	:ymaximum,	:unused,	:unused,
:unused,	:unused,	:unused,	:unused,	:unused,
# end of floats. start (word 70) of integers and enumerations
:nzyear,	:nzjday,	:nzhour,	:nzmin,	:nzsec,
:nzmsec, :nvhdr,  :norid,	:nevid,	:npts,
:internal, :nwfid,	:nxsize,	:nysize,	:unused,
:iftype,  :idep,	:iztype,	:unused,	:iinst,
:istreg,  :ievreg,	:ievtyp,	:iqual,	:isynth,
:imagtyp,	:imagsrc,	:unused,	:unused,	:unused,
:unused,	:unused,	:unused,	:unused,	:unused,
# end of integers and enumerations. start (word 105) of logical variables.
:leven,	:lpspol,	:lovrok,	:lcalda,	:unused,
# end of logical variables. start of alphanumeric variables. all are 2 words long
# except kevnm which is four words long.
:kstnm,	:kevnm,
:khole,	:ko, :ka,
:kt0,	:kt1,	:kt2,
:kt3,	:kt4,	:kt5,
:kt6,	:kt7,	:kt8,
:kt9,	:kf,	:kuser0,
:kuser1,	:kuser2,	:kcmpnm,
:knetwk,	:kdatrd,	:kinst]

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
    delta::Float32
    depmin::Float32
    depmax::Float32
    scale::Float32
    odelta::Float32
    b::Float32
    e::Float32
    o::Float32
    a::Float32
    internal1::Float32
    t0::Float32
    t1::Float32
    t2::Float32
    t3::Float32
    t4::Float32
    t5::Float32
    t6::Float32
    t7::Float32
    t8::Float32
    t9::Float32
    f::Float32
    resp0::Float32
    resp1::Float32
    resp2::Float32
    resp3::Float32
    resp4::Float32
    resp5::Float32
    resp6::Float32
    resp7::Float32
    resp8::Float32
    resp9::Float32
    stla::Float32
    stlo::Float32
    stel::Float32
    stdp::Float32
    evla::Float32
    evlo::Float32
    evel::Float32
    evdp::Float32
    mag::Float32
    user0::Float32
    user1::Float32
    user2::Float32
    user3::Float32
    user4::Float32
    user5::Float32
    user6::Float32
    user7::Float32
    user8::Float32
    user9::Float32
    dist::Float32
    az::Float32
    baz::Float32
    gcarc::Float32
    internal2::Float32
    internal3::Float32
    depmen::Float32
    cmpaz::Float32
    cmpinc::Float32
    xminimum::Float32
    xmaximum::Float32
    yminimum::Float32
    ymaximum::Float32
    unused1::Float32
    unused2::Float32
    unused3::Float32
    unused4::Float32
    unused5::Float32
    unused6::Float32
    unused7::Float32
    # Integers
    nzyear::Int32
    nzjday::Int32
    nzhour::Int32
    nzmin::Int32
    nzsec::Int32
    nzmsec::Int32
    nvhdr::Int32
    norid::Int32
    nevid::Int32
    npts::Int32
    internal4::Int32
    nwfid::Int32
    nxsize::Int32
    nysize::Int32
    unused8::Int32
    # Enumerations
    iftype::SACHeaderEnum
    idep::SACHeaderEnum
    iztype::SACHeaderEnum
    unused9::SACHeaderEnum
    iinst::SACHeaderEnum
    istreg::SACHeaderEnum
    ievreg::SACHeaderEnum
    ievtyp::SACHeaderEnum
    iqual::SACHeaderEnum
    isynth::SACHeaderEnum
    imagtyp::SACHeaderEnum
    imagsrc::SACHeaderEnum
    unused10::SACHeaderEnum
    unused11::SACHeaderEnum
    unused12::SACHeaderEnum
    unused13::SACHeaderEnum
    unused14::SACHeaderEnum
    unused15::SACHeaderEnum
    unused16::SACHeaderEnum
    unused17::SACHeaderEnum
    # Logical Variables
    leven::Bool
    lpspol::Bool
    lovrok::Bool
    lcalda::Bool
    unused18::Bool
    # Alphanumerics
    kstnm::ASCIIString
    kevnm::ASCIIString
    khole::ASCIIString
    ko::ASCIIString
    ka::ASCIIString
    kt0::ASCIIString
    kt1::ASCIIString
    kt2::ASCIIString
    kt3::ASCIIString
    kt4::ASCIIString
    kt5::ASCIIString
    kt6::ASCIIString
    kt7::ASCIIString
    kt8::ASCIIString
    kt9::ASCIIString
    kf::ASCIIString
    kuser0::ASCIIString
    kuser1::ASCIIString
    kuser2::ASCIIString
    kcmpnm::ASCIIString
    knetwk::ASCIIString
    kdatrd::ASCIIString
    kinst::ASCIIString

    function SACDataHeader(npts::Int32, beginning::Float32, ending::Float32,
                           ftype::SACHeaderEnum, even::Bool, delta::Float32;
                           version::Int32=Int32(6))
        hdr = SACDataHeader()
        hdr.npts = npts
        hdr.b = beginning
        hdr.e = ending
        hdr.iftype = ftype
        hdr.leven = even
        hdr.delta = delta
        hdr.nvhdr = version

        return hdr
    end

    SACDataHeader() = (hdr = new(); set_undefinedvars!(hdr))
end

"""
Set all the fields of `hdr::SACDataHeader` to their undefined values as
specified in the SAC manual.
"""
function set_undefinedvars!(hdr::SACDataHeader)
    for (field, T) in zip(fieldnames(SACDataHeader), SACDataHeader.types)
        hdr.(field) = sacheader_undefinedvars[T]
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
        if val == :internal || val == :unused
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
        if val == :internal || val == :unused
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
        if val == :internal || val == :unused
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
        if val == :internal || val == :unused
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
    hdr.kstnm = ascii(alpha_bs[1:sac_wordsize * 2]) # first two words of alphanumeric header
    hdr.kevnm = ascii(alpha_bs[sac_wordsize * 2 + 1 : sac_wordsize * (7-1)]) # Next four words of alphanumeric header

    rel_word = 6 # Up to word six
    while rel_word <= 46 # Remaining words to read
        val = sacheader_variables[113 + div(rel_word-6, 2)] # Starting from the 113th variable, KHOLE
        hdr.(val) = ascii(alpha_bs[sac_wordsize * rel_word + 1 : sac_wordsize * (rel_word + 2)])
        rel_word += 2
    end

    return nothing
end
