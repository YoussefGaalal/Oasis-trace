@echo off
chcp 65001 >nul
title Oasis Trace - Test Runner

echo.
echo ╔════════════════════════════════════════════╗
echo ║      OASIS TRACE - AUTOMATED TEST SUITE    ║
echo ║      Life Stock Tracking Application       ║
echo ╚════════════════════════════════════════════╝
echo.

cd /d "%~dp0"

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python not found!
    echo Please install Python 3.7+ and try again.
    pause
    exit /b 1
)

REM Check if requests library is installed
python -c "import requests" >nul 2>&1
if errorlevel 1 (
    echo Installing required packages...
    pip install requests colorama
    if errorlevel 1 (
        echo ERROR: Failed to install packages!
        pause
        exit /b 1
    )
)

REM Check if API server is running
echo Checking API server...
curl -s -o nul -w "%%{http_code}" http://localhost:8050/api/animals >temp_check.txt
set /p SERVER_STATUS=<temp_check.txt
del temp_check.txt

if not "%SERVER_STATUS%"=="200" (
    echo.
    echo ╔═══════════════════════════════════════════════════════════╗
    echo ║            ERROR: API SERVER NOT RUNNING!                 ║
    echo ╠═══════════════════════════════════════════════════════════╣
    echo ║                                                           ║
    echo ║  Start the server with these commands:                    ║
    echo ║                                                           ║
    echo ║  1. cd C:\Users\Rami-PC\Downloads\oasis-trace\oasis-trace ║
    echo ║  2. php artisan serve --port=8050                         ║
    echo ║                                                           ║
    echo ╚═══════════════════════════════════════════════════════════╝
    echo.
    pause
    exit /b 1
)

echo ✓ API server is running! (Status: %SERVER_STATUS%)
echo.
echo Running tests...
echo.

python run_tests.py

echo.
echo Test complete! Check the log files for results.
echo.

REM Open log file in default text editor
for /f "tokens=*" %%f in ('dir /b /o-d test_log_*.txt 2^>nul') do (
    echo Latest log: %%f
    echo.
    type %%f
    goto :done
)

:done
echo.
pause
