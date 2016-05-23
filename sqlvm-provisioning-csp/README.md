# Create a SQL Server Virtual Machine on Azure CSP Subscription

Microsoft Azure has a new subscription offering, CSP Subscriptions. Some aspects of SQL VM deployment are not yet supported in CSP subscriptions. This includes the SQL IaaS Agent Extension, which is required for features such as SQL Automated Backup and SQL Automated Patching.

# Solution Overview

Deploying via powershell or portal ui
Requires the latest Azure PowerShell SDK http://azure.microsoft.com/en-us/downloads/

Click the button below to deploy from the portal

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsqlvm-provisioning-csp%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsqlvm-provisioning-csp%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

## Files Included

This solution includes 3 files required for deployment and 1 example powershell script to help with executing the PowerShell cmdlet:
+   Common.ps1
    A set of helper functions common in the implementation
+   New-SqlServerVirtualMachine.ps1
    The PowerShell function that handles deployment of the template
+   azuredeploy.json
    ARM CSM v2 template to deploy SQL Server in an Azure VM
+   CreateSQLVMExample.ps1
    Sample PowerShell script to help user execute the PowerShell cmdlet

## Deploying from PowerShell

For details on how to install and configure Azure Powershell see [here].(https://azure.microsoft.com/en-us/documentation/articles/powershell-install-configure/)

Before deploying via PowerShell there are a few steps you should follow:
+   Download the above files to the same location on your local machine
+   For each file, right click and open **Properties**, then deselect **Read-only** for each file. This will allow you to edit the files as needed.
+   Update the CreateSQLVMExample.ps1 file to fit your preferred input parameters

Launch an Azure PowerShell console

Log in to your Azure account

```PowerShell

Add-AzureAccount

```

Ensure that you are in Resource Manager Mode

```PowerShell

Switch-AzureMode AzureResourceManager

```

Change working folder to the folder containing these files.

If you have updated the CreateSQLVMExample.ps1 file, run that file to deploy the template with your desired specifications.

```PowerShell

./CreateSQLVMExample.ps1

```

## Additional Notes

+   Supported Images
    All public SQL images are supported, both OS and Platform images.
+   Public DNS IP Address
    A public DNS IP address is added to each VM created. The public DNS entry allows the remote desktop access.
+   Remote desktop
    Remote desktop will be enabled by default on all new Virtual Machines created
+   Public Endpoint
    The deployment does not create any public endpoint for any VM
+   Deploying on existing resources
    Azure CSM v2 supports existing resources by simply referencing them. Submit a request to create a resource that already exists, will result in success request. Therefore, there is no special handling. For example, if you submit info for an existing VM, but change the storage account information, this will update the existing VM to use that storage account.
+   Data Disks
    The template will not create data disks for OS images deployment. User can use the portal to add data disks after provisioning is complete. Platform images are created with preconfigured data disks.
+   Supported Deployment Locations
    This is provided as a parameter the user can provide at deployment time

## Supported Scenarios

+   New Virtual Machine Deployment Resources using OS Image
    Im this scenario, the following resources are created:
    +   Virtual Machine using OS image with no data disks
    +   public DNS entry
    +   Storage
    +   Virtual Network
    +   Subnet
+   Add Virtual Machine using OS image and existing storage
    In this scenario, the following resources are created:
    +   Virtual Machine using OS image with no data disks
    +   Public DNS Entry
    +   Virtual Network
    +   Subnet
+   Add Virtual Machine using OS Image and existing VNET / Subnet
    In this scenario, the following resources are created:
    +   Virtual Machine using OS image with no data disks
    +   Public DNS Entry
    +   Storage
+   Add Virtual Machine using OS Image to existing VNET / Subnet and Storage
    In this scenario, the following resources are created:
    +   Virtual Machine using OS image with no data disks
    +   Public DNS Entry
+   New Virtual Machine Deployment Resources using Platform Image
    In this scenario, the following resources are created:
    +   Virtual Machine using Platform image
    +   Public DNS Entry
    +   Storage
    +   Virtual Network
    +   Subnet
+   Add Virtual Machine using Platform Image and existing Storage
    In this scenario, the following resources are created:
    +   Virtual Machine using Platform Image
    +   Public DNS Entry
    +   Virtual Network
    +   Subnet
+   Add Virtual Machine using Platform Image and existing VNET / Subnet
    In this scenario, the following resources are created:
    +   Virtual Machine using Platform image
    +   Public DNS Entry
    +   Storage
+   Add Virtual Machine using Platform Image to existing VNET / Subnet and Storage
    In this scenario, the following resources are created:
    +   Virtual Machine using Platform image
    +   Public DNS Entry
