#!/usr/bin/env julia
#
# Copyright © 2017 Odd Stråbø <oddstr13@openshell.no>
# License: MIT - https://opensource.org/licenses/MIT
#
# Reads binary images from mks_pic/ and writes them to out/
#

if Pkg.installed("Images") == nothing
    Pkg.add("Images")
end

using Images

push!(LOAD_PATH, "lib")
using OptimusBitmap

println("Converting images...")

const OUTPUT = joinpath("build", "bitmap")

for (root, dirs, files) in walkdir("imgsrc")
    for fn in files
        if endswith(fn, ".png")
            ifn = joinpath(root, fn)

            outdir = stripdirs(root, 1)
            
            ofn = joinpath(OUTPUT, outdir, "bmp_" * fn[1:end-3] * "bin")

            println(ifn, " -> ", ofn)
            
            mkpath(joinpath(OUTPUT, outdir))

            im = load(ifn)
            
            savebinimg(ofn, im)
        end
    end
end