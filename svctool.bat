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

set services=pcasvc DiagTrack DPS SysMain SgrmBroker CDPUserSvc WSearch TabletInputService wisvc RemoteRegistry Fax MapsBroker dmwappushservice WerSvc RetailDemo WpcNetworkSvc TermService lfsvc XboxNetApiSvc XblAuthManager XblGameSave XboxGipSvc 

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
echo.
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

if "%input%"=="1" goto enable
if "%input%"=="2" goto disable
if "%input%"=="3" goto view
if "%input%"=="4" goto fexit

echo Scelta non valida
pause
goto menu

:view
echo.
call :banner
echo.
echo %ESC%[97m[SERVICES STATUS]%ESC%[0m
set "SERVICEVIEWLIST=Appinfo,CDPUserSvc*,DiagTrack,dmwappushservice,DPS,EventLog,Fax,lfsvc,MapsBroker,PcaSvc,RemoteRegistry,RetailDemo,SgrmBroker,SysMain,TabletInputService,TermService,VSS,WerSvc,wisvc,WpcNetworkSvc,WSearch,XblAuthManager,XblGameSave,XboxGipSvc,XboxNetApiSvc"
powershell -NoProfile -ExecutionPolicy Bypass "$arr=$env:SERVICEVIEWLIST -split ','; $list=Get-Service -Name $arr -ErrorAction SilentlyContinue | Sort-Object Name; foreach($s in $list){ $wmi=Get-CimInstance Win32_Service -Filter \"Name='$($s.Name)'\"; $startType=$wmi.StartMode; if($s.Status -eq 'Stopped' -or $startType -eq 'Disabled'){ Write-Host '[DISABLED] ' -NoNewline -ForegroundColor Red; Write-Host ($s.Name.PadRight(22) + ' - State: ' + $s.Status + ' - Type: ' + $startType) } else { Write-Host '[ENABLED]  ' -NoNewline -ForegroundColor Green; Write-Host ($s.Name.PadRight(22) + ' - State: ' + $s.Status + ' - Type: ' + $startType) } }"
echo.
echo.
echo.
pause
goto menu

:enable
echo.
call :banner
echo.
echo %ESC%[92m[ENABLING SERVICES]%ESC%[0m
for %%s in (%services%) do (
    echo Starting process %%s...
    sc config %%s start= auto >nul 2>&1
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

:disable
echo.
call :banner
echo.
echo %ESC%[91m[DISABLING SERVICES]%ESC%[0m
for %%s in (%services%) do (
    echo Stopping process %%s...
    sc config %%s start= disabled >nul 2>&1
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

:fexit
echo Exiting...
exit