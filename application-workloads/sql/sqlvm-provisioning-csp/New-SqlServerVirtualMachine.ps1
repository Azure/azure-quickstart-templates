function New-SqlServerVirtualMachine()
{
    #<#
	#.Synopsis
	#	   Deploy a new SQL VM Datawarehouse server on Azure cloud solution. 
	#.Description
    #      Create Azure resource group if not present and deploy a new cloud service and virtual machine. 
    #      User can specify the SQL Server image name and SKU but the script will only create 
    #      SQL Server IaaS VM. If you provide an image not published by SQL Server, the
    #      deployment will fail. All virtual machines deployed are configured 
    #      for remote desktop. 
    #
	#.Parameter SubscriptionId
    #      SubscriptionId is the identifier of the subscription to use. 
	#.Parameter ResourceGroupName
	#      Azure resource group name. If this resource group exists, it will be used for the new VM deployment
    #.Parameter TemplatePath
    #      Virtual Machine CSM JSON file absolute path    
    #.Parameter TemplateStorage
    #      Azure stroage name to use for executing the template. This is a legacey parameter which Azure PowerShell SDK require but does not use.
    #.Parameter VmName
    #      Virtual Machine name. The name must be 15 character and all lowercase 
    #.Parameter VmSize
    #     Virtual Machine size. 
    #.Parameter VmLocation
    #     Virtual Machine deployment location 
    #.Parameter Username
    #     Virtual Machine username
    #.Parameter Password
    #     Virtual Machine password
    #.Parameter StorageName
    #     Virtual Machine service service name. If not is specified, then one will be create and the VM will be add to it. Otherwise, the provided service will be used
    #.Parameter StorageType
    #     Virtual Machine cloud storage type.
    #.Parameter VnetName
    #     Virtual Machine virtual network name 
    #.Parameter NetworkAddressSpace
    #     Virtual Machine virtual network address space 
    #.Parameter SubnetName      
    #     Virtual Machine virtual network subnet name 
    #.Parameter SubnetAddressPrefix
    #     Virtual Machine virtual network subnet address prefix
	##>
    param
    (
      [Parameter(Mandatory)]
      [string]$SubscriptionId,

      [Parameter(Mandatory)]
      [string]$ResourceGroupName,

      [Parameter(Mandatory)] 
      [string]$TemplatePath ,

      [Parameter(Mandatory)]
      [string]$VmName,

      [Parameter(Mandatory)]
      [string]$VmSize,
      
      [Parameter(Mandatory)]
      [string]$VmLocation,

      [Parameter(Mandatory)]
      [string]$Username,

      [Parameter(Mandatory)]
      [SecureString]$Password,

      [Parameter(Mandatory)]
      [string]$StorageName,

      [Parameter(Mandatory)]
      [string]$StorageType,

      [Parameter(Mandatory)]
      [string]$VnetName,

      [string]$NetworkAddressSpace,

      [Parameter(Mandatory)]
      [string]$SubnetName,

      [string]$SubnetAddressPrefix
    )


    Write-Host 'Selecting Azure Subscription...' -foregroundcolor Yellow

    # include helper functions
    . "$PSScriptRoot\Common.ps1"

    # validate virtual machine name is less than or equal to 15 characters and all lowercase
    if (($VmName.length -gt 15) -or ($VmName -cne $VmName.ToLower()))
    {
        Write-Output "The parameter 'ServiceName' should be 15 lowercase characters or less."
        return;
    }

    # Update current subscription
    Write-Host 'Selecting Azure Subscription...' $SubscriptionName -foregroundcolor Yellow
    SetupAzureResourceManagementSubscription -SubscriptionId $SubscriptionId



    # create the resource group if does not exists 
    try
    {
        # create new resource group
        Write-Host "Query resource group details '$ResourceGroupName' ..." -foregroundcolor Green


        # if the resource group does not exist, then it will return a non-terminating error. We check the error to catch and create the resource in the finally. 
        $error.Clear()

        Get-AzureResourceGroup -Name $ResourceGroupName
    }
    catch
    {
        Write-Warning ("Azure resource group query operation failed. Error details:" + $_)
    }
    finally
    {
        if ($error[0])
        {
            # reset the error state
            $error.Clear()

            Write-Host "Create resource group '$ResourceGroupName' ..." -foregroundcolor Yellow

            New-AzureResourceGroup  -Name $ResourceGroupName -Location $VmLocation

            $error.Clear()
            Get-AzureResourceGroup -Name $ResourceGroupName

            if ($error[0])
            {
                Write-Host "Failed to create resource group '$ResourceGroupName'!" -foregroundcolor Red
            }
            else
            {
                Write-Host "Created resource group '$ResourceGroupName'" -foregroundcolor Green
            }
        }
        else
        {
            Write-Host "Resource group '$ResourceGroupName' is already created!" -foregroundcolor Green
        }
    }

    # execute the deployment template
    try
    {
        $error.Clear()

        New-AzureResourceGroupDeployment -ResourceGroupName $ResourceGroupName `
                                         -TemplateFile $TemplatePath `
                                         -vmName $VmName `
                                         -vmSize $VmSize `
                                         -sqlImageOffer "SQL2014-WS2012R2" `
                                         -sqlImageSku "Enterprise" `
                                         -sqlImageVersion "latest" `
                                         -vmLocation $VmLocation `
                                         -username $Username `
                                         -password $Password `
                                         -storageName $StorageName `
                                         -storageType $StorageType `
                                         -vnetName $VnetName `
                                         -networkAddressSpace $NetworkAddressSpace `
                                         -subnetName $SubnetName `
                                         -subnetAddressPrefix $SubnetAddressPrefix `
                                         -Verbose
    }
    catch
    {
        Write-Warning ("Azure SQL Server deployment failed!! Error details:" + $_)
    }
    finally
    {
        if ($error[0])
        {
            Write-Host "SQL Server deployment under resource group '$ResourceGroupName' failed!!" -foregroundcolor Red
        }
        else
        {
            Write-Host "*****************************************************************************" -foregroundcolor Green
            Write-Host "Created SQL Server deployment under resource group '$ResourceGroupName'"       -foregroundcolor Green
            Write-Host "*****************************************************************************" -foregroundcolor Green
        }   
    }
}
