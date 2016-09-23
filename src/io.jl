const SAC_WORD_SIZE = 4

"""
    decodesacbytes(T::Type, bs::Vector{UInt8}, needswap=false)

Decode the bytes `bs` into the type `T` swapping the byte order if
`needswap=true`. Returns an array of decoded values in the order they were
decoded.

    decodesacbytes(T::Type{String}, bs::Vector{UInt8}, stringsize=8)

Decode the bytes `bs` into `Strings` with each string being `stringsize`
bytes long. Returns an array of strings in the order they were decoded.
"""
decodesacbytes(T::Type{HeaderEnum}, bs::Vector{UInt8}, needswap=false) =
    reinterpret(HeaderEnum, decodesacbytes(Int32, bs, needswap))
decodesacbytes(T::Type{Bool}, bs::Vector{UInt8}, needswap=false) =
    decodesacbytes(Int32, bs, needswap) .!= 0 # SAC treats anything that isn't 0 as true
function decodesacbytes(T::Type, bs::Vector{UInt8}, needswap=false)
    @assert(length(bs) % 4 == 0, "Length of byte array is not a multiple of 4")
    decdata = reinterpret(T, bs)
    return needswap ? map(bswap, decdata) : decdata
end
function decodesacbytes(T::Type{String}, bs::Vector{UInt8}, stringsize::Integer=8)
    @assert(length(bs) % stringsize == 0,
            "Length of byte array is not a multiple of $stringsize")
    nstr = div(length(bs), stringsize)
    return [ascii(String(bs[(stringsize * n) + 1 : (stringsize * n) + stringsize]))
            for n in 0:1:nstr-1]
end

"Determine if a SAC file is in non-native endianness by checking the header
version number is between 1 and `SAC_HDR_VERSION`. Returns `true` if the file is
alien."
function isalienend(f::IOStream)
    p = position(f)
    seek(f, 76 * SAC_WORD_SIZE)
    nvhdr = reinterpret(Int32, read(f, 4))[1]
    seek(f,p)

    return !(1 <= nvhdr <= SAC_HDR_VERSION)
end

"""
    parsetext(T::Type, text::String, colwidth::Integer)

Parse values of type `T` from `text` where each value is `colwidth` columns wide
in the text. Returns an array of `T`s. Newline characters are stripped from
`text` before parsing.

Raises an error if the length of `text` is not a multiple of `colwidth` after
stripping newlines.
"""
parsetext(T::Type{Int32}, text::String) = parsetext(T, text, 10)
parsetext(T::Type{Float32}, text::String) = parsetext(T, text, 15)
parsetext(T::Type{HeaderEnum}, text::String) = reinterpret(HeaderEnum, parsetext(Int32, text))
parsetext(T::Type{Bool}, text::String) = parsetext(Int32, text) .!= 0
parsetext(T::Type{String}, text::String) = parsetext(T, text, 8)
function parsetext(T::Type, text::String, colwidth::Integer)
    cleantext = replace(text, '\n', "")
    @assert(length(cleantext) % colwidth == 0,
            "Text is not a multiple of $colwidth characters wide after stripping newline characters.")
    readvals = Array(T, div(length(cleantext), colwidth))

    for i in eachindex(readvals)
        field = cleantext[(i-1) * colwidth + 1 : (i-1) * colwidth + colwidth]
        readvals[i] = T <: Number ? parse(T, field) : strip(field)
    end

    return readvals
end

################################################################################
#                                  HEADER IO
################################################################################

"""
    readsachdr(fname::AbstractString; ascii=false)
    readsachdr(f::IOStream; ascii=false)

Read the header data (first 158 words/632 bytes) from the file named `fname` or
the stream `f`. Returns a `Header` instance constructed from the data.

Pass `ascii=true` to read the header of a SAC alpha file.
"""
readsachdr(fname::AbstractString; kwargs...) = open((f) -> readsachdr(f; kwargs...), fname)
function readsachdr(f::IOStream; ascii=false)
    ascii ? _readsachdr_ascii(f) : _readsachdr_binary(f)
end

function _readsachdr_ascii(f)
    seekstart(f)
    fhdrcontents = ascii(String(read(f, SAC_HDR_ASCII_END)))
    # For the alphanumeric section of the header, we have to offset from the
    # start of this section to account for the different length of the kevnm
    # field.
    hdrarr = [parsetext(Float32, fhdrcontents[SAC_HDR_ASCII_FLOAT_START:SAC_HDR_ASCII_INT_START-1]);
              parsetext(Int32, fhdrcontents[SAC_HDR_ASCII_INT_START:SAC_HDR_ASCII_ENUM_START-1]);
              parsetext(HeaderEnum, fhdrcontents[SAC_HDR_ASCII_ENUM_START:SAC_HDR_ASCII_BOOL_START-1]);
              parsetext(Bool, fhdrcontents[SAC_HDR_ASCII_BOOL_START:SAC_HDR_ASCII_ALPHA_START-1]);
              parsetext(String, fhdrcontents[SAC_HDR_ASCII_ALPHA_START:SAC_HDR_ASCII_ALPHA_START+7]);
              parsetext(String, fhdrcontents[SAC_HDR_ASCII_ALPHA_START+8:SAC_HDR_ASCII_ALPHA_START+23], 16);
              parsetext(String, fhdrcontents[SAC_HDR_ASCII_ALPHA_START+25:SAC_HDR_ASCII_END])]

    hdr = Header()
    for (val, field) in zip(hdrarr, fieldnames(Header))
        setfield!(hdr, field, val)
    end

    return hdr
