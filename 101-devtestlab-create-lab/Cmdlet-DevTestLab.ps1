<##################################################################################################

    Usage
    =====

    Login-AzureRmAccount
    Import-Module .\Cmdlet-DevTestLab.ps1
    New-AzureDtlLab -LabName <lab name> -LabLocation <lab location>   


    Pre-Requisites
    ==============

    - Please ensure that the powershell execution policy is set to unrestricted or bypass.
    - Please ensure that the latest version of Azure Powershell in installed on the machine.


    Known Issues
    ============
    - The following regression in the Azure PS cmdlets impacts us currently. 
      - https://github.com/Azure/azure-powershell/issues/1259

##################################################################################################>

function FetchAzureResource
{
    Param(
        [Parameter(Mandatory=$true, ParameterSetName="SingleResourceId")] 
        [ValidateNotNullOrEmpty()]
        [string]
        $ResourceId,

        [Parameter(Mandatory=$true, ParameterSetName="MultipleResourceIds")] 
        [ValidateNotNullOrEmpty()]
        [string[]]
        $ResourceIds
    )

    switch ($PSCmdlet.ParameterSetName)
    {
        "SingleResourceId"
        {
            return Get-AzureRmResource -ResourceId $ResourceId -ExpandProperties
        }

        "MultipleResourceIds"
        {
            $resources = @()

            $ResourceIds | % { $resources += Get-AzureRmResource -ResourceId $_ }

            if ($resources.Count -eq 0)
            {
                return $null
            }
            else
            {
                return $resources
            }
        }
    }
}

function Get-AzureDtlLab
{
    [CmdletBinding(DefaultParameterSetName="ListAll")]
    Param(
        # ResourceId of the lab
        [Parameter(Mandatory=$true, ParameterSetName="ListByLabId")] 
        [ValidateNotNullOrEmpty()]
        [string]
        $LabId,

        # Name of the lab
        [Parameter(Mandatory=$true, ParameterSetName="ListByLabName")] 
        [ValidateNotNullOrEmpty()]
        [string]
        $LabName,

        # Name of the lab's resource group
        [Parameter(Mandatory=$false, ParameterSetName="ListByLabName")] 
        [Parameter(Mandatory=$true, ParameterSetName="ListAllInResourceGroup")] 
        [ValidateNotNullOrEmpty()]
        [string]
        $LabResourceGroupName,

        # Location of the lab
        [Parameter(Mandatory=$true, ParameterSetName="ListAllInLocation")] 
        [ValidateNotNullOrEmpty()]
        [string]
        $LabLocation
    )

    PROCESS
    {
        Write-Verbose "Displaying parameter values"
        Write-Verbose "==========================="
        Write-Verbose $("`LabId = " + $LabId)
        Write-Verbose $("`LabName = " + $LabName)
        Write-Verbose $("`LabResourceGroupName = " + $LabResourceGroupName)
        Write-Verbose $("`LabLocation = " + $LabLocation)
        Write-Verbose "==========================="
        Write-Verbose "Displaying parameter set values"
        Write-Verbose "==============================="
        Write-Verbose $("`$PSCmdlet.ParameterSetName = " + $PSCmdlet.ParameterSetName)
        Write-Verbose "==============================="

        # The lab resource type
        $labResourceType = "microsoft.devtestlab/labs"

        switch($PSCmdlet.ParameterSetName)
        {
            "ListByLabId"
            {
                Get-AzureRmResource | Where { 
                    $_.ResourceType -eq $labResourceType -and 
                    $_.ResourceId -eq $LabId 
                } | Write-Output
            }
                    
            "ListByLabName"
            {
                if ($PSBoundParameters.ContainsKey("LabResourceGroupName"))
                {
                    Get-AzureRmResource | Where { 
                        $_.ResourceType -eq $labResourceType -and 
                        $_.ResourceName -eq $LabName -and 
                        $_.ResourceGroupName -eq $LabResourceGroupName 
                    } | Write-Output                
                }
                else
                {
                    Get-AzureRmResource | Where { 
                        $_.ResourceType -eq $labResourceType -and 
                        $_.ResourceName -eq $LabName 
                    }                 
                }
            }

            "ListAllInResourceGroup"
            {
                Get-AzureRmResource | Where { 
                    $_.ResourceType -eq $labResourceType -and 
                    $_.ResourceGroupName -eq $LabResourceGroupName 
                } | Write-Output
            }

            "ListAllInLocation"
            {
                Get-AzureRmResource | Where { 
                    $_.ResourceType -eq $labResourceType -and 
                    $_.Location -eq $LabLocation 
                } | Write-Output
            }

            "ListAll" 
            {
                Get-AzureRmResource | Where { 
                    $_.ResourceType -eq $labResourceType 
                } | Write-Output
            }
        }
    }
}

