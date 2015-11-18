<##################################################################################################

    Usage
    =====
    
    - Powershell -executionpolicy bypass -file CreateVMExample.ps1  


    Pre-Requisites
    ==============

    - Please ensure that the powershell execution policy is set to unrestricted or bypass.
    - Please ensure that the latest version of Azure Powershell in installed on the machine.

##################################################################################################>

#
# Powershell Configurations
#

# Note: Because the $ErrorActionPreference is "Stop", this script will stop on first failure.  
$ErrorActionPreference = "stop"

###################################################################################################

#
# Custom Configurations
#

# Default exit code
$ExitCode = 0

# Folder location of VM creation script, the template file and template parameters file.
$VMCreationScriptDir = Split-Path $MyInvocation.MyCommand.Path
$VMCreationTemplateFile = Join-Path $VMCreationScriptDir -ChildPath "azuredeploy.json"
$VMCreationTemplateParameterFile = Join-Path $VMCreationScriptDir -ChildPath "azuredeploy.parameters.json"

##################################################################################################

[CmdletBinding]
function New-AzureDtlVirtualMachine()
{
    Param(
        # Name of Dev/Test lab instance.
        [ValidateNotNullOrEmpty()]
        [string]
        $LabName,

        # Azure subscription ID associated with the Dev/Test lab instance.
        [ValidateNotNullOrEmpty()]
        [string]
        $AzureSubscriptionId,

        # Full path to the VHD file (that'll be uploaded to the Dev/Test lab instance).
        # Note: Currently we only support VHDs that are available from:
        # - local drives (e.g. c:\somefolder\somefile.ext)
        # - UNC shares (e.g. \\someshare\somefolder\somefile.ext).
        # - Network mapped drives (e.g. net use z: \\someshare\somefolder && z:\somefile.ext). 
        [ValidateNotNullOrEmpty()]
        [string]
        $VHDFullPath,

        # [Optional] The name that will be assigned to VHD once uploded to the Dev/Test lab instance.
        # The name should be in a "<filename>.vhd" format (E.g. "WinServer2012-VS2015.VHD"). 
        [string]
        $VHDFriendlyName,

        # [Optional] If this switch is specified, then any VHDs copied to the staging area (if any) 
        # will NOT be deleted.
        # Note: The default behavior is to delete all VHDs from the staging area.
        [switch]
        $KeepStagingVHD = $false
    )
}

try
{
    #Login-AzureRmAccount

}

catch
{
    if (($null -ne $Error[0]) -and ($null -ne $Error[0].Exception) -and ($null -ne $Error[0].Exception.Message))
    {
        $errMsg = $Error[0].Exception.Message
        Write-Host $errMsg
    }

    # Important note: Throwing a terminating error (using $ErrorActionPreference = "stop") still returns exit 
    # code zero from the powershell script. The workaround is to use try/catch blocks and return a non-zero 
    # exit code from the catch block. 
    $ExitCode = -1
}

finally
{
    Write-Host $("Exiting with " + $ExitCode)
    exit $ExitCode
}