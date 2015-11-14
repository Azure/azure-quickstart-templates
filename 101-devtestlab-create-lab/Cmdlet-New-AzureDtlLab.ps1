<##################################################################################################

    Usage
    =====

    Login-AzureRmAccount
    Import-Module .\New-AzureDtlLab.ps1
    New-AzureDtlLab -LabName <lab name> -LabLocation <lab location>   


    Pre-Requisites
    ==============

    - Please ensure that the powershell execution policy is set to unrestricted or bypass.
    - Please ensure that the latest version of Azure Powershell in installed on the machine.

##################################################################################################>

function New-AzureDtlLab
{
    [CmdletBinding()]
    Param(
        # Name of DevTestLab instance to be created.
        [ValidateNotNullOrEmpty()]
        [string]
        $LabName,

        # Location where the DevTestLab instance will be created.
        [ValidateNotNullOrEmpty()]
        [string]
        $LabLocation
    )

    PROCESS 
    {
        # Folder location of VM creation script, the template file and template parameters file.
        $LabCreationTemplateFile = Join-Path $PSScriptRoot -ChildPath "azuredeploy.json"

        if ($false -eq (Test-Path -Path $LabCreationTemplateFile))
        {
            Write-Error $("The RM template file could not be located at : '" + $LabCreationTemplateFile + "'")
        }
        else
        {
            Write-Verbose $("The RM template file was located at : '" + $LabCreationTemplateFile + "'")
        }

        # Create a new resource group with the same name as the lab. 
        Write-Verbose $("Creating new resoure group '" + $LabName + "' at location '" + $LabLocation + "'")
        $resourceGroup = New-AzureRmResourceGroup -Name $LabName -Location $LabLocation
    
        # Create the lab in this resource group by deploying the RM template
        Write-Verbose $("Creating new lab '" + $LabName + "'")
        $rgDeployment = New-AzureRmResourceGroupDeployment -ResourceGroupName $LabName -TemplateFile $LabCreationTemplateFile -labname $LabName

        if (($null -ne $rgDeployment) -and ($null -ne $rgDeployment.Outputs['labId']) -and ($null -ne $rgDeployment.Outputs['labId'].Value))
        {
            Write-Verbose $("Lab id : '" + $rgDeployment.Outputs['labId'].Value + "'")

            Get-AzureRmResource -ResourceId $rgDeployment.Outputs['labId'].Value | Write-Output
        }
    }
}