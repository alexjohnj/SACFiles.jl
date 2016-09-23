module SACTestUtilities
using Base.Test
using SACFiles

"Creates an instance of `Header` with the fields manually initialised to
the header variables of './test-files/test-seismo.sac'."
function make_test_seismo_hdr()
    hdr = Header(Int32(1000), Float32(9.459999), Float32(1.945E1), SACFiles.itime, true, Float32(1E-2))
    hdr.idep = SACFiles.ivolts
    hdr.depmin = -1.569280
    hdr.depmax = 1.520640
    hdr.depmen = -9.854718e-2
    hdr.o = -41.43 # equivalent of omarker variable
    hdr.a = 10.464 # equivalent of amarker variable
    hdr.iztype = SACFiles.ib
    hdr.kstnm = "CDV"
    hdr.cmpaz = 0
    hdr.cmpinc = 0
    hdr.stla = 4.8e1
    hdr.stlo = -1.2e2
    hdr.kevnm = "K8108838"
    hdr.evla = 4.8e1
    hdr.evlo = -1.25e2
    hdr.evdp = 1.5e1
    hdr.ievtyp = SACFiles.ipostq
    hdr.dist = 3.730627e+02
    hdr.az = 8.814721e+01
    hdr.baz = 2.718528e+02
    hdr.gcarc = 3.357465e+00
    hdr.lovrok = true
    hdr.nvhdr = 6
    hdr.norid = 0
    hdr.nevid = 0
    hdr.lpspol = true
    hdr.lcalda = true

    hdr.nzyear = 1981
    hdr.nzjday = 88
    hdr.nzhour = 10
    hdr.nzmin = 38
    hdr.nzsec = 14
    hdr.nzmsec = 0

    return hdr
end

"Test the equality of each field between two `Header` instances using
`@test` and `@test_approx_eq` for floating fields."
function testhdrequal(hdra::Header, hdrb::Header)
    map(fieldnames(Header), Header.types) do field, T
        if T == Float32
            @test_approx_eq getfield(hdra, field) getfield(hdrb, field)
        else
            @test getfield(hdra, field) == getfield(hdrb, field)
        end
    end
    return nothing
end

end
