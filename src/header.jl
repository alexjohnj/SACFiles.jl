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

@enum(SACHeaderEnum, itime=1, irlim, iamph, ixy, iunkn, idisp, ivel, iacc, ib,
      iday, io, ia, it0, it1, it2, it3, it4, it5, it6, it7, it8, it9, iradnv,
      itannv, iradev, itanev, inorth, ieast, ihorza, idown, iup, illlbb, iwwsn1,
      iwwsn2, ihglp, isro, inucl, ipren, ipostn, iquake, ipreq, ipostq, ichem,
      iother, igood, iglch, idrop, ilowsn, irldta, ivolts, imb=52, ims, iml, imw,
      imd, imx, ineic, ipdeq, ipdew, ipde, iisc, ireb, iusgs, ibrk, icaltech,
      illnl, ievloc, ijsop, iuser, iunknown, iqb, iqb1, iqb2, iqbx, iqmt, ieq,
      ieq1, ieq2, ime, iex, inu, inc, io_, il, ir, it, iu, ieq3, ieq0, iex0,
      iqc, iqb0, igey, ilit, imet, iodor, ios=103)

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

    SACDataHeader() = new()
end