##################################################################################################

function Get-AzureDtlVirtualMachine
{
    [CmdletBinding(DefaultParameterSetName="ListAll")]
    Param(
        # ResourceId of the VM
        [Parameter(Mandatory=$true, ParameterSetName="ListByVMId")] 
        [ValidateNotNullOrEmpty()]
        [string]
        $VMId,

        # Name of the VM
        [Parameter(Mandatory=$true, ParameterSetName="ListByVMName")] 
        [ValidateNotNullOrEmpty()]
        [string]
        $VMName,

        # Name of the VM
        [Parameter(Mandatory=$true, ParameterSetName="ListAllInLab")] 
        [ValidateNotNullOrEmpty()]
        [string]
        $LabName,

        # Name of the VM's resource group
        [Parameter(Mandatory=$true, ParameterSetName="ListAllInResourceGroup")] 
        [ValidateNotNullOrEmpty()]
        [string]
        $VMResourceGroupName,

        # Location of the VM
        [Parameter(Mandatory=$true, ParameterSetName="ListAllInLocation")] 
        [ValidateNotNullOrEmpty()]
        [string]
        $VMLocation
    )

    PROCESS
    {
        Write-Verbose "Displaying parameter values"
        Write-Verbose "==========================="
        Write-Verbose $("`$VMId = " + $VMId)
        Write-Verbose $("`$VMName = " + $VMName)
        Write-Verbose $("`$VMResourceGroupName = " + $VMResourceGroupName)
        Write-Verbose $("`$VMLocation = " + $VMLocation)
        Write-Verbose "==========================="
        Write-Verbose "Displaying parameter set values"
        Write-Verbose "==============================="
        Write-Verbose $("`$PSCmdlet.ParameterSetName = " + $PSCmdlet.ParameterSetName)
        Write-Verbose "==============================="

        # The DTL resource types
        $labResourceType = "microsoft.devtestlab/labs"
        $environmentResourceType = "microsoft.devtestlab/environments"

        switch($PSCmdlet.ParameterSetName)
        {
            "ListByVMId"
            {
                Get-AzureRmResource | Where { 
                    $_.ResourceType -eq $environmentResourceType -and 
                    $_.ResourceId -eq $VMId 
                } | Write-Output
            }
                    
            "ListByVMName"
            {
                Get-AzureRmResource | Where { 
                    $_.ResourceType -eq $environmentResourceType -and 
                    $_.ResourceName -eq $VMName 
                } | Write-Output                
            }

            "ListAllInLab"
            {
                $fetchedLabObj = Get-AzureDtlLab -LabName $LabName 

                if ($fetchedLabObj -ne $null -and $fetchedLabObj.Count -ne 0)
                {
                    if ($fetchedLabObj.Count > 1)
                    {
                        Write-Error $("Multiple labs found with name '" + $LabName + "'")
                    }
                    else
                    {
                        write-Verbose $("Found lab : " + $fetchedLabObj.ResourceName) 
                        write-Verbose $("LabId : " + $fetchedLabObj.ResourceId) 

                        Get-AzureRmResource -ExpandProperties | Where { 
                            $_.ResourceType -eq $environmentResourceType -and
                            $_.Properties.LabId -eq $fetchedLabObj.ResourceId
                        } | Write-Output
                    }
                }
            }

            "ListAllInResourceGroup"
            {
                Get-AzureRmResource | Where { 
                    $_.ResourceType -eq $environmentResourceType -and 
                    $_.ResourceGroupName -eq $VMResourceGroupName 
                } | Write-Output                
            }

            "ListAllInLocation"
            {
                Get-AzureRmResource | Where { 
                    $_.ResourceType -eq $environmentResourceType -and 
                    $_.Location -eq $VMLocation 
                } | Write-Output
            }

            "ListAll" 
            {
                Get-AzureRmResource | Where { 
                    $_.ResourceType -eq $environmentResourceType 
                } | Write-Output 
            }
        }
    }
}

