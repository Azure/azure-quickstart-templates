<#
.SYNOPSIS
    Updates Dev Drive configuration. Requires that the Dev Drive feature be enabled, and if applicable
    a reboot performed, prior to calling this script.
.DESCRIPTION
    Uses `fsutil devdrv` to set optional Windows filter drivers allowed to attach to Dev Drive.
    The default for Dev Drive is to allow a very small list, which is how it gains performance -
    the more filter drivers, the more kernel callbacks in the chain-of-responsibility for every single
    filesystem call. The list of drivers added by the caller should be as minimal as possible.
    Note that the driver list set by fsutil adds to any default list set by Group Policy.
.PARAMETER EnableGVFS
    When set, the PrjFlt filesystem minifilter driver is allowed on the Dev Drive.
    This supports use of GVFS/VFSForGit repo enlistments at the cost of reduced Dev Drive performance.
.PARAMETER EnableContainers
    When set, the wcifs and bindflt filesystem minifilter drivers are allowed on the Dev Drive.
    This supports mounting Windows containers on the Dev Drive at the cost of reduced Dev Drive performance.
#>

param
(
    [Parameter(Mandatory = $true)][bool] $EnableGVFS,
    [Parameter(Mandatory = $true)][bool] $EnableContainers
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

Write-Host ""
Write-Host "Check that /DrvDrv parameter is visible on format command."
format /?

Write-Host "Setting Dev Drive group policies and settings."

# MsSecFlt - allow mounting Defender
# ProcMon24 - Allow ProcMon by default for better default dev experience - its driver attaches only during measurement.
#             The name of this driver can occasionally change, the Windows team has a table at
#             https://aka.ms/DevDrive#filters-for-common-scenarios that may match reality when updated.
$AllowedFilterList = "MsSecFlt,ProcMon24"
if ($EnableGVFS) {
    $AllowedFilterList += ",PrjFlt"
}
if ($EnableContainers) {
    $AllowedFilterList += ",wcifs,bindFlt"
}
Write-Host ""
Write-Host "Allowing the following filesystem filter drivers to mount to any Dev Drive:"
Write-Host "  $AllowedFilterList"
fsutil devdrv setFiltersAllowed $AllowedFilterList
