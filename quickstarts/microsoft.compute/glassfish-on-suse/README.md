# GlassFish on SUSE

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/glassfish-on-suse/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/glassfish-on-suse/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/glassfish-on-suse/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/glassfish-on-suse/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/glassfish-on-suse/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/glassfish-on-suse/CredScanResult.svg)

[![Deploy to Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fglassfish-on-suse%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fglassfish-on-suse%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fglassfish-on-suse%2Fazuredeploy.json) 

This template deploys GlassFish application server onto multiple load balanced SUSE Linux VMs. It is possible to select either OpenSUSE or SLES for the OS, and any release package associated with version 3 or 4 of GlassFish.

This template will deploy the following resources:

|Resource           |Properties                                                                                                                          |
|-------------------|------------------------------------------------------------------------------------------------------------------------------------|
|Virtual Network    |**Address prefix:** 10.0.0.0/16<br />**VM subnet:** 10.0.0.0/24                              |
|Load Balancer      |Two probes and two rules for TCP 8080 and TCP 4848                                                                                       |
|Public IP Addresses|Public IP attached to Load Balancer                                                |
|Network Security Group|Two inbound rules                                                |
|Storage Accounts   |One Storage Account                                                                                                                  |
|Virtual Machines   |User defined number of VMs|

### Generate SSH Keys

You'll need to generate a pair of SSH keys in order to provision this template.<br/>
If you are using a Windows computer, then you can download puttygen.exe to create a valid key pair. Alternativley, on a Linux or Mac, you can just use the ssh-keygen command.

### azuredeploy.Parameters.json File Explained

1.  glassfishVersion: The version of GlassFish that will be deployed
2.  glassfishRelease: The release package that will be deployed to all servers
3.  numberOfInstances: Number of VMs to deploy
4.  dnsNameforLBIP: A distinct Public DNS name used to reference the VM Load Balancer, for access to deployed applications
5.  adminUsername: Admin username for OS login
6.  glassfishAdminPassword: The password given to the default GlassFish 'admin' user
7.  sshPublicKey: The public key used to secure SSH access with each VM 

## Deploy Template

There are several ways in which you can deploy this template:

- This template can be deployed directly through the Azure Portal, by clicking the 'Deploy to Azure' button found at the top of this README.md file.

- You can also deploy this template via command line (using Azure PowerShell or the Azure CLI) using the scripts located in the root folder of the 'azure-quickstart-templates' repository. To achieve this, simply execute the script and pass in the folder name of this quickstart (glassfish-on-suse), as indicated by the following commands.

CLI
  ```
azure-group-deploy.sh -a 'glassfish-on-suse' -l <Location>
  ```
  
PowerShell
  ```
.\Deploy-AzureResourceGroup.ps1 -ResourceGroupLocation <Location> -ArtifactStagingDirectory 'glassfish-on-suse' 
  ```
 
- It is also possible to deploy this template by populating a local copy of the *azuredeploy.parameters.json* file and executing the following Resource Manager deployment commands with PowerShell or the xplat CLI.

CLI
  ```
   azure group create -n <ResourceGroupName> -l <Location>

   azure group deployment create -f https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/quickstarts/microsoft.compute/glassfish-on-suse/azuredeploy.json -e <PathToParamtersFile> -g <ResourceGroupName> -n <DeploymentName>
  ```
  
PowerShell
  ```
    New-AzureRMResourceGroup -Name <ResourceGroupName> -Location <Location>

    New-AzureRmResourceGroupDeployment -Name <DeploymentName> -DeploymentDebugLogLevel All -ResourceGroupName <ResourceGroupName> - TemplateFile https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/quickstarts/microsoft.compute/glassfish-on-suse/azuredeploy.json -TemplateParameterFile <PathToParamtersFile>
  ```

## Post-Deployment Operations

This template registers remote admin access, so post deployment it is possible to login to the admin area of each VM using the Load balancers DNS name and the 480(VM number) port.<br />
In addition it is possible to SSH into each VM using the public IP and the 500(VM number) port; a private key associated with the provided public ssh key is also required.

### Additional Configuration Options
 
You can configure additional settings per the official GlassFish documentation (https://glassfish.java.net/documentation.html).

### Important Note
 
This template only deploys a single storage account which is shared by all of the established VMs, creating a single point of failure with the storage. For critical environments, this template should be modified to use multiple storage accounts, spreading the VHDs across these extra accounts to ensure resilience. 