##################################################################################################

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

        # Pre-condition check to ensure the RM template file exists.
        if ($false -eq (Test-Path -Path $LabCreationTemplateFile))
        {
            Write-Error $("The RM template file could not be located at : '" + $LabCreationTemplateFile + "'")
        }
        else
        {
            Write-Verbose $("The RM template file was located at : '" + $LabCreationTemplateFile + "'")
        }

        # The lab resource type
        $labResourceType = "microsoft.devtestlab/labs"

        # Check if there are any existing labs with same name, resource group and location
        $existingLabs = Get-AzureRmResource | Where { 
            $_.ResourceType -eq $labResourceType -and 
            $_.ResourceName -eq $LabName -and 
            $_.ResourceGroupName -eq $LabName -and 
            $_.Location -eq $LabLocation }

        # If none exist, then create a new one
        if ($null -eq $existingLabs -or 0 -eq $existingLabs.Count)
        {
            # Create a new resource group with the same name as the lab. 
            Write-Verbose $("Creating new resoure group '" + $LabName + "' at location '" + $LabLocation + "'")
            $resourceGroup = New-AzureRmResourceGroup -Name $LabName -Location $LabLocation
    
            # Create the lab in this resource group by deploying the RM template
            Write-Verbose $("Creating new lab '" + $LabName + "'")
            $rgDeployment = New-AzureRmResourceGroupDeployment -ResourceGroupName $LabName  -TemplateFile $LabCreationTemplateFile -labname $LabName 

            if (($null -ne $rgDeployment) -and ($null -ne $rgDeployment.Outputs['labId']) -and ($null -ne $rgDeployment.Outputs['labId'].Value))
            {
                $labId = $rgDeployment.Outputs['labId'].Value

                Write-Verbose $("LabId : '" + $labId + "'")

                Get-AzureRmResource -ResourceId $labId | Write-Output
            }
        }

        # else display an error
        else
        {
            Write-Error $("One or more labs with name '" + $LabName + "' already exist at location '" + $LabLocation + "'.")
        }
    }
}

##################################################################################################

function New-AzureDtlVirtualMachine
{
    [CmdletBinding(DefaultParameterSetName="UseBuiltInUser")]
    Param(
        # Name of virtual machine to be created.
        [Parameter(Mandatory=$true, ParameterSetName="UseBuiltInUser")] 
        [Parameter(Mandatory=$true, ParameterSetName="UseUsernamePwd")] 
        [ValidateNotNullOrEmpty()]
        [string]
        $VMName,

        # Size of virtual machine to be created.
        [Parameter(Mandatory=$true, ParameterSetName="UseBuiltInUser")] 
        [Parameter(Mandatory=$true, ParameterSetName="UseUsernamePwd")] 
        [ValidateNotNullOrEmpty()]
        [string]
        $VMSize,

        # An existing DevTestLab instance in which the virtual machine will be created.
        [Parameter(Mandatory=$true, ParameterSetName="UseBuiltInUser")] 
        [Parameter(Mandatory=$true, ParameterSetName="UseUsernamePwd")] 
        [ValidateNotNull()]
        $Lab,

        # Name of an existing VM template which will be used to create the virtual machine.
        # Note: The specified vm template must exist in the lab (identified via the 'labName' parameter)
        [Parameter(Mandatory=$true, ParameterSetName="UseBuiltInUser")] 
        [Parameter(Mandatory=$true, ParameterSetName="UseUsernamePwd")] 
        [ValidateNotNullOrEmpty()]
        [string]
        $VMTemplateName
    )

    PROCESS 
    {
        # Folder location of VM creation script, the template file and template parameters file.
        $VMCreationTemplateFile = Join-Path $PSScriptRoot -ChildPath "azuredeploy.json"

        if ($false -eq (Test-Path -Path $VMCreationTemplateFile))
        {
            Write-Error $("The RM template file could not be located at : '" + $VMCreationTemplateFile + "'")
        }
        else
        {
            Write-Verbose $("The RM template file was located at : '" + $VMCreationTemplateFile + "'")
        }

        # Check if there are any existing labs with same name
        $existingLabs = Get-AzureRmResource | Where { 
            $_.ResourceType -eq $labResourceType -and 
            $_.ResourceName -eq $LabName -and 
            $_.ResourceGroupName -eq $LabName -and 
            $_.Location -eq $LabLocation }



        # Create the virtual machine in this lab by deploying the RM template
        Write-Verbose $("Creating new virtual machine '" + $VMName + "'")
        $rgDeployment = New-AzureRmResourceGroupDeployment -ResourceGroupName $Lab.ResourceGroupName -TemplateFile $VMCreationTemplateFile -vmName $VMName -labName $Lab.ResourceName -vmSize $VMSize -vmTemplateName $VMTemplateName

        if (($null -ne $rgDeployment) -and ($null -ne $rgDeployment.Outputs['vmId']) -and ($null -ne $rgDeployment.Outputs['vmId'].Value))
        {
            Write-Verbose $("vm id : '" + $rgDeployment.Outputs['vmId'].Value + "'")

            Get-AzureRmResource -ResourceId $rgDeployment.Outputs['vmId'].Value | Write-Output
        }
    }
}

##################################################################################################

