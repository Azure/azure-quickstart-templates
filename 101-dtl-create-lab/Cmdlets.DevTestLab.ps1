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

#
# Configurations
#

# Resource types exposed by the DevTestLab provider.
$LabResourceType = "microsoft.devtestlab/labs"
$EnvironmentResourceType = "microsoft.devtestlab/environments"
$VMTemplateResourceType = "microsoft.devtestlab/labs/vmtemplates"
$ArtifactSourceResourceType = "microsoft.devtestlab/labs/artifactsources"
$ArtifactResourceType = "microsoft.devtestlab/labs/artifactsources/artifacts"

# Other resource types
$StorageAccountResourceType = "microsoft.storage/storageAccounts"

# The API version required to query DTL resources
$RequiredApiVersion = "2015-05-21-preview"

##################################################################################################

#
# Private helper methods
#

function GetLabFromVM_Private
{
    Param(
        [ValidateNotNull()]
        # An existing VM (please use the Get-AzureDtlVirtualMachine cmdlet to get this VM object).
        $VM
    )

    $vm = GetResourceWithProperties_Private -Resource $VM

    $lab = Get-AzureRmResource | Where-Object {
        $_.ResourceType -eq $LabResourceType -and 
        $_.ResourceId -eq $vm.Properties.LabId
    }

    if ($null -eq $lab)
    {
        throw $("Unable to detect lab for VM '" + $VM.ResourceName + "'")
    }

    return $lab
}

function GetLabFromVhd_Private
{
    Param(
        [ValidateNotNull()]
        # An existing Vhd (please use the Get-AzureDtlVhd cmdlet to get this vhd object).
        $Vhd
    )

    if (($null -eq $Vhd) -or ($null -eq $Vhd.Context) -or ($null -eq $Vhd.Context.StorageAccountName))
    {
        throw $("Unable to determine the storage account name for the vhd '" + $Vhd.Name + "'.")
    }

    $vhdStorageAccount = Get-AzureRmResource | Where-Object {
        $_.ResourceType -eq $StorageAccountResourceType -and 
        $_.ResourceName -eq $Vhd.Context.StorageAccountName
    }

    if ($null -eq $vhdStorageAccount)
    {
        throw $("Unable to extract the storage account '" + $Vhd.Context.StorageAccountName + "'")
    }

    # Note: The -ErrorAction 'SilentlyContinue' ensures that we suppress irrelevant
    # errors originating while expanding properties (especially in internal test and
    # pre-production subscriptions).
    $lab = Get-AzureRmResource -ExpandProperties -ErrorAction "SilentlyContinue" | Where-Object {
        $_.ResourceType -eq $LabResourceType -and
        $_.Properties.DefaultStorageAccount -eq $vhdStorageAccount.ResourceId
    }

    if ($null -eq $lab)
    {
        throw $("Unable to detect lab for Vhd '" + $Vhd.Name + "'")
    }

    return $lab
}

function GetDefaultStorageAccountContextFromLab_Private
{
    Param(
        [ValidateNotNull()]
        # An existing Lab (please use the Get-AzureDtlLab cmdlet to get this lab object).
        $Lab
    )

    $lab = GetResourceWithProperties_Private -Resource $Lab

    # Get the default storage account associated with the lab.
    $labStorageAccount = Get-AzureRmResource | Where-Object {
        $_.ResourceType -eq $StorageAccountResourceType -and 
        $_.ResourceId -eq $lab.Properties.DefaultStorageAccount
    }

    if ($null -eq $labStorageAccount)
    {
        throw $("Unable to extract the default storage account for lab '" + $Lab.Name + "'")
    }

    # Extracting the lab's storage account key
    $labStorageAccountKey = Get-AzureRmStorageAccountKey -ResourceGroupName $labStorageAccount.ResourceGroupName -Name $labStorageAccount.ResourceName

    if ($null -eq $labStorageAccountKey)
    {
        throw $("Unable to extract the storage account key for lab '" + $Lab.Name + "'")
    }

    # Create a new storage context using the lab's default storage account .
    $labStorageAccountContext = New-AzureStorageContext -StorageAccountName $labStorageAccount.ResourceName -StorageAccountKey $labStorageAccountKey.Key1

    if ($null -eq $labStorageAccountContext)
    {
        throw $("Unable to create a new storage account context for storage account '" + $labStorageAccount.ResourceName + "'")
    }

    return $labStorageAccountContext
}

function GetResourceWithProperties_Private
{
    Param(
        [ValidateNotNull()]
        # ResourceId of an existing Azure RM resource.
        $Resource
    )

    if ($null -eq $Resource.Properties)
    {
        Get-AzureRmResource -ExpandProperties -ResourceId $Resource.ResourceId -ApiVersion $RequiredApiVersion
    }
    else
    {
        return $Resource
    }
}

function CreateNewResourceGroup_Private
{
    Param(
        [ValidateNotNullOrEmpty()]
        [string]
        # Seed/Prefix for the new resource group name to be generated.
        $ResourceGroupSeedPrefixName,

        [ValidateNotNullOrEmpty()]
        [string]
        # Location where the new resource group will be generated.
        $Location
    )

    # Using the seed/prefix, we'll generate a unique random name for the resource group.
    # We'll then check if there is an existing resource group with the same name.
    do
    {
        # NOTE: Unfortunately the Get-AzureRmResourceGroup cmdlet throws a terminating error 
        # if the specified resource group name does not exist. So we'll use a try/catch block.
        try
        {
            $randomRGName = $($ResourceGroupSeedPrefixName + (Get-Random).ToString())
            $randomRG = Get-AzureRmResourceGroup -Name $randomRGName
        }
        catch [ArgumentException]
        {
            $randomRG = $null
        }
    }
    until ($null -eq $randomRG)

    return (New-AzureRmResourceGroup -Name $randomRGName -Location $Location)
}

function IsFileRemote_Private
{
    Param(
        [ValidateNotNullOrEmpty()] 
        [string] 
        #  The full path or Uri of a file.
        $FilePathOrUri
    )

    # Poor man's check for UNC paths
    if ($FilePathOrUri.StartsWith("\\"))
    {
        return $true
    }

    # Poor man's check for Uris.
    if ($FilePathOrUri.StartsWith("https://"))
    {
        return $true
    }

    # A more formal check for UNC paths
    $uri = New-Object -TypeName System.Uri -ArgumentList @($FilePathOrUri) 
    if (($null -ne $uri) -and ($true -eq $uri.IsUnc))
    {
        return $true
    }

    # Check for network-mapped drives
    $driveInfo = New-Object -TypeName System.IO.DriveInfo -ArgumentList @($FilePathOrUri)
    if (($null -ne $driveInfo) -and ($driveInfo.DriveType -eq [System.IO.DriveType]::Network))
    {
        return $true
    }
            
    # else just assume it is local
    return $false
}

function CopyVhdToLocalIfRemote_Private
{
    Param(
        [ValidateNotNullOrEmpty()] 
        [string] 
        # The full path a local or remote (available from a UNC share or a network-mapped drive) file.
        $VhdFilePathOrUri,

        [ValidateNotNullOrEmpty()] 
        [string] 
        # A local folder to which the source vhd will be copied. 
        $LocalStagingFolder
    )

    # check whether the file resides locally or is remote. 
    $isRemoteVhd = IsFileRemote_Private -FilePathOrUri $VhdFilePathOrUri

    # if this is a local vhd, then don't copy it to the local staging area
    if ($false -eq $isRemoteVhd)
    {
        Write-Verbose "This is a local vhd, hence won't be copied into the local staging area."
        return $VhdFilePathOrUri
    }

    # Pre-condition check
    if ($false -eq (Test-Path -Path $LocalStagingFolder))
    {
        throw $("The specified local staging folder '" + $LocalStagingFolder + "' does not exist.")
    }

    $vhdSourceFolder = Split-Path $VhdFilePathOrUri -Parent
    $vhdSourceFileName = Split-Path -Path $VhdFilePathOrUri -Leaf
    $vhdStagingPath = Join-Path -Path $LocalStagingFolder -ChildPath $vhdSourceFileName

    # let us copy the vhd to the local staging folder.
    Write-Warning $("Copying the vhd to local staging area '" + $vhdStagingPath + "' (Note: This can take a while)...")
    Write-Verbose $("Copying the vhd to local staging area.")
    Write-Verbose $("Source : " + $VhdFilePathOrUri)
    Write-Verbose $("Staging Destination : " + $vhdStagingPath)

    # let us measure the file copy time for instrumentation purposes.
    $stopWatch = [Diagnostics.Stopwatch]::StartNew()

    if ($true -eq $VhdFilePathOrUri.StartsWith("https://"))
    {
        # @Todo: Blob Uris are currently not supported. Will be fixed in a future update.
        throw "Blob Uris are currently not supported by this cmdlet."
    }
    else
    {
        Copy-Item -Path $VhdFilePathOrUri -Destination $vhdStagingPath -Force | Out-Null

        if ($false -eq $?)
        {
            throw "An error occurred while copying the vhd to staging folder."
        }
    }

    $stopWatch.Stop()
    Write-Verbose $("Successfully copied vhd to staging folder in " + $stopWatch.Elapsed.TotalSeconds + " seconds.")

    return $vhdStagingPath
}

