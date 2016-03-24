const SAC_WORD_SIZE = 4

"""
    decodesacbytes(T::Type, bs::Vector{UInt8}, needswap=false)

Decode the bytes `bs` into the type `T` swapping the byte order if
`needswap=true`. Returns an array of decoded values in the order they were
decoded.

    decodesacbytes(T::Type{ASCIIString}, bs::Vector{UInt8}, wordsize=8)

Decode the bytes `bs` into `ASCIIStrings` with each string being `wordsize`
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
function decodesacbytes(T::Type{ASCIIString}, bs::Vector{UInt8}, wordsize::Integer=8)
    @assert(length(bs) % wordsize == 0,
            "Length of byte array is not a multiple of $wordsize")
    return [ascii(bs[(2 * SAC_WORD_SIZE * n) + 1 : div(wordsize, 4) * SAC_WORD_SIZE * (n+1)])
            for n in 0:1:div(length(bs), wordsize)-1]
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
