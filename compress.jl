#!/usr/bin/env julia
#
# Copyright © 2017 Odd Stråbø <oddstr13@openshell.no>
# License: MIT - https://opensource.org/licenses/MIT
#
# Builds release zip
#

if Pkg.installed("ZipFile") == nothing
    Pkg.add("ZipFile")
end

using ZipFile

push!(LOAD_PATH, "lib")
using OptimusBitmap

const BITMAPS = joinpath("build", "bitmap")

mkpath("assets")

const ZIPFN = joinpath("assets", "release.zip")
z = ZipFile.Writer(ZIPFN)

for (root, dirs, files) in walkdir(BITMAPS)
    for fn in files
        fp = joinpath(root, fn)

        zippath = joinpath("mks_pic", stripdirs(fp, 2))
        println(fp, " -> ", ZIPFN, ":", zippath)

        fh = ZipFile.addfile(z, zippath)
        infile = open(fp, "r")

        write(fh, read(infile))

        close(infile)
        close(fh)
    end
end

for (root, dirs, files) in walkdir("blobs")
    for fn in files
        fp = joinpath(root, fn)

        zippath = stripdirs(fp, 1)
        println(fp, " -> ", ZIPFN, ":", zippath)

        fh = ZipFile.addfile(z, zippath)
        infile = open(fp, "r")

        write(fh, read(infile))

        close(infile)
        close(fh)
    end
end

