# Copyright © 2017 Odd Stråbø <oddstr13@openshell.no>
# License: MIT - https://opensource.org/licenses/MIT

module OptimusBitmap

if Pkg.installed("Images") == nothing
    Pkg.add("Images")
end
if Pkg.installed("Colors") == nothing
    Pkg.add("Colors")
end

using Images
using FileIO
using Colors

export savebinimg, loadbinimg, stripdirs, ICON_X, ICON_Y, ICON_BITS, ICON_SIZE

const ICON_X =  78      # Width
const ICON_Y = 104      # Height
const ICON_BITS = 16    # Bits per pixel
const ICON_SIZE = 16224 # File size

import Base.joinpath
function joinpath()
    return ""
end

function stripdirs(path::AbstractString, num::Integer=1)
    return joinpath(split(normpath(path), Base.Filesystem.path_separator_re)[1+num:end]...)
end

function savebinimg(f::IOStream, im::AbstractArray)
    # ?bxxyy??
    y, x = size(im)

    # Only write header if picture is not exactly ICON_X,ICON_Y
    if !(x == ICON_X && y == ICON_Y)
        write(f, 0x00) # Unknown, seems static. Part of header.
        write(f, UInt8(16)) # Bits per pixel? (static)
        write(f, UInt8(x & 0xff))        # x LSB
        write(f, UInt8((x >> 8) & 0xff)) # x MSB
        write(f, UInt8(y & 0xff))        # y LSB
        write(f, UInt8((y >> 8) & 0xff)) # y MSB
        write(f, 0x01) # Unknown, seems static. Part of header.
        write(f, 0x1b) # Unknown, seems static. Part of header.
    end
    
    imf = im' # Flip x/y
    for i in eachindex(imf)
        p = imf[i]
        # 16b LSB MSb RGB 5:6:5

        func = round
        R = UInt16(func(p.r * 31))
        G = UInt16(func(p.g * 63))
        B = UInt16(func(p.b * 31))

        n = R << 11 | G << 5 | B

        write(f, UInt8(n & 0xff)) # LSB
        write(f, UInt8((n >> 8) & 0xff)) # MSB
    end
end

function savebinimg(fn::AbstractString, im::AbstractArray)
    f = open(fn, "w")
    try
        return savebinimg(f, im)
    finally
        close(f)
    end
end

function loadbinimg(f::IOStream)
    data = read(f)
    
    x::UInt64 = ICON_X
    y::UInt64 = ICON_Y
    depth::UInt16 = ICON_BITS

    # Not all images contain the 8-byte headers. These files are exactly 16224 bytes (16216 + 8)
    if length(data) != ICON_SIZE
        # ?bxxyy??
        header = data[1:8]
        data = data[9:end]

        # Bits per pixel
        depth = header[2]
    
        # Image size
        x = UInt64(header[4]) << 8 | header[3]
        y = UInt64(header[6]) << 8 | header[5]
    end

    #println(x, ",", y)
    #println(length(data))
    
    im = zeros(RGB{Float64}, x, y)

    for (i, I) in enumerate(Iterators.partition(data, 2))
        # 16b LSB MSb RGB 5:6:5
        n = UInt16(I[2]) << 8 + I[1]
        
        R = UInt8(n>>11)
        G = UInt8((n >> 5) & 0b111111)
        B = UInt8(n & 0b11111)
        
        im[i] = RGB(R/31, G/63, B/31)
    end

    return im' # Flip x/y
end

function loadbinimg(fn::AbstractString)
    return open(loadbinimg, fn)
end

end