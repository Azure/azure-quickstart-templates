# GlassFish on SUSE

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https://raw.githubusercontent.com/CalCof/azure-quickstart-templates/master/glassfish-on-suse/azuredeploy.json" target="_blank"><img src="http://azuredeploy.net/deploybutton.png"/></a>
<a href="http://armviz.io/#/?load=https://raw.githubusercontent.com/CalCof/azure-quickstart-templates/master/glassfish-on-suse/azuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

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

1.  _artifactsLocation: The base URL where artifacts required by this template are located
2.  glassfishVersion: The version of GlassFish that will be deployed
3.  glassfishRelease: The release package that will be deployed to all servers
4.  vmPrefix: Prefix used to create host names for all of the VMs
5.  numberOfInstances: Number of VMs to deploy
6.  dnsNameforLBIP: A distinct Public DNS name used to reference the VM Load Balancer, for access to deployed applications
7. lbName: The name given to the load balancer 
8. vmSize:  Select from one of the allowed VM sizes listed in the azuredeploy.json file
9. osImage: Select from OpenSUSE or SLES for the Operating System
10. adminUsername: Admin username for OS login
11. glassfishAdminPassword: The password given to the default GlassFish 'admin' user
12. sshPublicKey: The public key used to secure SSH access with each VM 


## Deploy Template

Once you have collected all of the prerequisites for the template, you can deploy the template by populating the *azuredeploy.parameters.json* file and executing Resource Manager deployment commands with PowerShell or the xplat CLI.

CLI
  ```
   azure group create -n <ResourceGroupName> -l <Location>

   azure group deployment create -f https://raw.githubusercontent.com/CalCof/azure-quickstart-templates/master/glassfish-on-suse/azuredeploy.json -e <PathToParamtersFile> -g <ResourceGroupName> -n <DeploymentName>
  ```
  
PowerShell
  ```
    New-AzureRMResourceGroup -Name <ResourceGroupName> -Location <Location>

    New-AzureRmResourceGroupDeployment -Name <DeploymentName> -DeploymentDebugLogLevel All -ResourceGroupName <ResourceGroupName> - TemplateFile https://raw.githubusercontent.com/CalCof/azure-quickstart-templates/master/glassfish-on-suse/azuredeploy.json -TemplateParameterFile <PathToParamtersFile>
  ```

## Post-Deployment Operations

This template registers remote admin access, so post deployment it is possible to login to the admin area of each VM using the Load balancers DNS name and the 480(VM number) port.<br />
In addition it is possible to SSH into each VM using the public IP and the 500(VM number) port; a private key associated with the provided public ssh key is also required.

### Additional Configuration Options
 
You can configure additional settings per the official GlassFish documentation (https://glassfish.java.net/documentation.html).

### Important Note
 
This template only deploys a single storage account which is shared by all of the established VMs, creating a single point of failure with the storage. For critical environments, this template should be modified to use multiple storage accounts, spreading the VHDs across these extra accounts to ensure resilience. 