##################################################################################################

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
        $LabLocation,

        [Parameter(Mandatory=$false, ParameterSetName="ListByLabId")] 
        [Parameter(Mandatory=$false, ParameterSetName="ListByLabName")] 
        [Parameter(Mandatory=$false, ParameterSetName="ListAllInResourceGroup")] 
        [Parameter(Mandatory=$false, ParameterSetName="ListAllInLocation")] 
        [Parameter(Mandatory=$false, ParameterSetName="ListAll")] 
        [switch]
        # Optional. If specified, fetches the properties of the lab(s).
        $ShowProperties
    )

    PROCESS
    {
        Write-Verbose $("Processing cmdlet '" + $PSCmdlet.MyInvocation.InvocationName + "', ParameterSet = '" + $PSCmdlet.ParameterSetName + "'")

        $output = $null

        switch($PSCmdlet.ParameterSetName)
        {
            "ListByLabId"
            {
                $output = Get-AzureRmResource | Where-Object { 
                    $_.ResourceType -eq $LabResourceType -and 
                    $_.ResourceId -eq $LabId 
                }
            }
                    
            "ListByLabName"
            {
                if ($PSBoundParameters.ContainsKey("LabResourceGroupName"))
                {
                    $output = Get-AzureRmResource | Where-Object { 
                        $_.ResourceType -eq $LabResourceType -and 
                        $_.ResourceName -eq $LabName -and 
                        $_.ResourceGroupName -eq $LabResourceGroupName 
                    }
                }
                else
                {
                    $output = Get-AzureRmResource | Where-Object { 
                        $_.ResourceType -eq $LabResourceType -and 
                        $_.ResourceName -eq $LabName 
                    }     
                }
            }

            "ListAllInResourceGroup"
            {
                $output = Get-AzureRmResource | Where-Object { 
                    $_.ResourceType -eq $LabResourceType -and 
                    $_.ResourceGroupName -eq $LabResourceGroupName 
                }
            }

            "ListAllInLocation"
            {
                $output = Get-AzureRmResource | Where-Object { 
                    $_.ResourceType -eq $LabResourceType -and 
                    $_.Location -eq $LabLocation 
                }
            }

            "ListAll" 
            {
                $output = Get-AzureRmResource | Where-Object { 
                    $_.ResourceType -eq $LabResourceType 
                }
            }
        }

        # now let us display the output
        if ($PSBoundParameters.ContainsKey("ShowProperties"))
        {
            foreach ($item in $output)
            {
                GetResourceWithProperties_Private -Resource $item | Write-Output
            }
        }
        else
        {
            $output | Write-Output
        }
    }
}

##################################################################################################

function Get-AzureDtlVMTemplate
{
    <#
        .SYNOPSIS
        Gets VM templates from a specified lab.

        .DESCRIPTION
        The Get-AzureDtlVMTemplate cmdlet does the following: 
        - Gets all VM templates from a lab, if the -Lab parameter is specified.
        - Gets all VM templates with matching name from a lab, if the -VMTemplateName and -Lab parameters are specified.
        - Gets a specific VM template, if the -VMTemplateId parameter is specified.

        .EXAMPLE
        $lab = $null

        $lab = Get-AzureDtlLab -LabName "MyLab1"
        Get-AzureDtlVMTemplate -Lab $lab

        Gets all VM templates from the lab "MyLab1".

        .EXAMPLE
        $lab = $null

        $lab = Get-AzureDtlLab -LabName "MyLab1"
        Get-AzureDtlVMTemplate -VMTemplateName "MyVMTemplate1" -Lab $lab

        Gets all VM templates with the name "MyVMTemplate1" from the lab "MyLab1".

        .EXAMPLE
        Get-AzureDtlVMTemplate -VMTemplateId "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/MyLabRG/providers/Microsoft.DevTestLab/labs/MyLab1/vmtemplates/MyVMTemplate1"
        Gets a specific VM template, identified by the specified resource-id.

        .INPUTS
        None. Currently you cannot pipe objects to this cmdlet (this will be fixed in a future version).  
    #>
    [CmdletBinding(DefaultParameterSetName="ListByVMTemplateName")]
    Param(
        [Parameter(Mandatory=$true, ParameterSetName="ListByVMTemplateId")] 
        [ValidateNotNullOrEmpty()]
        [string]
        # The ResourceId of the VM template (e.g. "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/MyLabRG/providers/Microsoft.DevTestLab/labs/MyLab1/vmtemplates/MyVMTemplate1").
        $VMTemplateId,

        [Parameter(Mandatory=$false, ParameterSetName="ListByVMTemplateName")] 
        [ValidateNotNullOrEmpty()]
        [string]
        # The name of the VM template 
        $VMTemplateName,

        [Parameter(Mandatory=$true, ParameterSetName="ListByVMTemplateName")] 
        [ValidateNotNull()]
        # An existing lab (please use the Get-AzureDtlLab cmdlet to get this lab object).
        $Lab,

        [Parameter(Mandatory=$false, ParameterSetName="ListByVMTemplateId")] 
        [Parameter(Mandatory=$false, ParameterSetName="ListByVMTemplateName")] 
        [switch]
        # Optional. If specified, fetches the properties of the VM template(s).
        $ShowProperties
    )

    PROCESS
    {
        Write-Verbose $("Processing cmdlet '" + $PSCmdlet.MyInvocation.InvocationName + "', ParameterSet = '" + $PSCmdlet.ParameterSetName + "'")

        $output = $null

        switch ($PSCmdlet.ParameterSetName)
        {
            "ListByVMTemplateId"
            {
                $output = Get-AzureRmResource -ResourceId $VMTemplateId -ApiVersion $RequiredApiVersion
            }

            "ListByVMTemplateName"
            {
                $output = Get-AzureRmResource -ResourceName $Lab.ResourceName -ResourceGroupName $Lab.ResourceGroupName -ResourceType $VMTemplateResourceType -ApiVersion $RequiredApiVersion

                if ($PSBoundParameters.ContainsKey("VMTemplateName"))
                {
                    $output = $output | Where-Object {
                        $_.Name -eq $VMTemplateName                        
                    }
                }
            }
        }

        # now let us display the output
        if ($PSBoundParameters.ContainsKey("ShowProperties"))
        {
            foreach ($item in $output)
            {
                GetResourceWithProperties_Private -Resource $item | Write-Output
            }
        }
        else
        {
            $output | Write-Output
        }
    }
}

##################################################################################################

