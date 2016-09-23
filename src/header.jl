"""
Enumerations for, well, SAC header enumerations. Names are the same as those
defined in the SAC manual. See
<http://ds.iris.edu/files/sac-manual/manual/file_format.html> for details on
each enum. For a list of values, run `instances(HeaderEnum)`.
"""
@enum(HeaderEnum, undefined=-12345, itime=1, irlim, iamph, ixy, iunkn, idisp, ivel, iacc, ib,
      iday, io, ia, it0, it1, it2, it3, it4, it5, it6, it7, it8, it9, iradnv,
      itannv, iradev, itanev, inorth, ieast, ihorza, idown, iup, illlbb, iwwsn1,
      iwwsn2, ihglp, isro, inucl, ipren, ipostn, iquake, ipreq, ipostq, ichem,
      iother, igood, iglch, idrop, ilowsn, irldta, ivolts, imb=52, ims, iml, imw,
      imd, imx, ineic, ipdeq, ipdew, ipde, iisc, ireb, iusgs, ibrk, icaltech,
      illnl, ievloc, ijsop, iuser, iunknown, iqb, iqb1, iqb2, iqbx, iqmt, ieq,
      ieq1, ieq2, ime, iex, inu, inc, io_, il, ir, it, iu, ieq3, ieq0, iex0,
      iqc, iqb0, igey, ilit, imet, iodor, ios=103)

# Undefined values for different data types, as given in the SAC manual.
const HEADER_UNDEFINED_VAL = Dict{Type,Any}(Float32     => Float32(-12345.0),
                                            Int32       => Int32(-12345),
                                            HeaderEnum  => undefined,
                                            Bool        => false,
                                            String => "-12345  " :: String)

const SAC_HDR_VERSION = 6
const SAC_HDR_NWORDS = 158
# Starting characters for each section of the header (1 indexed). Includes
# newline characters.
const SAC_HDR_ASCII_FLOAT_START = 1
const SAC_HDR_ASCII_INT_START = 1065
const SAC_HDR_ASCII_ENUM_START = 1218
const SAC_HDR_ASCII_BOOL_START = 1422
const SAC_HDR_ASCII_ALPHA_START = 1473
const SAC_HDR_ASCII_END = 1672

