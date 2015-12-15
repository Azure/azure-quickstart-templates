<##################################################################################################

    Usage Example
    =============

    Login-AzureRmAccount
    Import-Module .\Cmdlets.DevTestLab.ps1
    Get-AzureDtlLab   


    Help / Documentation
    ====================
    - To view a cmdlet's help description: Get-help "cmdlet-name" -Detailed
    - To view a cmdlet's usage example: Get-help "cmdlet-name" -Examples


    Pre-Requisites
    ==============
    - Please ensure that the powershell execution policy is set to unrestricted or bypass.
    - Please ensure that the latest version of Azure Powershell in installed on the machine.


    Known Issues
    ============
    - The following regression in the Azure PS cmdlets impacts us currently. 
      - https://github.com/Azure/azure-powershell/issues/1259

##################################################################################################>

function Get-AzureDtlLab
{
    <#
        .SYNOPSIS
        Gets labs under the current subscription.

        .DESCRIPTION
        The Get-AzureDtlLab cmdlet does the following: 
        - Gets a specific lab, if the -LabId parameter is specified.
        - Gets all labs with matching name, if the -LabName parameter is specified.
        - Gets all labs with matching name within a resource group, if the -LabName and -LabResourceGroupName parameters are specified.
        - Gets all labs in a resource group, if the -LabResourceGroupName parameter is specified.
        - Gets all labs in a location, if the -LabLocation parameter is specified.
        - Gets all labs within current subscription, if no parameters are specified. 

        .EXAMPLE
        Get-AzureDtlLab -LabId "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/MyLabRG/providers/Microsoft.DevTestLab/labs/MyLab"
        Gets a specific lab, identified by the specified resource-id.

        .EXAMPLE
        Get-AzureDtlLab -LabName "MyLab"
        Gets all labs with the name "MyLab".

        .EXAMPLE
        Get-AzureDtlLab -LabName "MyLab" -LabResourceGroupName "MyLabRG"
        Gets all labs with the name "MyLab" within the resource group "MyLabRG".

        .EXAMPLE
        Get-AzureDtlLab -LabResourceGroupName "MyLabRG"
        Gets all labs in the "MyLabRG" resource group.

        .EXAMPLE
        Get-AzureDtlLab -LabLocation "westus"
        Gets all labs in the "westus" location.

        .EXAMPLE
        Get-AzureDtlLab
        Gets all labs within current subscription (use the Select-AzureRmSubscription cmdlet to change the current subscription).

        .INPUTS
        None. Currently you cannot pipe objects to this cmdlet (this will be fixed in a future version).  
    #>
    [CmdletBinding(DefaultParameterSetName="ListAll")]
    Param(
        [Parameter(Mandatory=$true, ParameterSetName="ListByLabId")] 
        [ValidateNotNullOrEmpty()]
        [string]
        # The ResourceId of the lab (e.g. "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/MyLabRG/providers/Microsoft.DevTestLab/labs/MyLab").
        $LabId,

        [Parameter(Mandatory=$true, ParameterSetName="ListByLabName")] 
        [ValidateNotNullOrEmpty()]
        [string]
        # The name of the lab.
        $LabName,

        [Parameter(Mandatory=$false, ParameterSetName="ListByLabName")] 
        [Parameter(Mandatory=$true, ParameterSetName="ListAllInResourceGroup")] 
        [ValidateNotNullOrEmpty()]
        [string]
        # The name of the lab's resource group.
        $LabResourceGroupName,

        [Parameter(Mandatory=$true, ParameterSetName="ListAllInLocation")] 
        [ValidateNotNullOrEmpty()]
        [string]
        # The location of the lab ("westus", "eastasia" etc).
        $LabLocation
    )

    PROCESS
    {
        Write-Verbose $("Processing cmdlet '" + $PSCmdlet.MyInvocation.InvocationName + "', ParameterSet = '" + $PSCmdlet.ParameterSetName + "'")

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
    <#
        .SYNOPSIS
        Gets virtual machines under the current subscription.

        .DESCRIPTION
        The Get-AzureDtlVirtualMachine cmdlet does the following: 
        - Gets a specific VM, if the -VMId parameter is specified.
        - Gets all VMs with matching name, if the -VMName parameter is specified.
        - Gets all VMs in a lab, if the -LabName parameter is specified.
        - Gets all VMs in a resource group, if the -VMResourceGroup parameter is specified.
        - Gets all VMs in a location, if the -VMLocation parameter is specified.
        - Gets all VMs within current subscription, if no parameters are specified. 

        .EXAMPLE
        Get-AzureDtlVirtualMachine -VMId "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/MyLabRG/providers/Microsoft.DevTestLab/environments/MyVM"
        Gets a specific VM, identified by the specified resource-id.

        .EXAMPLE
        Get-AzureDtlVirtualMachine -VMName "MyVM1"
        Gets all VMs with the name "MyVM1".

        .EXAMPLE
        Get-AzureDtlVirtualMachine -LabName "MyLab"
        Gets all VMs within the lab "MyLab".

        .EXAMPLE
        Get-AzureDtlVirtualMachine -VMResourceGroupName "MyLabRG"
        Gets all VMs in the "MyLabRG" resource group.

        .EXAMPLE
        Get-AzureDtlVirtualMachine -VMLocation "westus"
        Gets all VMs in the "westus" location.

        .EXAMPLE
        Get-AzureDtlVirtualMachine
        Gets all VMs within current subscription (use the Select-AzureRmSubscription cmdlet to change the current subscription).

        .INPUTS
        None. Currently you cannot pipe objects to this cmdlet (this will be fixed in a future version).  
    #>
    [CmdletBinding(DefaultParameterSetName="ListAll")]
    Param(
        [Parameter(Mandatory=$true, ParameterSetName="ListByVMId")] 
        [ValidateNotNullOrEmpty()]
        [string]
        # The ResourceId of the VM (e.g. "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/MyLabRG/providers/Microsoft.DevTestLab/environments/MyVM").
        $VMId,

        [Parameter(Mandatory=$true, ParameterSetName="ListByVMName")] 
        [ValidateNotNullOrEmpty()]
        [string]
        # The name of the VM.
        $VMName,

        [Parameter(Mandatory=$true, ParameterSetName="ListAllInLab")] 
        [ValidateNotNullOrEmpty()]
        [string]
        # Name of the lab.
        $LabName,

        [Parameter(Mandatory=$true, ParameterSetName="ListAllInResourceGroup")] 
        [ValidateNotNullOrEmpty()]
        [string]
        # The name of the VM's resource group.
        $VMResourceGroupName,

        [Parameter(Mandatory=$true, ParameterSetName="ListAllInLocation")] 
        [ValidateNotNullOrEmpty()]
        [string]
        # The location of the VM.
        $VMLocation
    )

    PROCESS
    {
        Write-Verbose $("Processing cmdlet '" + $PSCmdlet.MyInvocation.InvocationName + "', ParameterSet = '" + $PSCmdlet.ParameterSetName + "'")

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
    <#
        .SYNOPSIS
        Creates a new lab.

        .DESCRIPTION
        The New-AzureDtlLab cmdlet creates a new lab in the specified location.

        .EXAMPLE
        New-AzureDtlLab -LabName "MyLab1" -LabLocation "West US"
        Creates a new lab "MyLab1" in the location "West US".

        .INPUTS
        None. Currently you cannot pipe objects to this cmdlet (this will be fixed in a future version).  
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)] 
        [ValidateNotNullOrEmpty()]
        [string]
        # Name of lab to be created.
        $LabName,

        [Parameter(Mandatory=$true)] 
        [ValidateNotNullOrEmpty()]
        [string]
        # Location where the lab will be created.
        $LabLocation
    )

    PROCESS 
    {
        Write-Verbose $("Processing cmdlet '" + $PSCmdlet.MyInvocation.InvocationName + "', ParameterSet = '" + $PSCmdlet.ParameterSetName + "'")

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
            $_.Location -eq $LabLocation 
        }

        # If none exist, then create a new one
        if ($null -eq $existingLabs -or 0 -eq $existingLabs.Count)
        {
            # Create a new resource group with the same name as the lab. 
            Write-Verbose $("Creating new resoure group '" + $LabName + "' at location '" + $LabLocation + "'")
            $resourceGroup = New-AzureRmResourceGroup -Name $LabName -Location $LabLocation
    
            # Create the lab in this resource group by deploying the RM template
            Write-Verbose $("Creating new lab '" + $LabName + "'")
            $rgDeployment = New-AzureRmResourceGroupDeployment -ResourceGroupName $LabName  -TemplateFile $LabCreationTemplateFile -newLabName $LabName 

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
    <#
        .SYNOPSIS
        Creates a new virtual machine.

        .DESCRIPTION
        The New-AzureDtlVirtualMachine cmdlet creates a new VM in a lab (and optionally creates a user account on the VM).

        .EXAMPLE
        $lab = $null

        $lab = Get-AzureDtlLab -LabName "MyLab"
        New-AzureDtlVirtualMachine -VMName "MyVM" -VMSize "Standard_A4" -Lab $lab -VMTemplate "MyVMTemplate"

        Creates a new VM "MyVM" from the VM template "MyVMTemplate" in the lab "MyLab".
        - No new user account is created during the VM creation.
        - We assume that the original VM template already contains a built-in user account.
        - We assume that this built-in account can be used to log into the VM after creation.

        .EXAMPLE
        $lab = $null

        $lab = Get-AzureDtlLab -LabName "MyLab"
        $secPwd = ConvertTo-SecureString -String "MyPwd" -AsPlainText -Force
        New-AzureDtlVirtualMachine -VMName "MyVM" -VMSize "Standard_A4" -Lab $lab -VMTemplate "MyVMTemplate" -UserName "MyAdmin" -Password $secPwd

        Creates a new VM "MyVM" from the VM template "MyVMTemplate" in the lab "MyLab".
        - A new user account is created using the username/password combination specified.
        - This user account is added to the local administrators group. 

        .EXAMPLE
        $lab = $null

        $lab = Get-AzureDtlLab -LabName "MyLab"
        $sshKey = ConvertTo-SecureString -String "MyKey" -AsPlainText -Force
        New-AzureDtlVirtualMachine -VMName "MyVM" -VMSize "Standard_A4" -Lab $lab -VMTemplate "MyVMTemplate" -UserName "MyAdmin" -SSHKey $sshKey

        Creates a new VM "MyVM" from the VM template "MyVMTemplate" in the lab "MyLab".
        - A new user account is created using the username/SSH-key combination specified.

        .INPUTS
        None. Currently you cannot pipe objects to this cmdlet (this will be fixed in a future version).  
    #>
    [CmdletBinding(DefaultParameterSetName="BuiltInUser")]
    Param(
        [Parameter(Mandatory=$true, ParameterSetName="BuiltInUser")] 
        [Parameter(Mandatory=$true, ParameterSetName="UsernamePwd")] 
        [Parameter(Mandatory=$true, ParameterSetName="UsernameSSHKey")] 
        [ValidateNotNullOrEmpty()]
        [string]
        # The name of VM to be created.
        $VMName,

        [Parameter(Mandatory=$true, ParameterSetName="BuiltInUser")] 
        [Parameter(Mandatory=$true, ParameterSetName="UsernamePwd")] 
        [Parameter(Mandatory=$true, ParameterSetName="UsernameSSHKey")] 
        [ValidateNotNullOrEmpty()]
        [string]
        # The size of VM to be created ("Standard_A0", "Standard_D1_v2", "Standard_D2" etc).
        $VMSize,

        [Parameter(Mandatory=$true, ParameterSetName="BuiltInUser")] 
        [Parameter(Mandatory=$true, ParameterSetName="UsernamePwd")] 
        [Parameter(Mandatory=$true, ParameterSetName="UsernameSSHKey")] 
        [ValidateNotNull()]
        # An existing lab in which the VM will be created (please use the Get-AzureDtlLab cmdlet to get this lab object).
        $Lab,

        [Parameter(Mandatory=$true, ParameterSetName="BuiltInUser")] 
        [Parameter(Mandatory=$true, ParameterSetName="UsernamePwd")] 
        [Parameter(Mandatory=$true, ParameterSetName="UsernameSSHKey")] 
        [ValidateNotNullOrEmpty()]
        [string]
        # The name of an existing VM template which will be used to create the new VM (this VM template must exist in the lab identified via the '-LabName' parameter).
        $VMTemplateName,

        [Parameter(Mandatory=$true, ParameterSetName="UsernamePwd")] 
        [Parameter(Mandatory=$true, ParameterSetName="UsernameSSHKey")] 
        [ValidateNotNullOrEmpty()]
        [string]
        # The user name that will be created on the new VM.
        $UserName,

        [Parameter(Mandatory=$true, ParameterSetName="UsernamePwd")] 
        [ValidateNotNullOrEmpty()]
        [Security.SecureString]
        # The password for the user to be created.
        $Password,

        [Parameter(Mandatory=$true, ParameterSetName="UsernameSSHKey")] 
        [ValidateNotNullOrEmpty()]
        [Security.SecureString]
        # The public SSH key for user to be created.
        $SSHKey
    )

    PROCESS 
    {
        Write-Verbose $("Processing cmdlet '" + $PSCmdlet.MyInvocation.InvocationName + "', ParameterSet = '" + $PSCmdlet.ParameterSetName + "'")

        # The DTL resource types
        $labResourceType = "microsoft.devtestlab/labs"
        $environmentResourceType = "microsoft.devtestlab/environments"

        # Unique name for the deployment
        $deploymentName = [Guid]::NewGuid().ToString()

        # Folder location of VM creation script, the template file and template parameters file.
        $VMCreationTemplateFile = $null

        switch($PSCmdlet.ParameterSetName)
        {
            "BuiltInUser"
            {
                $VMCreationTemplateFile = Join-Path $PSScriptRoot -ChildPath "..\101-dtl-create-vm-builtin-user\azuredeploy.json" -Resolve
            }

            "UsernamePwd"
            {
                $VMCreationTemplateFile = Join-Path $PSScriptRoot -ChildPath "..\101-dtl-create-vm-username-pwd\azuredeploy.json" -Resolve
            }

            "UsernameSSHKey"
            {
                $VMCreationTemplateFile = Join-Path $PSScriptRoot -ChildPath "..\101-dtl-create-vm-username-ssh\azuredeploy.json" -Resolve
            }
        }

        # pre-condition check to ensure that the template file actually exists.
        if ($false -eq (Test-Path -Path $VMCreationTemplateFile))
        {
            Write-Error $("The RM template file could not be located at : '" + $VMCreationTemplateFile + "'")
        }
        else
        {
            Write-Verbose $("The RM template file was located at : '" + $VMCreationTemplateFile + "'")
        }

        # Check if there are any existing VMs with same name in the specified lab
        $existingVMs = Get-AzureDtlVirtualMachine -LabName $Lab.ResourceName | Where {
            $_.ResourceName -eq $VMName
        } 

        # If none exist, then create a new one
        if ($null -eq $existingVMs -or 0 -eq $existingVMs.Count)
        {
            # Create the virtual machine in this lab by deploying the RM template
            Write-Verbose $("Creating new virtual machine '" + $VMName + "'")
            Write-Warning $("Creating new virtual machine '" + $VMName + "'. This may take a couple of minutes.")

            $rgDeployment = $null

            switch($PSCmdlet.ParameterSetName)
            {
                "BuiltInUser"
                {
                    $rgDeployment = New-AzureRmResourceGroupDeployment -Name $deploymentName -ResourceGroupName $Lab.ResourceGroupName -TemplateFile $VMCreationTemplateFile -newVMName $VMName -existingLabName $Lab.ResourceName -newVMSize $VMSize -existingVMTemplateName $VMTemplateName
                }

                "UsernamePwd"
                {
                    $rgDeployment = New-AzureRmResourceGroupDeployment -Name $deploymentName -ResourceGroupName $Lab.ResourceGroupName -TemplateFile $VMCreationTemplateFile -newVMName $VMName -existingLabName $Lab.ResourceName -newVMSize $VMSize -existingVMTemplateName $VMTemplateName -userName $UserName -password $Password
                }

                "UsernameSSHKey"
                {
                    $rgDeployment = New-AzureRmResourceGroupDeployment -Name $deploymentName -ResourceGroupName $Lab.ResourceGroupName -TemplateFile $VMCreationTemplateFile -newVMName $VMName -existingLabName $Lab.ResourceName -newVMSize $VMSize -existingVMTemplateName $VMTemplateName -userName $UserName -sshKey $SSHKey  
                }
            }

            if (($null -ne $rgDeployment) -and ($null -ne $rgDeployment.Outputs['vmId']) -and ($null -ne $rgDeployment.Outputs['vmId'].Value))
            {
                Write-Verbose $("vm id : '" + $rgDeployment.Outputs['vmId'].Value + "'")

                Get-AzureRmResource -ResourceId $rgDeployment.Outputs['vmId'].Value | Write-Output
            }
        }

        # else display an error
        else
        {
            Write-Error $("One or more VMs with name '" + $VMName + "' already exist in lab '" + $Lab.ResourceName + "'.")
        }
    }
}

##################################################################################################

