const SAC_WORD_SIZE = 4

"""
    decodesacbytes(T::Type, bs::Vector{UInt8}, needswap=false)

Decode the bytes `bs` into the type `T` swapping the byte order if
`needswap=true`. Returns an array of decoded values in the order they were
decoded.

    decodesacbytes(T::Type{ASCIIString}, bs::Vector{UInt8}, stringsize=8)

Decode the bytes `bs` into `ASCIIStrings` with each string being `stringsize`
bytes long. Returns an array of strings in the order they were decoded.
"""
decodesacbytes(T::Type{HeaderEnum}, bs::Vector{UInt8}, needswap=false) =
    reinterpret(HeaderEnum, decodesacbytes(Int32, bs, needswap))
decodesacbytes(T::Type{Bool}, bs::Vector{UInt8}, needswap=false) =
    map(Bool, decodesacbytes(Int32, bs, needswap) & 1)
decodesacbytes(T::Type{Bool}, bs::Vector{UInt8}, needswap=false) =
    decodesacbytes(Int32, bs, needswap) .!= 0 # SAC treats anything that isn't 0 as true
function decodesacbytes(T::Type, bs::Vector{UInt8}, needswap=false)
    @assert(length(bs) % 4 == 0, "Length of byte array is not a multiple of 4")
    decdata = reinterpret(T, bs)
    return needswap ? map(bswap, decdata) : decdata
end
function decodesacbytes(T::Type{ASCIIString}, bs::Vector{UInt8}, stringsize::Integer=8)
    @assert(length(bs) % stringsize == 0,
            "Length of byte array is not a multiple of $stringsize")
    nstr = div(length(bs), stringsize)
    return [ascii(bs[(stringsize * n) + 1 : (stringsize * n) + stringsize])
            for n in 0:1:nstr-1]
end

"Determine if a SAC file is in non-native endianness by checking the header
version number is between 1 and `SAC_HDR_VERSION`. Returns `true` if the file is
alien."
function isalienend(f::IOStream)
    p = position(f)
    seek(f, 76 * SAC_WORD_SIZE)
    nvhdr = reinterpret(Int32, readbytes(f, 4))[1]
    seek(f,p)

    return !(1 <= nvhdr <= SAC_HDR_VERSION)
end

"""
    parsetext(T::Type, text::ASCIIString, colwidth::Integer)

Parse values of type `T` from `text` where each value is `colwidth` columns wide
in the text. Returns an array of `T`s. Newline characters are stripped from
`text` before parsing.

Raises an error if the length of `text` is not a multiple of `colwidth` after
stripping newlines.
"""
parsetext(T::Type{Int32}, text::ASCIIString) = parsetext(T, text, 10)
parsetext(T::Type{Float32}, text::ASCIIString) = parsetext(T, text, 15)
parsetext(T::Type{HeaderEnum}, text::ASCIIString) = reinterpret(HeaderEnum, parsetext(Int32, text))
parsetext(T::Type{Bool}, text::ASCIIString) = parsetext(Int32, text) .!= 0
parsetext(T::Type{ASCIIString}, text::ASCIIString) = parsetext(T, text, 8)
function parsetext(T::Type, text::ASCIIString, colwidth::Integer)
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
