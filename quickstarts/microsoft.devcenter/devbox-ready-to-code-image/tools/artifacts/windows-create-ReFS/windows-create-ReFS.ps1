<#
.SYNOPSIS
    Create ReFS or Dev Drive "x" drive volume. 
.DESCRIPTION
    Create ReFS or Dev Drive "x" drive volume. If "x" volume already exists then delete it before creating "x".
.PARAMETER DevBoxRefsDrive (optional)
    Drive letter. Defaults to 'Q' to avoid the low drive letters that may already be taken by an Azure VM.
.PARAMETER OsDriveMinSizeGB (optional)
    The required minimum size of NTFS C drive in GB when ReFS or Dev Drive volume is created.
.PARAMETER IsDevDrive (optional)
    Whether the ReFS drive is to be formatted as a Dev Drive. Requires a compatible Win11 22H2+ October 2023 or later base image.

.EXAMPLE
    Sample Bicep snippet for using the artifact:

    {
      name: 'windows-create-ReFS'
      parameters: {
        DevBoxRefsDrive: 'Q'
        OsDriveMinSizeGB: 80
        IsDevDrive: true
      }
    }
#>

param
(
    [string] $DevBoxRefsDrive = "Q",
    [int] $OsDriveMinSizeGB = 160,
    [bool] $IsDevDrive = $false
)

Set-StrictMode -Version latest
$ErrorActionPreference = "Stop"

Write-Host "`nSTART: $(Get-Date -Format u)"

function FindOrCreateReFSOrDevDriveVolume([string] $DevBoxRefsDrive, [int] $OsDriveMinSizeGB, [bool] $IsDevDrive, [string] $TempDir) {
    Write-Host "`nStarted with volumes:$(Get-Volume | Out-String)"

    # Check whether Dev Drive volume already exists, i.e. has already been created in the base image.
    $firstReFSVolume = (Get-Volume | Where-Object { $_.FileSystemType -eq "ReFS" } | Select-Object -First 1)
    if ($firstReFSVolume) {
        $fromDriveLetterOrNull = $firstReFSVolume.DriveLetter
        if ($DevBoxRefsDrive -eq $fromDriveLetterOrNull) {
            Write-Host "Code drive letter ${DevBoxRefsDrive} already matches the first ReFS/Dev Drive volume."
        }
        else {
            Write-Host "Assigning code drive letter to $DevBoxRefsDrive"
            $firstReFSVolume | Get-Partition | Set-Partition -NewDriveLetter $DevBoxRefsDrive
        }
    
        Write-Host "`nDone with volumes:$(Get-Volume | Out-String)"
    
        # This will mount the drive and open a handle to it which is important to get the drive ready.
        Write-Host "Checking dir contents of ${DevBoxRefsDrive}: drive"
        Get-ChildItem ${DevBoxRefsDrive}:
        return
    }

    $cSizeGB = (Get-Volume C).Size / 1024 / 1024 / 1024
    $targetReFSSizeGB = [math]::Floor($cSizeGB - $OsDriveMinSizeGB)
    $diffGB = $cSizeGB - $targetReFSSizeGB
    Write-Host "Target ReFS size $targetReFSSizeGB GB, current C: size $cSizeGB GB"
    # Sanity checks
    if ($diffGB -lt 50) {
        throw "ReFS/Dev Drive target size $targetReFSSizeGB GB would leave less than 50 GB free on drive C: which is not enough for Windows and apps. Drive C: size $cSizeGB GB"
    }
    if ($targetReFSSizeGB -lt 20) {
        throw "ReFS/Dev Drive target size $targetReFSSizeGB GB is below the min size 20 GB. Drive C: size $cSizeGB GB"
    }

    $targetReFSSizeMB = $targetReFSSizeGB * 1024

    if ((Get-PSDrive).Name -match "^" + $DevBoxRefsDrive + "$") {
        $DiskPartDeleteScriptPath = $TempDir + "/CreateReFSDelExistingVolume.txt"
        $rmcmd = "SELECT DISK 0 `r`n SELECT VOLUME=$DevBoxRefsDrive `r`n DELETE VOLUME OVERRIDE"
        $rmcmd | Set-Content -Path $DiskPartDeleteScriptPath
        Write-Host "Delete existing $DevBoxRefsDrive `r`n $rmcmd"
        diskpart /s $DiskPartDeleteScriptPath
        $exitCode = $LASTEXITCODE
        if ($exitCode -eq 0) {
            Write-Host "Successfully deleted existing $DevBoxRefsDrive volume" 
        }
        else {
            Write-Error "[ERROR] Delete volume diskpart command failed with exit code: $exitCode" -ErrorAction Stop
        }
    }
    
    # https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/shrink
    $DiskPartScriptPath = $TempDir + "/CreateReFSFromExistingVolume.txt"
    $cmd = "SELECT VOLUME C: `r`n SHRINK desired = $targetReFSSizeMB minimum = $targetReFSSizeMB `r`n CREATE PARTITION PRIMARY `r`n ASSIGN LETTER=$DevBoxRefsDrive `r`n"
    $cmd | Set-Content -Path $DiskPartScriptPath
    Write-Host "Creating $DevBoxRefsDrive ReFS volume: diskpart:`r`n $cmd"
    diskpart /s $DiskPartScriptPath
    $exitCode = $LASTEXITCODE
    if ($exitCode -eq 0) {
        Write-Host "Successfully created ReFS $DevBoxRefsDrive volume"
    }
    else {
        Write-Error "[ERROR] ReFS volume creation command failed with exit code: $exitCode" -ErrorAction Stop
    }

    $DevBoxDriveWithColon = "${DevBoxRefsDrive}:"
    $DevDriveParam = ""
    $DriveLabel = "ReFS"
    if ($IsDevDrive) {
        $DevDriveParam = "/DevDrv"
        $DriveLabel = "DevDrive"
    }
    Run-Program format "$DevBoxDriveWithColon /q /y /FS:ReFS $DevDriveParam /V:$DriveLabel" -RetryAttempts 1
    Write-Host "Successfully formatted ReFS $DevBoxRefsDrive volume. Final volume list:"
    Get-Volume | Out-String
}

Import-Module -Force (Join-Path $(Split-Path -Parent $PSScriptRoot) '_common/windows-run-program.psm1') -DisableNameChecking
if (( -not(Test-Path variable:global:IsUnderTest)) -or (-not $global:IsUnderTest)) {
    try {
        FindOrCreateReFSOrDevDriveVolume $DevBoxRefsDrive $OsDriveMinSizeGB $IsDevDrive $env:TEMP
    } catch {
        Write-Error "!!! [ERROR] Unhandled exception:`n$_`n$($_.ScriptStackTrace)" -ErrorAction Stop
    }
}