"""
Description
===========

`Header` represents the header of a SAC file. Fields are initialised with
the default undefined values for Floats, Ints, Enumerations, Bools and Strings
as described in the SAC manual.

Fields
======

Fields have the same name as their header variables in SAC. See
<http://ds.iris.edu/files/sac-manual/manual/file_format.html> for details on
each one. The different header types become the following Julia types:

- Floating     => Float32
- Integer      => Int32
- Enumerated   => HeaderEnum
- Logical      => Bool
- Alphanumeric => String

Constructors
============

The best way to create a new header is to use:

`Header(npts::Int32, beginning::Float32, ending::Float32, ftype::HeaderEnum, even::Bool, delta::Float32; version::Int32=Int32(6))`

This will create a *valid* SAC header with the required fields initialised and
other fields set to their undefined values. You can create an empty header using
`Header()` but required fields will be initialised to their undefined
values so the header will be invalid.

See Also
========

`HeaderEnum` for information on the possible enumerated values.
"""
type Header
    "Increment between evenly spaced samples."
    delta::Float32
    "Minimum value of the dependent variable."
    depmin::Float32
    "Maximum value of the dependent variable."
    depmax::Float32
    "Scale factor for dependent variable (not used by SAC)."
    scale::Float32
    "Observed increment if different from `delta`."
    odelta::Float32
    "Beginning value of the independent variable."
    b::Float32
    "Ending value of the independent variable."
    e::Float32
    "Event origin time relative to the reference time in seconds."
    o::Float32
    "First arrival time relative to reference time in seconds."
    a::Float32
    internal1::Float32
    "User defined time pick or marker."
    t0::Float32
    "User defined time pick or marker."
    t1::Float32
    "User defined time pick or marker."
    t2::Float32
    "User defined time pick or marker."
    t3::Float32
    "User defined time pick or marker."
    t4::Float32
    "User defined time pick or marker."
    t5::Float32
    "User defined time pick or marker."
    t6::Float32
    "User defined time pick or marker."
    t7::Float32
    "User defined time pick or marker."
    t8::Float32
    "User defined time pick or marker."
    t9::Float32
    "End of event time in seconds relative to reference time."
    f::Float32
    "Instrument response parameter (not used by SAC)."
    resp0::Float32
    "Instrument response parameter (not used by SAC)."
    resp1::Float32
    "Instrument response parameter (not used by SAC)."
    resp2::Float32
    "Instrument response parameter (not used by SAC)."
    resp3::Float32
    "Instrument response parameter (not used by SAC)."
    resp4::Float32
    "Instrument response parameter (not used by SAC)."
    resp5::Float32
    "Instrument response parameter (not used by SAC)."
    resp6::Float32
    "Instrument response parameter (not used by SAC)."
    resp7::Float32
    "Instrument response parameter (not used by SAC)."
    resp8::Float32
    "Instrument response parameter (not used by SAC)."
    resp9::Float32
    "Station latitude with degrees north being positive."
    stla::Float32
    "Station longitude with degrees east being positive."
    stlo::Float32
    "Station elevation above sea level in metres."
    stel::Float32
    "Station depth below the surface in metres."
    stdp::Float32
    "Event latitude with degrees north being positive."
    evla::Float32
    "Event longitude with degrees east being positive."
    evlo::Float32
    "Event elevation in metres."
    evel::Float32
    "Event depth below surface in kilometres."
    evdp::Float32
    "Event magnitude."
    mag::Float32
    "User defined variable storage area."
    user0::Float32
    "User defined variable storage area."
    user1::Float32
    "User defined variable storage area."
    user2::Float32
    "User defined variable storage area."
    user3::Float32
    "User defined variable storage area."
    user4::Float32
    "User defined variable storage area."
    user5::Float32
    "User defined variable storage area."
    user6::Float32
    "User defined variable storage area."
    user7::Float32
    "User defined variable storage area."
    user8::Float32
    "User defined variable storage area."
    user9::Float32
    "Station to event distance in kilometres."
    dist::Float32
    "Event to station azimuth in degrees."
    az::Float32
    "Station to event azimuth in degrees."
    baz::Float32
    "Station to event great circle length (degrees)>"
    gcarc::Float32
    internal2::Float32
    internal3::Float32
    "Mean value of the dependent variable."
    depmen::Float32
    "Component azimuth in degrees measured clockwise from north."
    cmpaz::Float32
    "Component incident angle measured in degrees from the vertical."
    cmpinc::Float32
    "Minimum value of X (spectral files only)."
    xminimum::Float32
    "Maximum value of X (spectral files only)."
    xmaximum::Float32
    "Minimum value of Y (spectral files only)."
    yminimum::Float32
    "Maximum value of Y (spectral files only)."
    ymaximum::Float32
    unused1::Float32
    unused2::Float32
    unused3::Float32
    unused4::Float32
    unused5::Float32
    unused6::Float32
    unused7::Float32
    # Integers
    "GMT year corresponding to reference (zero) time in file."
    nzyear::Int32
    "GMT julian day corresponding to reference (zero) time in file."
    nzjday::Int32
    "GMT hour corresponding to reference (zero) time in file."
    nzhour::Int32
    "GMT minute corresponding to reference (zero) time in file."
    nzmin::Int32
    "GMT second corresponding to reference (zero) time in file."
    nzsec::Int32
    "GMT millisecond corresponding to reference (zero) time in file."
    nzmsec::Int32
    "Header version number"
    nvhdr::Int32
    "Origin ID (CSS 3.0)"
    norid::Int32
    "Event ID (CSS 3.0)"
    nevid::Int32
    "Number of points per data component"
    npts::Int32
    internal4::Int32
    "Waveform ID (CSS 3.0)"
    nwfid::Int32
    "Spectral length (spectral files only)."
    nxsize::Int32
    "Spectral width (spectral files only)."
    nysize::Int32
    unused8::Int32
    # Enumerations
    """Type of file. Must be one of:

     - `itime` (Time series file)
     - `irlim` (Spectral file with real and imaginary components)
     - `iamph` (Spectral file with amplitude and phase components)
     - `ixy` (General x vs. y data)
     - `ixyz` (General xyz data)
    """
    iftype::HeaderEnum
    """Type of dependent variable. Possible values include:

    - `iunkn` (Unknown)
    - `idisp` (Displacement in nm)
    - `ivel` (Velocity in nm/sec)
    - `ivolts` (Velocity in volts)
    - `iacc` (Acceleration in nm/sec/sec)
    """
    idep::HeaderEnum
    """Reference time type. Possible values include:

    - `iunkn` (Unknown)
    - `ib` (Begin time)
    - `iday` (Midnight of reference GMT day)
    - `io` (Event origin time)
    - `ia` (First arrival time)
    - `itn` where n = 0:9. (User defined time pick)
    """
    iztype::HeaderEnum
    unused9::HeaderEnum
    "Type of recording instrument (not used by SAC)."
    iinst::HeaderEnum
    "Station geographic region (not used by SAC)."
    istreg::HeaderEnum
    "Event geographic region (not used by SAC)."
    ievreg::HeaderEnum
    """Type of event. One of:

    - `iunkn` (Unknown)
    - `inucl` (Nuclear event)
    - `ipren` (Nuclear pre-shot event)
    - `ipostn` (Nuclear post-shot event)
    - `iquake` (Earthquake)
    - `ipreq` (Foreshock)
    - `ipostq` (Aftershock)
    - `ichem` (Chemical explosion)
    - `iqb` (Quarry or mine blast confirmed by quarry)
    - `iqb1` (Quarry/mine blast with designed shot info-ripple fired)
    - `iqb2` (Quarry/mine blast with observed shot info-ripple fired)
    - `iqbx` (Quarry or mine blast - single shot)
    - `iqmt` (Quarry/mining-induced events: tremors and rockbursts)
    - `ieq` (Earthquake)
    - `ieq1` (Earthquakes in a swarm or aftershock sequence)
    - `ieq2` (Felt earthquake)
    - `ime` (Marine explosion)
    - `iex` (Other explosion)
    - `inu` (Nuclear explosion)
    - `inc` (Nuclear cavity collapse)
    - `io` (Other source of unknown origin)
    - `il` (Local event of unknown origin)
    - `ir` (Regional event of unknown origin)
    - `it` (Teleseismic event of unknown origin)
    - `iu` (Undetermined or conflicting information)
    - `iother` (Other)
    """
    ievtyp::HeaderEnum
    """Quality of data (not used by SAC). Can be one of:

    - `igood` (Good data)
    - `iglch` (Glitches)
    - `idrop` (Dropouts)
    - `ilowsn` (Low signal to noise ratio)
    - `iother` (Other)
    """
    iqual::HeaderEnum
    "Synthetic data flag (not used by SAC). Can be `irldta` (real data)"
    isynth::HeaderEnum
    """Magnitude type. One of:

    - `imb` (Body wave magnitude)
    - `ims` (Surface wave magnitude)
    - `iml` (Local magnitude)
    - `imw` (Moment magnitude)
    - `imd` (Duration magnitude)
    - `imx` (User defined magnitude)
    """
    imagtyp::HeaderEnum
    """Source of magnitude information. One of:

    - `ineic` (National Earthquake Information Center)
    - `ipde` (Preliminary Determination of Epicentre)
    - `iisc` (International Seismological Centre)
    - `ireb` (Review Event Bulletin)
    - `iusgs` (United States Geological Survey)
    - `ibrk` (UC Berkeley)
    - `icaltech` (California Institute of Technology)
    - `illnl` (Lawrence Livermore National Laboratory)
    - `ievloc` (Event Location (computer program))
    - `ijsop` (Join Seismic Observation Program)
    - `iuser` (The individual using SAC2000)
    - `iunknown` (Unknown)
    """
    imagsrc::HeaderEnum
    unused10::HeaderEnum
    unused11::HeaderEnum
    unused12::HeaderEnum
    unused13::HeaderEnum
    unused14::HeaderEnum
    unused15::HeaderEnum
    unused16::HeaderEnum
    unused17::HeaderEnum
    # Logical Variables
    "`true` if data is evenly spaced."
    leven::Bool
    "`true` if station components have a positive polarity (left-hand rule)."
    lpspol::Bool
    "`true` if it is OK to overwrite this file on disk."
    lovrok::Bool
    "True if `dist`, `az`, `baz` and `gcarc` are to be calculated from station
    and event coordinates."
    lcalda::Bool
    unused18::Bool
    # Alphanumerics
    "Station name."
    kstnm::String
    "Event name."
    kevnm::String
    "If nuclear related then the hole identifier. Otherwise, the location identifier."
    khole::String
    "Event origin time identification."
    ko::String
    "First arrival time identification."
    ka::String
    "User defined time pick identifier."
    kt0::String
    "User defined time pick identifier."
    kt1::String
    "User defined time pick identifier."
    kt2::String
    "User defined time pick identifier."
    kt3::String
    "User defined time pick identifier."
    kt4::String
    "User defined time pick identifier."
    kt5::String
    "User defined time pick identifier."
    kt6::String
    "User defined time pick identifier."
    kt7::String
    "User defined time pick identifier."
    kt8::String
    "User defined time pick identifier."
    kt9::String
    "End of event time identification."
    kf::String
    "User defined variable storage area."
    kuser0::String
    "User defined variable storage area."
    kuser1::String
    "User defined variable storage area."
    kuser2::String
    "Channel name."
    kcmpnm::String
    "Name of the seismic network."
    knetwk::String
    "Date data was read onto computer."
    kdatrd::String
    "Generic name of recording instrument."
    kinst::String

    function Header(npts::Integer, b::AbstractFloat, e::AbstractFloat, ftype::HeaderEnum,
                    even::Bool, delta::AbstractFloat)
        hdr = Header()
        hdr.npts = npts
        hdr.b = b
        hdr.e = e
        hdr.iftype = ftype
        hdr.leven = even
        hdr.delta = delta
        hdr.nvhdr = 6

        return hdr
    end

    function Header(npts::Integer, b::AbstractFloat, e::AbstractFloat, ftype::HeaderEnum, even::Bool)
        # This exists because the SAC documentation says that the `delta` header
        # variable is required even though it doesn't make sense for a lot of
        # data types. With this, we can just initialise it to an undefined
        # variable, which is what SAC seems to do.
        Header(npts, b, e, ftype, even, HEADER_UNDEFINED_VAL[Float32])
    end

    Header() = (hdr = new(); set_undefinedvars!(hdr); cleanhdr!(hdr);)
end

"""
Set all the fields of `hdr::Header` to their undefined values as
specified in the SAC manual.
"""
function set_undefinedvars!(hdr::Header)
    for (field, T) in zip(fieldnames(Header), Header.types)
        setfield!(hdr, field, HEADER_UNDEFINED_VAL[T])
    end
    return hdr
end


"""
    cleanhdr!(hdr::Header)

Clean the string fields of `hdr`. This removes all leading/trailing whitespace
and strips null characters.
"""
function cleanhdr!(hdr::Header)
    for field in fieldnames(Header)[end-22:end]
        setfield!(hdr, field, strip(getfield(hdr, field)))
        setfield!(hdr, field, replace(getfield(hdr, field), '\0', ""))
    end

    return hdr
end
