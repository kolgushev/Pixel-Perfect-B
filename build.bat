@echo off
setlocal enabledelayedexpansion

REM Set the original folder path
set "original_folder=%~dp0"

REM Set the build directory path
set "build_directory=%original_folder%..\build\"

REM Create the build directory if it doesn't exist
if not exist "%build_directory%" (
    mkdir "%build_directory%"
)

REM Create a timestamp for the zip file
set "timestamp=%date:/=-%_%time::=-%"
set "timestamp=%timestamp: =0%"
set "timestamp=%timestamp:.=_%"
set "suffix=-Latest"

REM Set the zip file
set "zip_file=%build_directory%Pixel-Perfect!suffix!-%timestamp%.zip"

REM Create the zip file
tar.exe -a -c -f !zip_file! -X exclude_from_build.txt LICENSE shaders

echo Created !zip_file!

REM Replace the latest build file with current build
copy "!zip_file!" "%original_folder%..\Pixel-Perfect-Latest!suffix!.zip" /b /y

echo Replaced latest build

if not "%~1"=="/k" (
	REM Delete the original zip file
	del "!zip_file!"
	echo Deleted "!zip_file!"
) else (
	echo Kept "!zip_file!"
)

if not "%~1"=="/k" (
	echo You can use /k if you want to keep the zip file in the build folder after the program is done.
)

echo Build completed.