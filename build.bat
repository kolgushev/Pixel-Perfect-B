@echo off
setlocal enabledelayedexpansion

REM Set the original folder path
set "original_folder=%~dp0"

REM Set the build directory path
set "build_directory=%original_folder%..\build\"

REM Create the build directory if it doesn't exist
if not exist "%build_directory%" mkdir "%build_directory%"

REM Parse command-line arguments
set "keep_zip=0"
set "beta_build=0"
for %%i in (%*) do (
    if /i "%%i"=="/k" set "keep_zip=1"
    if /i "%%i"=="/e" set "beta_build=1"
)

REM Create a timestamp for the zip file
set "timestamp=%date:/=-%_%time::=-%"
set "timestamp=%timestamp: =0%"
set "timestamp=%timestamp:.=_%"
if %beta_build%==1 (
    set "suffix=-Latest-Beta-1"
) else (
    set "suffix=-Latest"
)

REM Set the zip file
set "zip_file=%build_directory%Pixel-Perfect!suffix!-%timestamp%.zip"

REM Create the zip file
tar.exe -a -c -f !zip_file! -X exclude_from_build.txt LICENSE shaders

echo Created !zip_file!

REM Set current build location
set "current_build_location=%original_folder%..\Pixel-Perfect!suffix!.zip"

REM Replace the latest build file with current build
copy "!zip_file!" "!current_build_location!" /b /y

echo Wrote latest build to !current_build_location!

if %keep_zip%==0 (
    REM Delete the original zip file
    del "!zip_file!"
    echo Deleted "!zip_file!"
) else (
    echo Kept "!zip_file!"
)

if %keep_zip%==0 (
    echo You can use /k if you want to keep the zip file in the build folder after the program is done.
)

echo Build completed. Press any key to close.

REM Prevent the window from closing on completion
pause >nul