end

function _readsachdr_binary(f::IOStream)
    seekstart(f)
    needswap = isalienend(f)
    bs = read(f, SAC_WORD_SIZE * SAC_HDR_NWORDS)
    hdr = Header()

    hdrvals = vcat(decodesacbytes(Float32, bs[1:SAC_WORD_SIZE * 70], needswap),
                   decodesacbytes(Int32, bs[(SAC_WORD_SIZE * 70) + 1 : SAC_WORD_SIZE * 85], needswap),
                   decodesacbytes(HeaderEnum, bs[(SAC_WORD_SIZE * 85) + 1 : SAC_WORD_SIZE * 105], needswap),
                   decodesacbytes(Bool, bs[(SAC_WORD_SIZE * 105) + 1 : SAC_WORD_SIZE * 110], needswap),
                   decodesacbytes(String, bs[(SAC_WORD_SIZE * 110) + 1 : SAC_WORD_SIZE * 112]),
                   decodesacbytes(String, bs[(SAC_WORD_SIZE * 112) + 1 : SAC_WORD_SIZE * 116], 16),
                   decodesacbytes(String, bs[(SAC_WORD_SIZE * 116) + 1 : SAC_WORD_SIZE * 158]))

    for (field, val) in zip(fieldnames(hdr), hdrvals)
        setfield!(hdr, field, val)
    end

    cleanhdr!(hdr)
    return hdr
end

################################################################################
#                                   DATA IO
################################################################################

"""
    readsac(fname::AbstractString; ascii=false)
    readsac(f::IOStream; ascii=false)

Read the SAC file at path `fname` or from the stream `f`. The return type is
determined using the file type declared in the file's header. *Note* this isn't
type stable.

    readsac{S<:AbstractSACData}(T::Type{S}, f::IOStream; ascii=false)

Read the SAC file of type `T` from the stream `f`. Raises an error if the type
`T` does not match the file type declared in the file's header. The returned
type is always of type `T`.

Pass `ascii=true` to read a SAC alpha file. *Note* this uses *significantly*
more memory than reading a binary SAC file.
"""
readsac(fname::AbstractString; kwargs...) = open((f) -> readsac(f; kwargs...), fname)
function readsac(f::IOStream; kwargs...)
    hdr = readsachdr(f; kwargs...)

    if hdr.iftype == itime && hdr.leven
        readsac(EvenTimeSeries, f, hdr; kwargs...)
    elseif hdr.iftype == itime && !hdr.leven
        readsac(UnevenTimeSeries, f, hdr; kwargs...)
    elseif hdr.iftype == irlim
        readsac(ComplexSpectrum, f, hdr; kwargs...)
    elseif hdr.iftype == iamph
        readsac(AmplitudeSpectrum, f, hdr; kwargs...)
    elseif hdr.iftype == ixy
        readsac(GeneralXY, f, hdr; kwargs...)
    end
end

readsac{S<:AbstractSACData}(T::Type{S}, f::IOStream; kwargs...) = readsac(T, f, readsachdr(f; kwargs...); kwargs...)
function readsac{S<:AbstractSACData}(T::Type{S}, f::IOStream, hdr::Header; kwargs...)
    if hdr.iftype != FILE_TYPE_ENUMS[T]
        error("File's header indicates it is not a $(T)")
    end
    if T == EvenTimeSeries
        T(hdr, readsac_data(f, hdr.npts; kwargs...)[1])
    elseif T == ComplexSpectrum
        T(hdr, complex(readsac_data(f, hdr.npts; kwargs...)...))
    else
        T(hdr, readsac_data(f, hdr.npts; kwargs...)...)
    end
end

"""
    readsac_data(f::IOStream, npts::Int32; ascii=false)

Read `npts` of the data section from the stream `f`. Will automatically swap the
byte order of the data if it isn't the host's byte order. Returns a 2-tuple
containing the first data section and, if present, the second data section.
"""
function readsac_data(f::IOStream, npts::Int32; ascii=false)
    ascii ? _readsac_data_ascii(f, npts) : _readsac_data_binary(f, npts)
end

function _readsac_data_binary(f::IOStream, npts::Int32)
    needswap = isalienend(f)
    seek(f, DATA_START)

    data1 = decodesacbytes(Float32, read(f, SAC_WORD_SIZE * npts), needswap)
    if eof(f)
        return (data1, Float32[])
    end

    data2 = decodesacbytes(Float32, read(f, SAC_WORD_SIZE * npts), needswap)
    return (data1, data2)
end

function _readsac_data_ascii(f::IOStream, npts::Int32)
    seek(f, ASCII_DATA_START)

    data = readstring(f)
    data = parsetext(Float32, data)

    if length(data) == 2 * npts
        return (data[1:npts], data[npts+1:end])
    elseif length(data) == npts
        return (data, Float32[])
    else
        error("Number of data points in file ($(length(data)) does not match
       the"*"number of points declared in the header ($(hdr.npts)).")
    end
end
