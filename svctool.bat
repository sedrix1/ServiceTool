@echo off

setlocal enabledelayedexpansion

net session >nul 2>&1

if %errorlevel% neq 0 (
    echo ===========================================================
    echo       This script requires Administrator privileges
    echo       Press any key to launch as Administrator...
    echo ===========================================================
    pause
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

for /f %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"

reg add HKCU\Console /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul 2>&1

set services=pcasvc DiagTrack SysMain SgrmBroker CDPUserSvc WSearch

chcp 65001 > nul

mode con: cols=120 lines=35

goto menu

:banner
cls
echo.
echo.
echo           %ESC%[38;2;255;0;0m███████╗███████╗██████╗ ██╗   ██╗██╗ ██████╗███████╗    ████████╗ ██████╗  ██████╗ ██╗     
echo           %ESC%[38;2;255;51;0m██╔════╝██╔════╝██╔══██╗██║   ██║██║██╔════╝██╔════╝    ╚══██╔══╝██╔═══██╗██╔═══██╗██║     
echo           %ESC%[38;2;255;102;0m███████╗█████╗  ██████╔╝██║   ██║██║██║     █████╗         ██║   ██║   ██║██║   ██║██║     
echo           %ESC%[38;2;255;153;0m╚════██║██╔══╝  ██╔══██╗╚██╗ ██╔╝██║██║     ██╔══╝         ██║   ██║   ██║██║   ██║██║     
echo           %ESC%[38;2;255;204;0m███████║███████╗██║  ██║ ╚████╔╝ ██║╚██████╗███████╗       ██║   ╚██████╔╝╚██████╔╝███████╗
echo           %ESC%[38;2;255;255;0m╚══════╝╚══════╝╚═╝  ╚═╝  ╚═══╝  ╚═╝ ╚═════╝╚══════╝       ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝
echo           %ESC%[0m
echo.
echo.
goto :eof

:menu
call :banner
echo.
echo            [1] Enable Services
echo            [2] Disable Services
echo            [3] View Services
echo            [4] Exit
echo.
echo.
echo.
set /p input="            [>] Select an option: "
echo. 

if "%input%"=="1" goto attiva
if "%input%"=="2" goto disattiva
if "%input%"=="3" goto visualizza
if "%input%"=="4" goto esci

echo Scelta non valida
pause
goto menu

:visualizza
call :banner
echo.
echo %ESC%[97m[STATO SERVIZI]%ESC%[0m
powershell -Command "get-service | findstr -i "pcasvc"; get-service | findstr -i "DPS"; get-service | findstr -i "Dialogtrack"; get-service | findstr -i "sysmain"; get-service | findstr -i "eventlog"; get-service | findstr -i "sgrmbroker"; get-service | findstr -i "cdpusersvc"; get-service | findstr -i "appinfo"; get-service | findstr -i "WSearch" | findstr -i "VSS"; get-service | findstr -i "vss""
echo.
echo.
echo.
pause
goto menu

:attiva
call :banner
echo.
echo %ESC%[92m[ENABLING SERVICES]%ESC%[0m
for %%s in (%services%) do (
    echo Starting process %%s...
    sc config %%s start = auto >nul 2>&1
    powershell -Command "Start-Service %%s -ErrorAction SilentlyContinue"
    if !errorlevel! equ 0 (
        echo %ESC%[92m[OK]%ESC%[0m Successfully enabled process %%s
    ) else (
        echo %ESC%[91m[ERROR]%ESC%[0m Failed to enable process %%s
    )
)
echo.
echo.
echo.
pause
goto menu

:disattiva
call :banner
echo.
echo %ESC%[91m[DISABLING SERVICES]%ESC%[0m
for %%s in (%services%) do (
    echo Stopping process %%s...
    sc config %%s start = disabled >nul 2>&1
    powershell -Command "Stop-Service %%s -ErrorAction SilentlyContinue"
    if !errorlevel! equ 0 (
        echo %ESC%[92m[OK]%ESC%[0m Successfully disabled process %%s
    ) else (
        echo %ESC%[91m[ERROR]%ESC%[0m Failed to disable process %%s
    )
)
echo.
echo.
echo.
pause
goto menu

:esci
echo Exiting...
exit