REM Runs under SYSTEM account
ECHO Dev Box Image Templates SetupComplete2.cmd BEGIN >> %WinDir%\Panther\WaSetup.log

IF EXIST "%SystemRoot%\OEM\SetupComplete2FromOrigBaseImage.cmd" (
    ECHO SetupComplete2FromOrigBaseImage.cmd BEGIN >> %WinDir%\Panther\WaSetup.log
    CALL "%SystemRoot%\OEM\SetupComplete2FromOrigBaseImage.cmd"
    ECHO SetupComplete2FromOrigBaseImage.cmd END >> %WinDir%\Panther\WaSetup.log
)

ECHO Configure User Tasks BEGIN >> %WinDir%\Panther\WaSetup.log
(PowerShell.exe -ExecutionPolicy Bypass -NoProfile "& 'C:\.tools\Setup\Scripts\setup-user-tasks.ps1'") 1>>C:\.tools\Setup\Logs\setup-user-tasks.log 2>&1
ECHO Configure User Tasks END >> %WinDir%\Panther\WaSetup.log

ECHO Dev Box Image Templates SetupComplete2.cmd END >> %WinDir%\Panther\WaSetup.log
