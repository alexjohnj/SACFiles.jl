module Utils
using Base.Test
using SACFiles

"Creates an instance of `SACDataHeader` with the fields manually initialised to
the header variables of './test-files/test-seismo.sac'."
function make_test_seismo_hdr()
    hdr = SACDataHeader(Int32(1000), Float32(9.459999), Float32(1.945E1), SACFiles.itime, true, Float32(1E-2))
    hdr.IDEP = SACFiles.ivolts
    hdr.DEPMIN = -1.569280
    hdr.DEPMAX = 1.520640
    hdr.DEPMEN = -9.854718E-2
    hdr.O = -41.43 # Equivalent of OMARKER variable
    hdr.A = 10.464 # Equivalent of AMARKER variable
    hdr.IZTYPE = SACFiles.ib
    hdr.KSTNM = rpad("CDV", 8, " ")
    hdr.CMPAZ = 0
    hdr.CMPINC = 0
    hdr.STLA = 4.8E1
    hdr.STLO = -1.2E2
    hdr.KEVNM = rpad("K8108838", 16, " ")
    hdr.EVLA = 4.8E1
    hdr.EVLO = -1.25E2
    hdr.EVDP = 1.5E1
    hdr.IEVTYP = SACFiles.ipostq
    hdr.DIST = 3.730627e+02
    hdr.AZ = 8.814721e+01
    hdr.BAZ = 2.718528e+02
    hdr.GCARC = 3.357465e+00
    hdr.LOVROK = true
    hdr.NVHDR = 6
    hdr.NORID = 0
    hdr.NEVID = 0
    hdr.LPSPOL = true
    hdr.LCALDA = true

    hdr.NZYEAR = 1981
    hdr.NZJDAY = 88
    hdr.NZHOUR = 10
    hdr.NZMIN = 38
    hdr.NZSEC = 14
    hdr.NZMSEC = 0

    return hdr
end

"Test the equality of each field between two `SACDataHeader` instances using
`@test` and `@test_approx_eq` for floating fields."
function testhdrequal(hdra::SACDataHeader, hdrb::SACDataHeader)
    for field in fieldnames(hdra)
        if typeof(hdra.(field)) == Float32
            @test_approx_eq hdra.(field) hdrb.(field)
        else
            @test hdra.(field) == hdrb.(field)
        end
    end
    return nothing
end

end
