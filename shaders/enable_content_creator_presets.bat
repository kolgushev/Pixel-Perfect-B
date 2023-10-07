@echo off
setlocal

:: Define the file path
set "FILE_PATH=shaders.properties"

:: Create a temporary file
set "TEMP_FILE=%TEMP%\tempfile.txt"

:: Use sed to process the file
sed -r "/^# profile\.CONTENT_(ONE|TWO|THREE) = /s/^# //" "%FILE_PATH%" > "%TEMP_FILE%"

:: Move the temporary file to replace the original file
move /Y "%TEMP_FILE%" "%FILE_PATH%"

:end
