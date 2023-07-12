@echo off
setlocal

REM Set the original folder path
set "original_folder=%~dp0"

REM Escape backslashes in path
@REM set "original_folder=%original_folder:\=\\%"

REM Set the build directory path
set "build_directory=%original_folder%..\build\"

REM Set the unzipped directory
set "unzipped_directory=%build_directory%unzipped\"

REM Create the build directory if it doesn't exist
if not exist "%build_directory%" (
    mkdir "%build_directory%"
)

REM Copy the contents of the original folder to the build directory
xcopy "%original_folder%" "%unzipped_directory%" /s /e /i /y /q /exclude:%original_folder%exclude_from_build.txt

echo Copied original folder to build directory

REM Create a timestamp for the zip file
set "timestamp=%date:/=-%_%time::=-%"
set "timestamp=%timestamp: =0%"
set "timestamp=%timestamp:.=_%"

REM Set the zip file
set "zip_file=%build_directory%Pixel-Perfect-%timestamp%.zip"

REM Create the zip file
powershell -nologo -noprofile -command "Add-Type -A 'System.IO.Compression.FileSystem'; [System.IO.Compression.ZipFile]::CreateFromDirectory('%unzipped_directory%', '%zip_file%')"

echo Created zip file

REM Replace the latest build file with current build
copy "%zip_file%" "%original_folder%..\Pixel-Perfect-Latest.zip" /b /y

echo Replaced latest build

REM Delete the unzipped directory
rmdir "%unzipped_directory%" /s /q
echo Deleted "%unzipped_directory%"

if not "%~1"=="/k" (
	REM Delete the original zip file
	del "%zip_file%"
	echo Deleted "%zip_file%"
	echo You can use /k if you want to keep the zip file in the build folder after the program is done
) else (
	echo Kept "%zip_file%"
)

echo Build completed.
pause