function Get-AzureDtlArtifact
{
    <#
        .SYNOPSIS
        Gets artifacts from a specified lab.

        .DESCRIPTION
        The Get-AzureDtlArtifact cmdlet does the following: 
        - Gets all artifacts from a lab, if the -Lab parameter is specified.
        - Gets all artifacts from a specific artifact repo of a lab, if the -ArtifactSourceName and -Lab parameters are specified.
        - Gets all artifacts with matching name from a lab, if the -ArtifactName and -Lab parameters are specified.
        - Gets all artifacts with matching name from a specific artifact repo of a lab, if the -ArtifactName, -ArtifactSourceName and -Lab parameters are specified.
        - Gets a specific artifact, if the -ArtifactId parameter is specified.

        .EXAMPLE
        $lab = $null

        $lab = Get-AzureDtlLab -LabName "MyLab1"
        Get-AzureDtlArtifact -Lab $lab

        Gets all artifacts from the lab "MyLab1".

        .EXAMPLE
        $lab = $null

        $lab = Get-AzureDtlLab -LabName "MyLab1"
        Get-AzureDtlArtifact -Lab $lab -ArtifactSource "MyArtifactRepo1"

        Gets all artifacts from the artifact repo "MyArtifactRepo1" of the lab "MyLab1".

        .EXAMPLE
        $lab = $null

        $lab = Get-AzureDtlLab -LabName "MyLab1"
        Get-AzureDtlArtifact -ArtifactName "MyArtifact1" -Lab $lab

        Gets all artifacts with the name "MyArtifact1" from the lab "MyLab1".

        .EXAMPLE
        $lab = $null

        $lab = Get-AzureDtlLab -LabName "MyLab1"
        Get-AzureDtlArtifact -ArtifactName "MyArtifact1" -ArtifactSource "MyArtifactRepo1" -Lab $lab

        Gets all artifacts with the name "MyArtifact1" from the artifact repo "MyArtifactRepo1" of the lab "MyLab1".

        .EXAMPLE
        Get-AzureDtlArtifact -ArtifactId "/subscriptions/xxxxxxxx-xxxx-xxxx/resourceGroups/MyLabRG/providers/Microsoft.DevTestLab/labs/MyLab1/artifactSources/MyArtifactRepo1/artifacts/MyArtifact1"
        Gets a specific artifact, identified by the specified resource-id.

        .INPUTS
        None. Currently you cannot pipe objects to this cmdlet (this will be fixed in a future version).  
    #>
    [CmdletBinding(DefaultParameterSetName="ListByArtifactName")]
    Param(
        [Parameter(Mandatory=$true, ParameterSetName="ListByArtifactId")] 
        [ValidateNotNullOrEmpty()]
        [string]
        # The ResourceId of the artifact (e.g. "/subscriptions/xxxxxxxx-xxxx-xxxx/resourceGroups/MyLabRG/providers/Microsoft.DevTestLab/labs/MyLab1/artifactSources/MyArtifactRepo1/artifacts/MyArtifact1").
        $ArtifactId,

        [Parameter(Mandatory=$false, ParameterSetName="ListByArtifactName")] 
        [ValidateNotNullOrEmpty()]
        [string]
        # The name of the artifact
        $ArtifactName,

        [Parameter(Mandatory=$false, ParameterSetName="ListByArtifactName")] 
        [ValidateNotNullOrEmpty()]
        [string]
        # The name of the artifact source
        $ArtifactSourceName,

        [Parameter(Mandatory=$true, ParameterSetName="ListByArtifactName")] 
        [ValidateNotNull()]
        # An existing lab (please use the Get-AzureDtlLab cmdlet to get this lab object).
        $Lab,

        [Parameter(Mandatory=$false, ParameterSetName="ListByArtifactId")] 
        [Parameter(Mandatory=$false, ParameterSetName="ListByArtifactName")] 
        [switch]
        # Optional. If specified, fetches the properties of the artifact(s).
        $ShowProperties
    )

    PROCESS
    {
        Write-Verbose $("Processing cmdlet '" + $PSCmdlet.MyInvocation.InvocationName + "', ParameterSet = '" + $PSCmdlet.ParameterSetName + "'")

        $output = $null

        switch ($PSCmdlet.ParameterSetName)
        {
            "ListByArtifactId"
            {
                $output = Get-AzureRmResource -ResourceId $ArtifactId -ApiVersion $RequiredApiVersion
            }

            "ListByArtifactName"
            {
                $output = @()

                # first let us extract all the artifact sources associated with the lab.
                $artifactSources = Get-AzureRmResource -ResourceName $Lab.ResourceName -ResourceGroupName $Lab.ResourceGroupName -ResourceType $ArtifactSourceResourceType -ApiVersion $RequiredApiVersion 

                # we'll filter by artifact source name, if specified
                if ($PSBoundParameters.ContainsKey("ArtifactSourceName"))
                {
                    $artifactSources = $artifactSources | Where-Object {
                        $_.Name -eq $ArtifactSourceName
                    }
                }

                # then for each of the artifact sources, let us extract the artifacts themselves.
                foreach ($artifactSrc in $artifactSources)
                {
                    $artifacts = Get-AzureRmResource -ResourceName $($Lab.ResourceName + "/" + $artifactSrc.Name) -ResourceGroupName $Lab.ResourceGroupName -ResourceType $ArtifactResourceType -ApiVersion $RequiredApiVersion

                    # filter by artifact name, if specified
                    if ($PSBoundParameters.ContainsKey("ArtifactName"))
                    {
                        $artifacts = $artifacts | Where-Object {
                            $_.Name -eq $ArtifactName
                        }
                    }

                    # dump the individual artifacts into the output variable
                    foreach ($artifact in $artifacts)
                    {
                        $output += $artifact
                    }
                }
            }
        }

        # now let us display the output
        if ($PSBoundParameters.ContainsKey("ShowProperties"))
        {
            foreach ($item in $output)
            {
                GetResourceWithProperties_Private -Resource $item | Write-Output
            }
        }
        else
        {
            $output | Write-Output
        }
    }
}

##################################################################################################

