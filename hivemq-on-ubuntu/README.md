# HiveMQ on Ubuntu

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FCalCof%2Fazure-quickstart-templates%2Fmaster%2Fhivemq-on-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FCalCof%2Fazure-quickstart-templates%2Fmaster%2Fhivemq-on-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template deploys a HiveMQ cluster across multiple load balanced Ubuntu Linux VMs. Before executing this ARM template, you must first obtain a license and download URL for HiveMQ. However, an evaluation license can be easily obtained by completing a simple online form at http://www.hivemq.com/downloads/
Upon successful completion of the form you will be presented with a distinct time-boxed download button which will allow you to download an evaluation version of HiveMQ. This download link must be provided as a parameter when deploying this template. 

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

1.  hiveMQDownloadURL: The download URL containing the HiveMQ deployment package
2.  numberOfInstances: Number of VMs to deploy
3.  dnsNameforLBIP: A distinct Public DNS name used to reference the VM Load Balancer, for access to deployed applications
4.  adminUsername: Admin username for OS login
5.  sshPublicKey: The public key used to secure SSH access with each VM 

## Deploy Template

There are several ways in which you can deploy this template:

- This template can be deployed directly through the Azure Portal, by clicking the 'Deploy to Azure' button found at the top of this README.md file.

- You can also deploy this template via command line (using Azure PowerShell or the Azure CLI) using the scripts located in the root folder of the 'azure-quickstart-templates' repository. To achieve this, simply execute the script and pass in the folder name of this quickstart (glassfish-on-suse), as indicated by the following commands.

CLI
  ```
azure-group-deploy.sh -a 'hivemq-on-ubuntu' -l <Location>
  ```
  
PowerShell
  ```
.\Deploy-AzureResourceGroup.ps1 -ResourceGroupLocation <Location> -ArtifactStagingDirectory 'hivemq-on-ubuntu' 
  ```
 
- It is also possible to deploy this template by populating a local copy of the *azuredeploy.parameters.json* file and executing the following Resource Manager deployment commands with PowerShell or the xplat CLI.

CLI
  ```
   azure group create -n <ResourceGroupName> -l <Location>

   azure group deployment create -f https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/hivemq-on-ubuntu/azuredeploy.json -e <PathToParamtersFile> -g <ResourceGroupName> -n <DeploymentName>
  ```
  
PowerShell
  ```
    New-AzureRMResourceGroup -Name <ResourceGroupName> -Location <Location>

    New-AzureRmResourceGroupDeployment -Name <DeploymentName> -DeploymentDebugLogLevel All -ResourceGroupName <ResourceGroupName> - TemplateFile https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/hivemq-on-ubuntu/azuredeploy.json -TemplateParameterFile <PathToParamtersFile>
  ```

## Post-Deployment Operations

This template registers all nodes within a HiveMQ cluster using default configuration settings and enables MQTT traffic over port 1883 (default MQTT port). It is obviously possible to modify the configuration of each node post deployment to better suite your individual needs.<br />
In addition it is possible to SSH into each VM using the public IP and the 220(VM number) port; a private key associated with the provided public ssh key is also required.

### Additional Configuration Options
 
You can configure additional settings per the official HiveMQ documentation (http://www.hivemq.com/docs/hivemq/latest/).

### Important Note
 
This template only deploys a single storage account which is shared by all of the established VMs, creating a single point of failure with the storage. For critical environments, this template should be modified to use multiple storage accounts, spreading the VHDs across these extra accounts to ensure resilience.
