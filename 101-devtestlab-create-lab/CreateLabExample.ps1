<##################################################################################################

    Usage
    =====
    
    - Powershell -executionpolicy bypass -file CreateLabExample.ps1  


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

# Folder location of this script, the template file and template parameters file.
$ScriptDir = Split-Path $MyInvocation.MyCommand.Path
$TemplateFile = Join-Path $ScriptDir -ChildPath "azuredeploy.json"
$TemplateParameterFile = Join-Path $ScriptDir -ChildPath "azuredeploy.parameters.json"

##################################################################################################

try
{
    Login-AzureRmAccount

    $myRGName = "CreateLabExampleRG"

    Write-Host $("Creating a resource group: " + $myRGName)
    $myRG = New-AzureRmResourceGroup -Name $myRGName -Location "West US"

    Write-Host $("Creating a lab in above resoure group.")
    $myDeployment = New-AzureRmResourceGroupDeployment -ResourceGroupName $myRGName -TemplateFile $TemplateFile -TemplateParameterFile $TemplateParameterFile -Verbose

    Write-Host $("Displaying the created lab.")
    $myLabId = $myDeployment.Outputs['labId'].Value
    Get-AzureRmResource -ResourceId $myLabId
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