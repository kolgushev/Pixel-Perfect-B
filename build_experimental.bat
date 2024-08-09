@echo off
setlocal enabledelayedexpansion

REM Set the original folder path
set "original_folder=%~dp0"

REM Call build.bat with /e flag and pass along all other arguments
call "%original_folder%build.bat" /e %*

echo Experimental build completed.