function Get-AzureDtlVhd
{
    <#
        .SYNOPSIS
        Gets vhds from a specified lab.

        .DESCRIPTION
        The Get-AzureDtlVhd cmdlet does the following: 
        - Gets a specific vhd from a lab, if the -VhdName parameter is specified.
        - Gets a specific vhd from a lab, if the -VhdUri parameter is specified.
        - Gets all vhds from a lab, if the -Lab parameter is specified.

        .EXAMPLE 
        $lab = $null

        $lab = Get-AzureDtlLab -LabName "MyLab1"
        Get-AzureDtlVhd -VhdName "myVhd.vhd" -Lab $lab

        Gets a specific vhd "myVhd.vhd" from the lab "MyLab1".

        .EXAMPLE 
        $lab = $null

        $lab = Get-AzureDtlLab -LabName "MyLab1"
        Get-AzureDtlVhd -VhdAbsoluteUri "https://msdtlvmxxxxxx.blob.core.windows.net/uploads/myVhd.vhd" -Lab $lab

        Gets a specific vhd from the lab "MyLab1".

        .EXAMPLE
        $lab = $null

        $lab = Get-AzureDtlLab -LabName "MyLab1"
        Get-AzureDtlVhd -Lab $lab

        Gets all vhds from the lab "MyLab1".

        .INPUTS
        None. Currently you cannot pipe objects to this cmdlet (this will be fixed in a future version).  
    #>
    [CmdletBinding(DefaultParameterSetName="ListAllInLab")]
    Param(
        [Parameter(Mandatory=$true, ParameterSetName="ListByVhdName")] 
        [ValidateNotNullOrEmpty()]
        [string]
        # The name of the vhd 
        $VhdName,

        [Parameter(Mandatory=$true, ParameterSetName="ListByVhdUri")] 
        [ValidateNotNullOrEmpty()]
        [string]
        # The absolute uri of the vhd
        $VhdAbsoluteUri,

        [Parameter(Mandatory=$true, ParameterSetName="ListAllInLab")] 
        [Parameter(Mandatory=$true, ParameterSetName="ListByVhdName")] 
        [Parameter(Mandatory=$true, ParameterSetName="ListByVhdUri")] 
        [ValidateNotNull()]
        # An existing lab (please use the Get-AzureDtlLab cmdlet to get this lab object).
        $Lab
    )

    PROCESS
    {
        Write-Verbose $("Processing cmdlet '" + $PSCmdlet.MyInvocation.InvocationName + "', ParameterSet = '" + $PSCmdlet.ParameterSetName + "'")

        # Get the default storage account associated with the lab.
        Write-Verbose $("Extracting the context for the default storage account for lab '" + $Lab.Name + "'")
        $labStorageAccountContext = GetDefaultStorageAccountContextFromLab_Private -Lab $Lab
        Write-Verbose $("Successfully extracted the context for the default storage account for lab '" + $Lab.Name + "'")

        # Extract the 'uploads' container (which houses the vhds).
        Write-Verbose $("Extracting the 'uploads' container")
        $uploadsContainer = Get-AzureStorageContainer -Name "uploads" -Context $labStorageAccountContext

        if ($null -eq $uploadsContainer)
        {
            throw $("Unable to extract the 'uploads' container from the default storage account for lab '" + $Lab.Name + "'")
        }
        
        #
        $output = $null

        switch ($PSCmdlet.ParameterSetName)
        {
            "ListByVhdName"
            {
                if ($VhdName -notlike "*.vhd")
                {
                    $VhdName = $($VhdName + ".vhd")
                }

                $output = Get-AzureStorageBlob -Container $uploadsContainer.Name -Blob $VhdName -Context $labStorageAccountContext
            }

            "ListByVhdUri"
            {
                $output = Get-AzureStorageBlob -Container $uploadsContainer.Name -Context $labStorageAccountContext | Where-Object {
                    ($_.ICloudBlob -ne $null) -and 
                    ($_.ICloudBlob.Uri -ne $null) -and
                    ($_.ICloudBlob.Uri.AbsoluteUri -ne $null) -and
                    ($_.ICloudBlob.Uri.AbsoluteUri -eq $VhdAbsoluteUri) 
                }
            }

            "ListAllInLab"
            {
                $output = Get-AzureStorageBlob -Container $uploadsContainer.Name -Context $labStorageAccountContext
            }
        }

        # now let us display the output
        $output | Write-Output
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
        $VMLocation,

        [Parameter(Mandatory=$false, ParameterSetName="ListByVMId")] 
        [Parameter(Mandatory=$false, ParameterSetName="ListByVMName")] 
        [Parameter(Mandatory=$false, ParameterSetName="ListAllInLab")] 
        [Parameter(Mandatory=$false, ParameterSetName="ListAllInResourceGroup")] 
        [Parameter(Mandatory=$false, ParameterSetName="ListAllInLocation")] 
        [Parameter(Mandatory=$false, ParameterSetName="ListAll")] 
        [switch]
        # Optional. If specified, fetches the properties of the virtual machine(s).
        $ShowProperties
    )

    PROCESS
    {
        Write-Verbose $("Processing cmdlet '" + $PSCmdlet.MyInvocation.InvocationName + "', ParameterSet = '" + $PSCmdlet.ParameterSetName + "'")

        $output = $null

        switch($PSCmdlet.ParameterSetName)
        {
            "ListByVMId"
            {
                $output = Get-AzureRmResource | Where-Object { 
                    $_.ResourceType -eq $EnvironmentResourceType -and 
                    $_.ResourceId -eq $VMId 
                }
            }
                    
            "ListByVMName"
            {
                $output = Get-AzureRmResource | Where-Object { 
                    $_.ResourceType -eq $EnvironmentResourceType -and 
                    $_.ResourceName -eq $VMName 
                }                
            }

            "ListAllInLab"
            {
                $fetchedLabObj = Get-AzureDtlLab -LabName $LabName 

                if ($null -ne $fetchedLabObj -and $fetchedLabObj.Count -ne 0)
                {
                    if ($fetchedLabObj.Count > 1)
                    {
                        throw $("Multiple labs found with name '" + $LabName + "'")
                    }
                    else
                    {
                        write-Verbose $("Found lab : " + $fetchedLabObj.ResourceName) 
                        write-Verbose $("LabId : " + $fetchedLabObj.ResourceId) 

                        # Note: The -ErrorAction 'SilentlyContinue' ensures that we suppress irrelevant
                        # errors originating while expanding properties (especially in internal test and
                        # pre-production subscriptions).
                        $output = Get-AzureRmResource -ExpandProperties -ErrorAction "SilentlyContinue" | Where-Object { 
                            $_.ResourceType -eq $EnvironmentResourceType -and
                            $_.Properties.LabId -eq $fetchedLabObj.ResourceId
                        }
                    }
                }
            }

            "ListAllInResourceGroup"
            {
                $output = Get-AzureRmResource | Where-Object { 
                    $_.ResourceType -eq $EnvironmentResourceType -and 
                    $_.ResourceGroupName -eq $VMResourceGroupName 
                }             
            }

            "ListAllInLocation"
            {
                $output = Get-AzureRmResource | Where-Object { 
                    $_.ResourceType -eq $EnvironmentResourceType -and 
                    $_.Location -eq $VMLocation 
                }
            }

            "ListAll" 
            {
                $output = Get-AzureRmResource | Where-Object { 
                    $_.ResourceType -eq $EnvironmentResourceType 
                }
            }
        }

        # now let us display the output
        if ($PSBoundParameters.ContainsKey("ShowProperties"))
        {
            foreach ($item in $output)
            {
                GetResourceWithProperties_Private -Resource $item | Write-Output
            }
        }
        else
        {
            $output | Write-Output
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

        # Unique name for the deployment
        $deploymentName = [Guid]::NewGuid().ToString()

        # Folder location of VM creation script, the template file and template parameters file.
        $LabCreationTemplateFile = Join-Path $PSScriptRoot -ChildPath "azuredeploy.json"

        # Pre-condition check to ensure the RM template file exists.
        if ($false -eq (Test-Path -Path $LabCreationTemplateFile))
        {
            throw $("The RM template file could not be located at : '" + $LabCreationTemplateFile + "'")
        }
        else
        {
            Write-Verbose $("The RM template file was located at : '" + $LabCreationTemplateFile + "'")
        }

        # Check if there are any existing labs with same name in the current subscription
        $existingLabs = Get-AzureRmResource | Where-Object { 
            $_.ResourceType -eq $LabResourceType -and 
            $_.ResourceName -eq $LabName -and 
            $_.SubscriptionId -eq (Get-AzureRmContext).Subscription.SubscriptionId
        }

        # If none exist, then create a new one
        if ($null -eq $existingLabs -or 0 -eq $existingLabs.Count)
        {
            # Create a new resource group with a unique name (using the lab name as a seed/prefix).
            Write-Verbose $("Creating new resoure group with seed/prefix '" + $LabName + "' at location '" + $LabLocation + "'")
            $newResourceGroup = CreateNewResourceGroup_Private -ResourceGroupSeedPrefixName $LabName -Location $LabLocation
            Write-Verbose $("Successfully created new resoure group '" + $newResourceGroup.ResourceGroupName + "' at location '" + $newResourceGroup.Location + "'")
    
            # Create the lab in this resource group by deploying the RM template
            Write-Verbose $("Creating new lab '" + $LabName + "'")
            $rgDeployment = New-AzureRmResourceGroupDeployment -Name $deploymentName -ResourceGroupName $newResourceGroup.ResourceGroupName  -TemplateFile $LabCreationTemplateFile -newLabName $LabName 

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
            throw $("One or more labs with name '" + $LabName + "' already exist in the current subscription '" + (Get-AzureRmContext).Subscription.SubscriptionId + "'.")
        }
    }
}

##################################################################################################

function New-AzureDtlVMTemplate
{
    <#
        .SYNOPSIS
        Creates a new (or updates an existing) virtual machine template.

        .DESCRIPTION
        The New-AzureDtlVMTemplate cmdlet creates a new VM template from an existing VM or Vhd.
        - The VM template name can only include alphanumeric characters, underscores, hyphens and parantheses.
        - The new VM template is created in the same lab as the VM (or Vhd).
        - If a VM template with the same name already exists in the lab, then it is simply updated.

        .EXAMPLE
        $vm = $null

        $vm = Get-AzureDtlVirtualMachine -VMName "MyVM1"
        New-AzureDtlVMTemplate -SrcDtlVM $vm -DestVMTemplateName "MyVMTemplate1" -DestVMTemplateDescription "MyDescription"

        Creates a new VM Template "MyVMTemplate1" from the VM "MyVM1" (in the same lab as the VM).

        .EXAMPLE
        $lab = $null

        $lab = Get-AzureDtlLab -LabName "MyLab1"
        $vhd = Get-AzureDtlVhd -Lab $lab -VMName "MyVhd1.vhd"
        New-AzureDtlVMTemplate -SrcDtlVhd $vhd -DestVMTemplateName "MyVMTemplate1" -DestVMTemplateDescription "MyDescription"

        Creates a new VM Template "MyVMTemplate1" in the lab "MyLab1" using the vhd "MyVhd1.vhd" as the source.

        .EXAMPLE
        $lab = $null

        $lab = Get-AzureDtlLab -LabName "MyLab1"
        $image = Get-AzureRmVMImage -Location "west us" -PublisherName "microsoftwindowsserver" -Offer "windowsserver" -Skus "2016-Nano-Server" -Version "2016.0.15"
        New-AzureDtlVMTemplate -SrcAzureRmVMImage $image -DestLabName "MyLab1" -DestVMTemplateName "MyVMTemplate1" -DestVMTemplateDescription "MyDescription"

        Creates a new VM Template "MyVMTemplate1" in the lab "MyLab1" from the azure marketplace image "windowsserver" (sku = "2016-Nano-Server", version "2016.0.15").

        .INPUTS
        None.
    #>
    [CmdletBinding(DefaultParameterSetName="FromVM")]
    Param(
        [Parameter(Mandatory=$true, ParameterSetName="FromVM")]
        [ValidateNotNull()]
        # An existing lab VM from which the new lab VM template will be created (please use the Get-AzureDtlVirtualMachine cmdlet to get this lab VM object).
        $SrcDtlVM,

        [Parameter(Mandatory=$true, ParameterSetName="FromVhd")]
        [ValidateNotNull()]
        # An existing lab vhd from which the new lab VM template will be created (please use the Get-AzureDtlVhd cmdlet to get this lab vhd object).
        $SrcDtlVhd,

        [Parameter(Mandatory=$true, ParameterSetName="FromAzureRmVMImage")]
        [ValidateNotNull()]
        # An existing azure gallery image from which the new lab VM template will be created (please use the Get-AzureRmVMImage cmdlet to get this image object).
        $SrcAzureRmVMImage,

        [Parameter(Mandatory=$true, ParameterSetName="FromAzureRmVMImage")]
        [ValidateNotNullOrEmpty()]
        [string]
        # The name of the lab.
        $DestLabName,

        [Parameter(Mandatory=$true, ParameterSetName="FromVM")]
        [Parameter(Mandatory=$true, ParameterSetName="FromVhd")]
        [Parameter(Mandatory=$true, ParameterSetName="FromAzureRmVMImage")]
        [ValidateNotNullOrEmpty()]
        [string]
        # Name of the new lab VM template to be created.
        $DestVMTemplateName,

        [Parameter(Mandatory=$true, ParameterSetName="FromVM")]
        [Parameter(Mandatory=$true, ParameterSetName="FromVhd")]
        [Parameter(Mandatory=$true, ParameterSetName="FromAzureRmVMImage")]
        [ValidateNotNull()]
        [string]
        # Details about the new lab VM template being created.
        $DestVMTemplateDescription = ""
    )

    PROCESS
    {
        Write-Verbose $("Processing cmdlet '" + $PSCmdlet.MyInvocation.InvocationName + "', ParameterSet = '" + $PSCmdlet.ParameterSetName + "'")

        # @Todo: Pre-condition check for the VM template name
        
        # Encode the VM template name
        $VMTemplateNameEncoded = $DestVMTemplateName.Replace(" ", "%20")

        # Unique name for the deployment
        $deploymentName = [Guid]::NewGuid().ToString()

        # Copy the vhd file into the staging area if needed
        switch($PSCmdlet.ParameterSetName)
        {
            "FromVM"
            {
                # Get the same VM object, but with properties attached.
                $SrcDtlVM = GetResourceWithProperties_Private -Resource $SrcDtlVM

                # Pre-condition checks to ensure that VM is in a valid state.
                if (($null -ne $SrcDtlVM) -and ($null -ne $SrcDtlVM.Properties) -and ($null -ne $SrcDtlVM.Properties.ProvisioningState))
                {
                    if ("succeeded" -ne $SrcDtlVM.Properties.ProvisioningState)
                    {
                        throw $("The provisioning state of the VM '" + $SrcDtlVM.ResourceName + "' is '" + $SrcDtlVM.Properties.ProvisioningState + "'. Hence unable to continue.")
                    }
                }
                else
                {
                    throw $("The provisioning state of the VM '" + $SrcDtlVM.ResourceName + "' could not be determined. Hence unable to continue.")
                }

                # Pre-condition checks to ensure that we're able to extract the Resource Id of the compute VM.
                if (($null -eq $SrcDtlVM.Properties) -or ($null -eq $SrcDtlVM.Properties.Vms) -or ($null -eq $SrcDtlVM.Properties.Vms[0]) -or ($null -eq $SrcDtlVM.Properties.Vms[0].ComputeId) )
                {
                    throw $("Unable to determine the Resource Id of the compute VM '" + $SrcDtlVM.ResourceName + "'.")
                }

                # Folder location of VM creation script, the template file and template parameters file.
                $VMTemplateCreationTemplateFile = Join-Path $PSScriptRoot -ChildPath "..\201-dtl-create-vmtemplate-from-vm\azuredeploy.json" -Resolve

                # Pre-condition check to ensure the RM template file exists.
                if ($false -eq (Test-Path -Path $VMTemplateCreationTemplateFile))
                {
                    throw $("The RM template file could not be located at : '" + $VMTemplateCreationTemplateFile + "'")
                }
                else
                {
                    Write-Verbose $("The RM template file was located at : '" + $VMTemplateCreationTemplateFile + "'")
                }

                # Get the lab that contains the source VM
                $lab = GetLabFromVM_Private -VM $SrcDtlVM

                # Create the VM Template in the lab's resource group by deploying the RM template
                Write-Verbose $("Creating VM Template '" + $DestVMTemplateName + "' in lab '" + $lab.ResourceName + "'")
                $rgDeployment = New-AzureRmResourceGroupDeployment -Name $deploymentName -ResourceGroupName $lab.ResourceGroupName -TemplateFile $VMTemplateCreationTemplateFile -existingLabName $lab.ResourceName -existingVMResourceId $SrcDtlVM.Properties.Vms[0].ComputeId -templateName $VMTemplateNameEncoded -templateDescription $DestVMTemplateDescription
            }

            "FromVhd"
            {
                # Pre-condition checks to ensure that we're able to extract the uri of the vhd blob.
                if (($null -eq $SrcDtlVhd.ICloudBlob) -or ($null -eq $SrcDtlVhd.ICloudBlob.Uri) -or ($null -eq $SrcDtlVhd.ICloudBlob.Uri.AbsoluteUri))
                {
                    throw $("Unable to determine the absolute uri of the vhd '" + $SrcDtlVhd.Name + "'.")
                }

                # Folder location of VM creation script, the template file and template parameters file.
                $VMTemplateCreationTemplateFile = Join-Path $PSScriptRoot -ChildPath "..\201-dtl-create-vmtemplate-from-vhd\azuredeploy.json" -Resolve

                # Pre-condition check to ensure the RM template file exists.
                if ($false -eq (Test-Path -Path $VMTemplateCreationTemplateFile))
                {
                    throw $("The RM template file could not be located at : '" + $VMTemplateCreationTemplateFile + "'")
                }
                else
                {
                    Write-Verbose $("The RM template file was located at : '" + $VMTemplateCreationTemplateFile + "'")
                }

                # Get the lab that contains the source VM
                $lab = GetLabFromVhd_Private -Vhd $SrcDtlVhd

                # Create the VM Template in the lab's resource group by deploying the RM template
                Write-Verbose $("Creating VM Template '" + $DestVMTemplateName + "' in lab '" + $lab.ResourceName + "'")
                $rgDeployment = New-AzureRmResourceGroupDeployment -Name $deploymentName -ResourceGroupName $lab.ResourceGroupName -TemplateFile $VMTemplateCreationTemplateFile -existingLabName $lab.ResourceName -existingVhdUri $SrcDtlVhd.ICloudBlob.Uri.AbsoluteUri -templateName $VMTemplateNameEncoded -templateDescription $DestVMTemplateDescription
            }

            "FromAzureRmVMImage"
            {
                # Pre-condition checks to ensure that we're able to extract the properties of the azure gallery image.
                if (($null -eq $SrcAzureRmVMImage.PublisherName) -or ($null -eq $SrcAzureRmVMImage.Offer) -or ($null -eq $SrcAzureRmVMImage.Skus) -or ($null -eq $SrcAzureRmVMImage.Version))
                {
                    throw $("Unable to determine the properties of the specified azure gallery image '" + $SrcAzureRmVMImage.Name + "'.")
                }

                # Folder location of VM creation script, the template file and template parameters file.
                $VMTemplateCreationTemplateFile = Join-Path $PSScriptRoot -ChildPath "..\201-dtl-create-vmtemplate-from-azure-image\azuredeploy.json" -Resolve

                # Pre-condition check to ensure the RM template file exists.
                if ($false -eq (Test-Path -Path $VMTemplateCreationTemplateFile))
                {
                    throw $("The RM template file could not be located at : '" + $VMTemplateCreationTemplateFile + "'")
                }
                else
                {
                    Write-Verbose $("The RM template file was located at : '" + $VMTemplateCreationTemplateFile + "'")
                }

                # fetch the lab where the VM template should be created
                $lab = Get-AzureDtlLab -LabName $DestLabName 

                if ($null -eq $lab -or $lab.Count -eq 0)
                {
                    throw $("Unable to detect lab with name '" + $DestLabName + "'")
                }

                if ($lab.Count > 1)
                {
                    throw $("Multiple labs found with name '" + $DestLabName + "'")
                }

                write-Verbose $("Found lab : " + $lab.ResourceName) 
                write-Verbose $("LabId : " + $lab.ResourceId) 

                # Create the VM Template in the lab's resource group by deploying the RM template
                Write-Verbose $("Creating VM Template '" + $DestVMTemplateName + "' in lab '" + $lab.ResourceName + "'")
                $rgDeployment = New-AzureRmResourceGroupDeployment -Name $deploymentName -ResourceGroupName $lab.ResourceGroupName -TemplateFile $VMTemplateCreationTemplateFile -existingLabName $lab.ResourceName -imagePublisher $SrcAzureRmVMImage.PublisherName -imageOffer $SrcAzureRmVMImage.Offer -imageSku $SrcAzureRmVMImage.Skus -imageVersion $SrcAzureRmVMImage.Version -templateName $VMTemplateNameEncoded -templateDescription $DestVMTemplateDescription
            }
        }

        # fetch and output the newly created VM template. 
        if (($null -ne $rgDeployment) -and ($null -ne $rgDeployment.Outputs['vmTemplateId']) -and ($null -ne $rgDeployment.Outputs['vmTemplateId'].Value))
        {
            $vmTemplateId = $rgDeployment.Outputs['vmTemplateId'].Value
            Write-Verbose $("VMTemplateId : '" + $vmTemplateId + "'")

            Get-AzureRmResource -ResourceId $vmTemplateId -ApiVersion $RequiredApiVersion | Write-Output
        }
    }
}

##################################################################################################

function Add-AzureDtlVhd
{
    <#
        .SYNOPSIS
        Uploads a local or remote vhd into the specified lab.

        .DESCRIPTION
        The Add-AzureDtlVhd cmdlet uploads a vhd into a lab. The source vhd must reside on:
        - local drives (e.g. c:\somefolder\somefile.ext) OR
        - UNC shares (e.g. \\someshare\somefolder\somefile.ext) OR
        - Network mapped drives (e.g. net use z: \\someshare\somefolder && z:\somefile.ext). 

        If your source vhd is stored as blob in an Azure storage account, please use the Start-AzureDtlVhdCopy
        cmdlet instead.

        Please note that the vhd file must meet the following specific requirements (dictated by Azure):
        - Must be a Gen1 vhd file (and NOT a Gen2 vhdx file).
        - Fixed sized vhd (and NOT dynamically expanding vhd). 
        - Size must be less than 1023 GB. 
        - The vhd must be uploaded as a page blob (and NOT as a block blob).

        Other notes:
        - Vhds from local drives are: 
            - validated to ensure they meet the Azure requirements. 
            - If validation is successful, they are uploaded to the destination lab.
        - Vhds from UNC shares and network mapped drives too are validated. The vhd files are:
            - copied to a local staging (location is customizable via the -LocalStagingFolder parameter) and 
            - validated to ensure they meet the Azure requirements. 
            - If validation is successful, they are uploaded to the destination lab.

        .EXAMPLE
        $destLab = $null

        $destLab = Get-AzureDtlLab -LabName "MyLab"
        Add-AzureDtlVhd -SrcVhdPath "d:\myImages\MyOriginal.vhd" -DestLab $destLab -DestVhdName "MyRenamed.vhd"

        Uploads a local vhd "MyOriginal.vhd" into the lab "MyLab" as "MyRenamed.vhd".

        .EXAMPLE
        $destLab = $null

        $destLab = Get-AzureDtlLab -LabName "MyLab"
        Add-AzureDtlVhd -SrcVhdPath "\\MyShare\MyFolder\MyOriginal.vhd" -DestLab $lab 

        Uploads a vhd file "MyOriginal.vhd" from specified network share "\\MyShare\MyFolder" into the lab "MyLab". 

        .EXAMPLE
        $destLab = $null

        $destLab = Get-AzureDtlLab -LabName "MyLab"
        Add-AzureDtlVhd -SrcVhdPath "\\MyShare\MyFolder\MyOriginal.vhd" -DestLab $lab -LocalStagingFolder "f:\temp"

        Uploads a vhd file "MyOriginal.vhd" from specified network share "\\MyShare\MyFolder" into the lab "MyLab",
        using "f:\temp" as an intermediate staging folder.

        .INPUTS
        None. Currently you cannot pipe objects to this cmdlet (this will be fixed in a future version).  
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    Param(
        [Parameter(Mandatory=$true)] 
        [ValidateNotNullOrEmpty()]
        [string]
        # Full path to the vhd file (that'll be uploaded to the lab).
        # Note: Currently we only support vhds that are available from:
        # - local drives (e.g. c:\somefolder\somefile.ext)
        # - UNC shares (e.g. \\someshare\somefolder\somefile.ext).
        # - Network mapped drives (e.g. net use z: \\someshare\somefolder && z:\somefile.ext). 
        $SrcVhdPath,

        [Parameter(Mandatory=$true)] 
        [ValidateNotNull()]
        # An existing lab to which the vhd will be uploaded (please use the Get-AzureDtlLab cmdlet to get this lab object).
        $DestLab,

        [Parameter(Mandatory=$false)] 
        [string]
        # [Optional] The name that will be assigned to vhd once uploded to the lab.
        # The name should be in a "<filename>.vhd" format (E.g. "WinServer2012-VS2015.Vhd"). 
        $DestVhdName,

        [Parameter(Mandatory=$false)] 
        [ValidateNotNullOrEmpty()]
        [string]
        # [Optional] An intermediate, local folder to which the source vhd will be copied, prior to upload. 
        # All validation checks (dictated by Azure) will be run on the vhd here. 
        # Note: By default, the local staging folder used is '%USERPROFILE%\UploadVhdToDTL\Staging'.
        # Note: This parameters is ignored in case the source vhd resides on local drives.
        $LocalStagingFolder = $(Join-Path $env:USERPROFILE -ChildPath "UploadVhdToDTL\Staging"),

        [Parameter(Mandatory=$false)] 
        [ValidateScript({$_ -ge 1})]
        [int]
        # [Optional] The number of uploader threads to use.
        # Note: By default, the numer of uploader threads used is equal to the number of processors.  
        $NumThreads = $env:NUMBER_OF_PROCESSORS,

        [Parameter(Mandatory=$false)] 
        [switch]
        # [Optional] If specified, will overwrite any existing vhd with the same name in the lab.
        $OverWrite
    )

    PROCESS
    {
        Write-Verbose $("Processing cmdlet '" + $PSCmdlet.MyInvocation.InvocationName + "', ParameterSet = '" + $PSCmdlet.ParameterSetName + "'")

        # Check if the specified vhd actually exists
        if ($false -eq (Test-Path -Path $SrcVhdPath))
        {
            throw $("Specified vhd is not accessible: " + $SrcVhdPath)
        }

        # If the user has specified a name for the destination name, ensure that it is appended with ".vhd" extension. 
        if ([string]::IsNullOrEmpty($DestVhdName))
        {
            $DestVhdName = Split-Path -Path $SrcVhdPath -Leaf
        }
        else
        {
            if ($DestVhdName -notlike "*.vhd")
            {
                $DestVhdName = $($DestVhdName + ".vhd")
            }
        }

        # Create the local staging folder if it doesn't already exist
        if ($false -eq (Test-Path -Path $LocalStagingFolder))
        {
            New-Item -Path $LocalStagingFolder -ItemType directory | Out-Null
        }
        
        # If this is a remote vhd, then copy it to the local staging area 
        $vhdLocalPath = CopyVhdToLocalIfRemote_Private -VhdFilePathOrUri $SrcVhdPath -LocalStagingFolder $LocalStagingFolder

        # Get the context associated with the lab's default storage account.
        $destStorageAccountContext = GetDefaultStorageAccountContextFromLab_Private -Lab $DestLab

        # Extract the 'uploads' container (which houses the vhds).
        $destContainer = Get-AzureStorageContainer -Name "uploads" -Context $destStorageAccountContext

        if ($null -eq $destContainer)
        {
            throw $("Unable to extract the 'uploads' container from the default storage account of lab '" + $DestLab.Name + "'")
        }

        # Processing the -Confirm and -Whatif switches.
        if ($PSCmdlet.ShouldProcess($DestVhdName, "Add Vhd"))
        {
            # Compute the destination vhd uri. 
            $destVhdUri = $($destContainer.CloudBlobContainer.Uri.AbsoluteUri + "/" + $DestVhdName) 

            # Now upload the vhd to lab's container
            Write-Warning "Starting upload of vhd to lab (Note: This can take a while)..."
            Write-Verbose "Starting upload of vhd to lab (Note: This can take a while)..."
            Write-Verbose $("Source: " + $VhdLocalPath)
            Write-Verbose $("Destination: " + $destVhdUri)
        
            # let us measure the file upload time for instrumentation purposes.
            $stopWatch = [Diagnostics.Stopwatch]::StartNew()

            # Now upload the local vhd to the lab.
            Add-AzureRmVhd -Destination $destVhdUri -LocalFilePath $VhdLocalPath -ResourceGroupName $DestLab.ResourceGroupName -NumberOfUploaderThreads $NumThreads -OverWrite:$PSBoundParameters.ContainsKey("OverWrite") | Out-Null

            if ($false -eq $?)
            {
                throw "An error occurred while copying the vhd to the lab '" + $DestLab.Name + "'."
            }    

            $stopWatch.Stop()
            Write-Verbose $("Successfully uploaded vhd to the lab in " + $stopWatch.Elapsed.TotalSeconds + " seconds.")

            # fetch and return the vhd which was just uploaded
            Get-AzureDtlVhd -Lab $DestLab -VhdAbsoluteUri $destVhdUri | Write-Output
        }
    }
}

##################################################################################################

function Start-AzureDtlVhdCopy
{
    <#
        .SYNOPSIS
        Starts to copy a vhd from an Azure storage account into the specified lab.

        .DESCRIPTION
        The Add-AzureDtlVhd cmdlet starts a copy operation to upload a vhd into a lab. The source vhd 
        must reside:
        - as blobs in Azure storage containers.
        - as files on Azure file shares (currently not supported).

        If your source vhd is located on a local disk or a network share, please use the Add-AzureDtlVhd 
        cmdlet instead.

        Please note that the vhd file must meet the following specific requirements (dictated by Azure):
        - Must be a Gen1 vhd file (and NOT a Gen2 vhdx file).
        - Fixed sized vhd (and NOT dynamically expanding vhd). 
        - Size must be less than 1023 GB. 
        - The vhd must be uploaded as a page blob (and NOT as a block blob).

        Other notes:
        - Vhds from Azure storage containers are copied directly into the lab (without being staged and validated locally).  

        .EXAMPLE
        $lab = $null

        $lab = Get-AzureDtlLab -LabName "MyLab"
        $friendlyName = "AnExampleVHD.vhd"

        Start-AzureDtlVhdCopy -SrcVhdBlobName "MyOriginal.vhd" -SrcVhdContainerName "MyContainer1" -SrcVhdStorageAccountName "MyStorageAccount1" -SrcVhdStorageAccountKey "xxxxxxx" -DestLab $lab -DestVhdName "MyRenamed.vhd"

        Initiates copying of vhd file "MyOriginal.vhd" from the storage account "MyStorageAccount1" into the lab "MyLab" as "MyRenamed.vhd".

        .EXAMPLE
        $lab = $null

        $lab = Get-AzureDtlLab -LabName "MyLab"
        $friendlyName = "AnExampleVHD.vhd"

        Start-AzureDtlVhdCopy -SrcVhdBlobName "MyOriginal.vhd" -SrcVhdContainerName "MyContainer1" -SrcVhdStorageAccountName "MyStorageAccount1" -SrcVhdStorageAccountKey "xxxxxxx" -DestLab $lab -WaitForCompletion

        Initiates copying of vhd file "MyOriginal.vhd" from the storage account "MyStorageAccount1" into the lab "MyLab" and wait
        for the copy operation to fully complete.

        .INPUTS
        None. Currently you cannot pipe objects to this cmdlet (this will be fixed in a future version).  
    #>
    [CmdletBinding(DefaultParameterSetName="AddFromStorageContainer")]
    Param(
        [Parameter(Mandatory=$true, ParameterSetName="AddFromStorageContainer")] 
        [ValidateNotNullOrEmpty()]
        [string]
        # The name of the blob representing the vhd file (that'll be uploaded to the lab).
        $SrcVhdBlobName,

        [Parameter(Mandatory=$true, ParameterSetName="AddFromStorageContainer")] 
        [ValidateNotNullOrEmpty()]
        [string]
        # The name of the container representing the vhd file (that'll be uploaded to the lab).
        $SrcVhdContainerName,

        [Parameter(Mandatory=$true, ParameterSetName="AddFromStorageContainer")] 
        [ValidateNotNullOrEmpty()]
        [string]
        # The name of the storage account associated with the vhd file (that'll be uploaded to the lab).
        $SrcVhdStorageAccountName,

        [Parameter(Mandatory=$true, ParameterSetName="AddFromStorageContainer")] 
        [ValidateNotNullOrEmpty()]
        [string]
        # The key of the storage account associated with the vhd file (that'll be uploaded to the lab).
        $SrcVhdStorageAccountKey,

        [Parameter(Mandatory=$true, ParameterSetName="AddFromStorageContainer")] 
        [ValidateNotNull()]
        # An existing lab to which the vhd will be uploaded (please use the Get-AzureDtlLab cmdlet to get this lab object).
        $DestLab,

        [Parameter(Mandatory=$false, ParameterSetName="AddFromStorageContainer")] 
        [string]
        # [Optional] The name that will be assigned to vhd once uploded to the lab.
        # The name should be in a "<filename>.vhd" format (E.g. "WinServer2012-VS2015.Vhd"). 
        $DestVhdName,

        [Parameter(Mandatory=$false, ParameterSetName="AddFromStorageContainer")] 
        [ValidateScript({$_ -ge 1})]
        [int]
        # [Optional] The number of uploader threads to use.
        # Note: By default, the numer of uploader threads used is equal to the number of processors.  
        $NumThreads = $env:NUMBER_OF_PROCESSORS,

        [Parameter(Mandatory=$false, ParameterSetName="AddFromStorageContainer")] 
        [switch]
        # [Optional] If specified, will overwrite any existing vhd with the same name in the lab.
        $OverWrite,

        [Parameter(Mandatory=$false, ParameterSetName="AddFromStorageContainer")] 
        [switch]
        # [Optional] If specified, will wait for vhd copy operation to complete.
        # Note: If specified, then this cmdlet's output is the vhd object successfully copied into the lab.
        # Note: If specified, then this cmdlet's output is the vhd object partially copied into the lab.
        $WaitForCompletion
    )

    PROCESS 
    {
        Write-Verbose $("Processing cmdlet '" + $PSCmdlet.MyInvocation.InvocationName + "', ParameterSet = '" + $PSCmdlet.ParameterSetName + "'")

        # If the user has specified a name for the destination name, ensure that it is appended with ".vhd" extension. 
        if ([string]::IsNullOrEmpty($DestVhdName))
        {
            $DestVhdName = $SrcVhdBlobName
        }
        else
        {
            if ($DestVhdName -notlike "*.vhd")
            {
                $DestVhdName = $($DestVhdName + ".vhd")
            }
        }
        
        # Copy the vhd file into the staging area if needed
        switch($PSCmdlet.ParameterSetName)
        {
            "AddFromStorageContainer"
            {
                # Create a new storage context using the provided src storage account name and key.
                $srcStorageAccountContext = New-AzureStorageContext -StorageAccountName $SrcVhdStorageAccountName -StorageAccountKey $SrcVhdStorageAccountKey

                if ($null -eq $srcStorageAccountContext)
                {
                    throw $("Unable to create a new storage account context for storage account '" + $SrcVhdStorageAccountName + "'")
                }

                # Get the context associated with the lab's default storage account.
                $destStorageAccountContext = GetDefaultStorageAccountContextFromLab_Private -Lab $DestLab

                # Extract the 'uploads' container (which houses the vhds).
                $destContainer = Get-AzureStorageContainer -Name "uploads" -Context $destStorageAccountContext

                if ($null -eq $destContainer)
                {
                    throw $("Unable to extract the 'uploads' container from the default storage account of lab '" + $DestLab.Name + "'")
                }

                # Processing the -Confirm and -Whatif switches.
                if ($PSCmdlet.ShouldProcess($DestVhdName, "Add Vhd"))
                {
                    # check if the vhd with same name already exists in the lab.
                    $destVhdExists = ($null -ne (Get-AzureStorageBlob -Blob $DestVhdName -Container $destContainer.Name -Context $destStorageAccountContext -ErrorAction Ignore))

                    if ($destVhdExists -and ($false -eq $PSBoundParameters.ContainsKey("OverWrite")))
                    {
                        throw $("A vhd with the name '" + $DestVhdName + "' already exists in the lab '" + $DestLab.Name + "'. Please use the -OverWrite switch to overwrite it.")
                    }

                    # Compute the destination vhd uri. 
                    $destVhdUri = $($destContainer.CloudBlobContainer.Uri.AbsoluteUri + "/" + $DestVhdName) 

                    # copy the vhd to the lab.
                    Write-Verbose $("Copying the vhd to lab '" + $DestLab.Name + "'")
                    Write-Verbose $("Source blob: " + $SrcVhdBlobName)
                    Write-Verbose $("Source container: " + $SrcVhdBlobName)
                    Write-Verbose $("Source storage account: " + $SrcVhdBlobName)
                    Write-Verbose $("Destination blob: " + $DestVhdName)
                    Write-Verbose $("Destination container: " + $destContainer.Name)
                    Write-Verbose $("Destination storage account: " + $destStorageAccountContext.StorageAccountName)

                    $partiallyCopiedVhd = Start-AzureStorageBlobCopy -SrcBlob $SrcVhdBlobName -SrcContainer $SrcVhdContainerName -Context $srcStorageAccountContext -DestBlob $DestVhdName -DestContainer $destContainer.Name -DestContext $destStorageAccountContext -ConcurrentTaskCount $NumThreads -Force 

                    if ($false -eq $? -or $null -eq $partiallyCopiedVhd)
                    {
                        throw "An error occurred while copying the vhd to the lab '" + $DestLab.Name + "'."
                    }    

                    Write-Verbose $("Successfully initiated the copy of vhd '" + $SrcVhdBlobName + "' to lab '" + $DestLab.Name + "'.")

                    if($PSBoundParameters.ContainsKey("WaitForCompletion"))
                    {
                        Write-Warning $("Waiting for the vhd copy operation to complete (Note: This can take a while)...")

                        # let us measure the file copy time for instrumentation purposes.
                        $stopWatch = [Diagnostics.Stopwatch]::StartNew()

                        Get-AzureStorageBlobCopyState -Blob $DestVhdName -Container $destContainer.Name -Context $destStorageAccountContext -WaitForComplete | Out-Null

                        if ($false -eq $?)
                        {
                            throw "An error occurred while querying the copy-state of the uploaded vhd."
                        }    

                        $stopWatch.Stop()
                        Write-Verbose $("Successfully copied vhd to lab " + $stopWatch.Elapsed.TotalSeconds + " seconds.")

                        # fetch and return the vhd which was just uploaded
                        Get-AzureDtlVhd -Lab $DestLab -VhdAbsoluteUri $destVhdUri | Write-Output
                    }
                    else
                    {
                        $partiallyCopiedVhd | Write-Output
                    }
                }
            }
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
        $vmtemplate = Get-AzureDtlVMTemplate -Lab $lab -VMTemplateName "MyVMTemplate"
        New-AzureDtlVirtualMachine -VMName "MyVM" -VMSize "Standard_A4" -Lab $lab -VMTemplate $vmtemplate

        Creates a new VM "MyVM" from the VM template "MyVMTemplate" in the lab "MyLab".
        - No new user account is created during the VM creation.
        - We assume that the original VM template already contains a built-in user account.
        - We assume that this built-in account can be used to log into the VM after creation.

        .EXAMPLE
        $lab = $null

        $lab = Get-AzureDtlLab -LabName "MyLab"
        $vmtemplate = Get-AzureDtlVMTemplate -Lab $lab -VMTemplateName "MyVMTemplate"
        $secPwd = ConvertTo-SecureString -String "MyPwd" -AsPlainText -Force
        New-AzureDtlVirtualMachine -VMName "MyVM" -VMSize "Standard_A4" -Lab $lab -VMTemplate $vmtemplate -UserName "MyAdmin" -Password $secPwd

        Creates a new VM "MyVM" from the VM template "MyVMTemplate" in the lab "MyLab".
        - A new user account is created using the username/password combination specified.
        - This user account is added to the local administrators group. 

        .EXAMPLE
        $lab = $null

        $lab = Get-AzureDtlLab -LabName "MyLab"
        $vmtemplate = Get-AzureDtlVMTemplate -Lab $lab -VMTemplateName "MyVMTemplate"
        $sshKey = ConvertTo-SecureString -String "MyKey" -AsPlainText -Force
        New-AzureDtlVirtualMachine -VMName "MyVM" -VMSize "Standard_A4" -Lab $lab -VMTemplate $vmtemplate -UserName "MyAdmin" -SSHKey $sshKey

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
        [ValidateNotNull()]
        # An existing VM template which will be used to create the new VM (please use the Get-AzureDtlVmTemplate cmdlet to get this VMTemplate object).
        # Note: This VM template must exist in the lab identified via the '-LabName' parameter.
        $VMTemplate,

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

        # Get the same VM template object, but with properties attached.
        $VMTemplate = GetResourceWithProperties_Private -Resource $VMTemplate

        # Pre-condition checks for azure gallery images.
        if ("Gallery" -eq $VMTemplate.Properties.ImageType)
        {
            if ($false -eq (($PSBoundParameters.ContainsKey("UserName") -and $PSBoundParameters.ContainsKey("Password")) -or ($PSBoundParameters.ContainsKey("UserName") -and $PSBoundParameters.ContainsKey("SSHKey"))))
            {
                throw $("The specified VM template '" + $VMTemplate.Name + "' uses an Azure gallery image. Please specify either the -UserName and -Password parameters or the -UserName and -SSHKey parameters to use this VM template.")
            }
        }
        else
        {
            # Pre-condition checks for linux vhds.
            if ("linux" -eq $VMTemplate.Properties.OsType)
            {
                if ($false -eq (($PSBoundParameters.ContainsKey("UserName") -and $PSBoundParameters.ContainsKey("Password")) -or ($PSBoundParameters.ContainsKey("UserName") -and $PSBoundParameters.ContainsKey("SSHKey"))))
                {
                    throw $("The specified VM template '" + $VMTemplate.Name + "' uses a linux vhd. Please specify either the -UserName and -Password parameters or the -UserName and -SSHKey parameters to use this VM template.")
                }
            }

            # Pre-condition checks for windows vhds.
            else 
            {
                # Pre-condition checks for sysprepped Windows vhds.
                if ($true -eq $VMTemplate.Properties.SysPrep)
                {
                    if ($false -eq ($PSBoundParameters.ContainsKey("UserName") -and $PSBoundParameters.ContainsKey("Password")))
                    {
                        throw $("The specified VM template '" + $VMTemplate.Name + "' uses a sysprepped vhd. Please specify both the -UserName and -Password parameters to use this VM template.")
                    }
                }

                # Pre-condition checks for non-sysprepped Windows vhds.
                # Note: For non-sysprepped windows vhds we ignore the username and password and instead use the built-in account.
                else
                {
                    if ($true -eq ($PSBoundParameters.ContainsKey("UserName") -and $PSBoundParameters.ContainsKey("Password")))
                    {
                        Write-Warning $("The specified VM template '" + $VMTemplate.Name + "' uses a non-sysprepped vhd with a built-in account. The specified userame and password will not be used.")
                    }                    
                }
            }
        }


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


        # Create a new resource group with a unique name (using the VM name as a seed/prefix).
        Write-Verbose $("Creating new resoure group with seed/prefix '" + $VMName + "' at location '" + $Lab.Location + "'")
        $newResourceGroup = CreateNewResourceGroup_Private -ResourceGroupSeedPrefixName $VMName -Location $Lab.Location
        Write-Verbose $("Created new resource group '" + $newResourceGroup.ResourceGroupName + "' at location '" + $newResourceGroup.Location + "'")

        # Create the virtual machine in this lab by deploying the RM template
        Write-Verbose $("Creating new virtual machine '" + $VMName + "'")
        Write-Warning $("Creating new virtual machine '" + $VMName + "'. This may take a couple of minutes.")

        $rgDeployment = $null

        # Unique name for the deployment
        $deploymentName = [Guid]::NewGuid().ToString()

        switch($PSCmdlet.ParameterSetName)
        {
            "BuiltInUser"
            {
                $rgDeployment = New-AzureRmResourceGroupDeployment -Name $deploymentName -ResourceGroupName $newResourceGroup.ResourceGroupName -TemplateFile $VMCreationTemplateFile -newVMName $VMName -existingLabName $Lab.ResourceName -existingLabResourceGroupName $Lab.ResourceGroupName -newVMSize $VMSize -existingVMTemplateName $VMTemplate.Name
            }

            "UsernamePwd"
            {
                $rgDeployment = New-AzureRmResourceGroupDeployment -Name $deploymentName -ResourceGroupName $newResourceGroup.ResourceGroupName -TemplateFile $VMCreationTemplateFile -newVMName $VMName -existingLabName $Lab.ResourceName -existingLabResourceGroupName $Lab.ResourceGroupName -newVMSize $VMSize -existingVMTemplateName $VMTemplate.Name -userName $UserName -password $Password
            }

            "UsernameSSHKey"
            {
                $rgDeployment = New-AzureRmResourceGroupDeployment -Name $deploymentName -ResourceGroupName $newResourceGroup.ResourceGroupName -TemplateFile $VMCreationTemplateFile -newVMName $VMName -existingLabName $Lab.ResourceName -existingLabResourceGroupName $Lab.ResourceGroupName -newVMSize $VMSize -existingVMTemplateName $VMTemplate.Name -userName $UserName -sshKey $SSHKey  
            }
        }

        if (($null -ne $rgDeployment) -and ($null -ne $rgDeployment.Outputs['vmId']) -and ($null -ne $rgDeployment.Outputs['vmId'].Value))
        {
            Write-Verbose $("vm id : '" + $rgDeployment.Outputs['vmId'].Value + "'")

            Get-AzureRmResource -ResourceId $rgDeployment.Outputs['vmId'].Value | Write-Output
        }
    }
}

##################################################################################################

function Remove-AzureDtlVirtualMachine
{
    <#
        .SYNOPSIS
        Deletes specified virtual machines.

        .DESCRIPTION
        The Remove-AzureDtlVirtualMachine cmdlet does the following: 
        - Deletes a specific VM, if the -VMId parameter is specified.
        - Deletes all VMs with matching name, if the -VMName parameter is specified.
        - Deletes all VMs in a lab, if the -LabName parameter is specified.
        - Deletes all VMs in a resource group, if the -VMResourceGroup parameter is specified.
        - Deletes all VMs in a location, if the -VMLocation parameter is specified.
        - Deletes all VMs within current subscription, if no parameters are specified. 

        Warning: 
        - If multiple VMs match the specified conditions, all of them will be deleted. 
        - Please use the '-WhatIf' parameter to preview the VMs being deleted (without actually deleting them).
        - Please use the '-Confirm' parameter to pop up a confirmation dialog for each VM to be deleted.

        .EXAMPLE
        Remove-AzureDtlVirtualMachine -VMId "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/MyLabRG/providers/Microsoft.DevTestLab/environments/MyVM"
        Deletes a specific VM, identified by the specified resource-id.

        .EXAMPLE
        Remove-AzureDtlVirtualMachine -VMName "MyVM1"
        Deletes all VMs with the name "MyVM1".

        .EXAMPLE
        Remove-AzureDtlVirtualMachine -LabName "MyLab"
        Deletes all VMs within the lab "MyLab".

        .EXAMPLE
        Remove-AzureDtlVirtualMachine -VMResourceGroupName "MyLabRG"
        Deletes all VMs in the "MyLabRG" resource group.

        .EXAMPLE
        Remove-AzureDtlVirtualMachine -VMLocation "westus"
        Deletes all VMs in the "westus" location.

        .EXAMPLE
        Remove-AzureDtlVirtualMachine
        Deletes all VMs within current subscription (use the Select-AzureRmSubscription cmdlet to change the current subscription).

        .INPUTS
        None. Currently you cannot pipe objects to this cmdlet (this will be fixed in a future version).  
    #>
    [CmdletBinding(
        SupportsShouldProcess=$true,
        DefaultParameterSetName="DeleteAll")]
    Param(
        [Parameter(Mandatory=$true, ParameterSetName="DeleteByVMId")] 
        [ValidateNotNullOrEmpty()]
        [string]
        # The ResourceId of the VM (e.g. "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/MyLabRG/providers/Microsoft.DevTestLab/environments/MyVM").
        $VMId,

        [Parameter(Mandatory=$true, ParameterSetName="DeleteByVMName")] 
        [ValidateNotNullOrEmpty()]
        [string]
        # The name of the VM.
        $VMName,

        [Parameter(Mandatory=$true, ParameterSetName="DeleteAllInLab")] 
        [ValidateNotNullOrEmpty()]
        [string]
        # Name of the lab.
        $LabName,

        [Parameter(Mandatory=$true, ParameterSetName="DeleteAllInResourceGroup")] 
        [ValidateNotNullOrEmpty()]
        [string]
        # The name of the VM's resource group.
        $VMResourceGroupName,

        [Parameter(Mandatory=$true, ParameterSetName="DeleteAllInLocation")] 
        [ValidateNotNullOrEmpty()]
        [string]
        # The location of the VM.
        $VMLocation
    )

    PROCESS
    {
        Write-Verbose $("Processing cmdlet '" + $PSCmdlet.MyInvocation.InvocationName + "', ParameterSet = '" + $PSCmdlet.ParameterSetName + "'")

        $vms = $null

        # First step is to fetch the specified VMs.
        switch($PSCmdlet.ParameterSetName)
        {
            "DeleteByVMId"
            {
                $vms = Get-AzureDtlVirtualMachine -VMId $VMId
            }
                    
            "DeleteByVMName"
            {
                $vms = Get-AzureDtlVirtualMachine -VMName $VMName 
            }

            "DeleteAllInLab"
            {
                $vms = Get-AzureDtlVirtualMachine -LabName $LabName
            }

            "DeleteAllInResourceGroup"
            {
                $vms = Get-AzureDtlVirtualMachine -VMResourceGroupName $VMResourceGroupName 
            }

            "DeleteAllInLocation"
            {
                $vms = Get-AzureDtlVirtualMachine -VMLocation $VMLocation
            }

            "DeleteAll" 
            {
                $vms = Get-AzureDtlVirtualMachine
            }
        }

        # Next, for each VM... 
        foreach ($vm in $vms)
        {
            # Get the same VM object, but with properties attached.
            $vm = GetResourceWithProperties_Private -Resource $vm

            # Pop the confirmation dialog.
            if ($PSCmdlet.ShouldProcess($vm.ResourceName, "delete VM"))
            {
                Write-Warning $("Deleting VM '" + $vm.ResourceName + "' (Id = " + $vm.ResourceId + ") ...")
                Write-Verbose $("Deleting VM '" + $vm.ResourceName + "' (Id = " + $vm.ResourceId + ") ...")

                # Nuke the VM.
                $result = Remove-AzureRmResource -ResourceId $vm.ResourceId -Force

                if ($true -eq $result)
                {
                    Write-Verbose $("Successfully deleted VM '" + $vm.ResourceName + "' (Id = " + $vm.ResourceId + ") ...")
                }
            }
        }
    }
}

##################################################################################################
