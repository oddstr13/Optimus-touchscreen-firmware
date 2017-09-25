#!/usr/bin/env julia
#
# Copyright © 2017 Odd Stråbø <oddstr13@openshell.no>
# License: MIT - https://opensource.org/licenses/MIT
#
# Converts optimus bitmaps from mks_pic/ to PNGs in build/image
#

if Pkg.installed("Images") == nothing
    Pkg.add("Images")
end

using Images

push!(LOAD_PATH, "lib")
using OptimusBitmap

println("Converting images...")

const OUTPUT = joinpath("build", "image")

for (root, dirs, files) in walkdir("mks_pic")
    for fn in files
        if startswith(fn, "bmp_") && endswith(fn, ".bin")
            ifn = joinpath(root, fn)

            outdir = stripdirs(root, 1)

            ofn = joinpath(OUTPUT, outdir, fn[5:end-3] * "png")

            println(ifn, " -> ", ofn)

            mkpath(joinpath(OUTPUT, outdir))

            im = loadbinimg(ifn)

            save(ofn, im)
        end
    end
end