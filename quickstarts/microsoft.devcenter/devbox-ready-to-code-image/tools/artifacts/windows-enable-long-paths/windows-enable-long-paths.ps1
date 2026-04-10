$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem -Name LongPathsEnabled -Value 1 -Type DWord -Force