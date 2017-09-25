@echo off
rem Clean build;
rmdir /S /Q build
rmdir /S /Q assets

julia im2bin.jl
julia compress.jl