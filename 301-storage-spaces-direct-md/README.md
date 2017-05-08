# Use Managed Disks to Create a Storage Spaces Direct (S2D) Scale-Out File Server (SOFS) Cluster with Windows Server 2016
This template will create a Storage Spaces Direct (S2D) Scale-Out File Server (SOFS) cluster using Windows Server 2016 and Managed Disks in an existing VNET and Active Directory environment.

This template provisions and configures the following resources by default:

+   A Standard Storage Account for a Cloud Witness
+   An Azure Virtual Machine for each cluster node - both two-node and three-node clusters are supported
+	One Managed Availability Set for the cluster nodes
+   Managed Disk resources for OS disks
+   A variable number of Managed Disks resources for data disks, depending on total disk space provisioned
+   Azure VM Extensions for PowerShell DSC to configure the cluster, cluster resources and cluster-aware updating (CAU)
+   Azure VM Extensions for Microsoft Antimalware

To deploy the required Azure VNET and Active Directory infrastructure, if not already in place, you may use <a href="https://github.com/Azure/azure-quickstart-templates/tree/master/active-directory-new-domain-ha-2-dc">this template</a> to deploy the prerequisite infrastructure. 

Click the button below to deploy from the portal:

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F301-storage-spaces-direct-md%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F301-storage-spaces-direct-md%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

## Notes

+	The default settings for storage are to deploy using **premium storage**, which is **strongly** recommended for S2D performance.  When using Premium Storage, be sure to select a VM size (DS-series, GS-series) that supports Premium Storage.

+   The default Azure VM size setting is Standard_DS4 (v2) which is strongly recommended as a starting configuration for testing network IO performance for S2D and SOFS.  This default setting requires 16 cores of free quota to deploy.

+   The default settings deploy 2 data disks per storage node, but can be increased to up to 32 data disks per node.  When increasing # of data disks, be sure to select a VM size that can support the # of data disks you specify.

+ 	The images used to create this deployment are
    +   Windows Server 2016 Datacenter Edition - Server Core (Default)
	+ 	Windows Server 2016 Datacenter Edition

+	To successfully deploy this template, be sure that the subnet to which the storage nodes are being deployed already exists on the specified Azure virtual network, AND this subnet should be defined in Active Directory Sites and Services for the appropriate AD site in which the closest domain controllers are configured.

+ SPECIAL THANKS to <a href="https://github.com/mmarch">@mmarch</a> on code contributions for dynamic data disk selection nested templates!

## Deploying Sample Templates

You can deploy these samples directly through the Azure Portal or by using the scripts supplied in the root of the repo.

To deploy the sammple using the Azure Portal, click the **Deploy to Azure** button found above.

To deploy the sample via the command line (using [Azure PowerShell or the Azure CLI](https://azure.microsoft.com/en-us/downloads/)) you can use the scripts.

Simply execute the script and pass in the folder name of the sample you want to deploy.  For example:

```PowerShell
.\Deploy-AzureResourceGroup.ps1 -ResourceGroupLocation 'eastus' -ArtifactsStagingDirectory '[foldername]'
```
```bash
azure-group-deploy.sh -a [foldername] -l eastus -u
```
If the sample has artifacts that need to be "staged" for deployment (Configuration Scripts, Nested Templates, DSC Packages) then set the upload switch on the command.
You can optionally specify a storage account to use, if so the storage account must already exist within the subscription.  If you don't want to specify a storage account
one will be created by the script or reused if it already exists (think of this as "temp" storage for AzureRM).

```PowerShell
.\Deploy-AzureResourceGroup.ps1 -ResourceGroupLocation 'eastus' -ArtifactsStagingDirectory '301-storage-spaces-direct' -UploadArtifacts 
```
```bash
azure-group-deploy.sh -a '301-storage-spaces-direct' -l eastus -u
```

Tags: ``cluster, ha, storage spaces, storage spaces direct, S2D, windows server 2016, ws2016``
