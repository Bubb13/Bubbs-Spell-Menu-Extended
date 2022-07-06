
@echo off
rem | This script converts all .png in the script's directory into paletted variants and saves them to /out

pushd "%~dp0"
if exist out rmdir /s /q out
mkdir out
cd out
mkdir tmp

for %%f in (../*.png) do (
	echo %%~nxf
	ffmpeg -loglevel warning -i "../%%~nxf" -vf palettegen tmp/palette.png -y
	ffmpeg -loglevel warning -i "../%%~nxf" -i tmp/palette.png -lavfi paletteuse "%%~nxf" -y
)

rmdir /s /q tmp
popd
