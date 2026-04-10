<#
.SYNOPSIS
    Remaps the CloudPC-designated D: ReFS/Dev Drive code drive to the original Q: drive used during image gen.
.DESCRIPTION
    Image prep creates the ReFS volume as Q: to avoid low letters like D: that can be mapped
    to a temp drive or virtual CD-ROM, and the N: drive reserved by the image builder.
    Image prep can update global environment variables to contain Q:, and build outputs and
    caches applied to repos on Q: can have full paths inside them that would be invalidated
    by a drive letter change.
.PARAMETER ToDriveLetter
    Final ReFS partition drive letter, defaults to 'Q'.
#>

param
(
    [Parameter(Mandatory = $true)][PSObject] $TaskParams
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function RemapCodeDrive($TaskParams) {
    $ToDriveLetter = $TaskParams.ToDriveLetter
    if (!$ToDriveLetter) {
        $ToDriveLetter = 'Q'
    }

    # FileSystemType ReFS applies to Dev Drive as well, which is a special "Trusted" mode of ReFS.
    Write-Host "`nStarted with volumes:$(Get-Volume | Out-String)"
    $FirstReFSVolume = (Get-Volume | Where-Object { $_.FileSystemType -eq "ReFS" } | Select-Object -First 1)
    if (!$FirstReFSVolume) {
        throw "No ReFS drive found";
    }

    $FromDriveLetter = $FirstReFSVolume.DriveLetter
    if (!$FromDriveLetter) {
        throw "No ReFS drive letter found";
    }

    if ($ToDriveLetter -eq $FromDriveLetter) {
        Write-Host "Code drive letter ${ToDriveLetter} already matches the first ReFS/Dev Drive volume."
    }
    else {
        Write-Host "Reassigning code drive letter $FromDriveLetter to $ToDriveLetter"
        Set-Partition -DriveLetter $FromDriveLetter -NewDriveLetter $ToDriveLetter
    }

    Write-Host "`nEnded with volumes:$(Get-Volume | Out-String)"

    # This will mount the drive and open a handle to it.
    Write-Host "Checking dir contents of ${ToDriveLetter}: drive"
    Get-ChildItem ${ToDriveLetter}:
}

if (( -not(Test-Path variable:global:IsUnderTest)) -or (-not $global:IsUnderTest)) {
    try {
        # Unit-testable function - place all real logic there.
        RemapCodeDrive($TaskParams)
    }
    catch {
        Write-Host "!!! [WARN] Unhandled exception (will be ignored):`n$_`n$($_.ScriptStackTrace)"
    }
}
