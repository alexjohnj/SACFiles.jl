module TestHeaders
using Base.Test
using SACFiles

# Test enums are defined correctly.
ids = vcat(-12345, 1:50, 52:97, 103)
enums = instances(SACHeaderEnum) # This feels dirty. Is instances guaranteed to return the Enums in order?
map(ids, enums) do id, enum
    @test SACHeaderEnum(id) == enum
end

# Test header reading on a hexed file.
open("./test-files/test-hexed-header.sac", "r") do f
    inhdr = readsachdr(f)
    hdr_hexedvalues = Dict{Type, Any}(Float32       => Float32(1337.0),
                                      Int32         => Int32(1337),
                                      SACHeaderEnum => SACFiles.inucl,
                                      ASCIIString   => ascii("BLEEPBLO"),
                                      Bool          => true)
    testhdr = SACDataHeader()

    for val in SACFiles.sacheader_variables
        if val == :UNUSED || val == :INTERNAL
            continue
        end

        if val == :KEVNM
            testhdr.(val) = ascii("BLEEPBLOOPBLEEPS")
        else
            testhdr.(val) = hdr_hexedvalues[typeof(testhdr.(val))]
        end
        @test inhdr.(val) == testhdr.(val)
    end
end

# Test header reading on a synthetic seismogram
open("./test-files/test-seismo.sac", "r") do f
    inhdr = readsachdr(f)
    testhdr = SACDataHeader(Int32(1000), Float32(9.459999), Float32(1.945E1), SACFiles.itime, true, Float32(1E-2))
    testhdr.IDEP = SACFiles.ivolts
    testhdr.DEPMIN = -1.569280
    testhdr.DEPMAX = 1.520640
    testhdr.DEPMEN = -9.854718E-2
    testhdr.O = -41.43 # Equivalent of OMARKER variable
    testhdr.A = 10.464 # Equivalent of AMARKER variable
    testhdr.IZTYPE = SACFiles.ib
    testhdr.KSTNM = rpad("CDV", 8, " ")
    testhdr.CMPAZ = 0
    testhdr.CMPINC = 0
    testhdr.STLA = 4.8E1
    testhdr.STLO = -1.2E2
    testhdr.KEVNM = rpad("K8108838", 16, " ")
    testhdr.EVLA = 4.8E1
    testhdr.EVLO = -1.25E2
    testhdr.EVDP = 1.5E1
    testhdr.IEVTYP = SACFiles.ipostq
    testhdr.DIST = 3.730627e+02
    testhdr.AZ = 8.814721e+01
    testhdr.BAZ = 2.718528e+02
    testhdr.GCARC = 3.357465e+00
    testhdr.LOVROK = true
    testhdr.NVHDR = 6
    testhdr.NORID = 0
    testhdr.NEVID = 0
    testhdr.LPSPOL = true
    testhdr.LCALDA = true

    testhdr.NZYEAR = 1981
    testhdr.NZJDAY = 88
    testhdr.NZHOUR = 10
    testhdr.NZMIN = 38
    testhdr.NZSEC = 14
    testhdr.NZMSEC = 0


    for val in SACFiles.sacheader_variables
        if val == :UNUSED || val == :INTERNAL
            continue
        end

        if typeof(testhdr.(val)) == Float32
            @test_approx_eq inhdr.(val) testhdr.(val)
        else
            @test inhdr.(val) == testhdr.(val)
        end
    end
end

end
