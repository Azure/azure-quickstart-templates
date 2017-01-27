# OpenShift Origin with Username / Password

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fopenshift-origin-rhel%2Fazuredeploy.json" target="_blank"><img src="http://azuredeploy.net/deploybutton.png"/></a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fopenshift-origin-rhel%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template deploys OpenShift Origin with basic username / password for authentication to OpenShift. You can select to use either CentOS or RHEL for the OS. It includes the following resources:

|Resource           |Properties                                                                                                                          |
|-------------------|------------------------------------------------------------------------------------------------------------------------------------|
|Virtual Network    |**Address prefix:** 10.0.0.0/16<br />**Master subnet:** 10.0.0.0/24<br />**Node subnet:** 10.0.1.0/24                               |
|Load Balancer      |2 probes and two rules for TCP 80 and TCP 443                                                                                       |
|Public IP Addresses|OpenShift Master public IP<br />OpenShift Router public IP attached to Load Balancer                                                |
|Storage Accounts   |2 Storage Accounts                                                                                                                  |
|Virtual Machines   |Single master<br />User-defined number of nodes<br />All VMs include a single attached data disk for Docker thin pool logical volume|

If you already have a Red Hat subscription and would like to deploy an OpenShift Container Platform (Enterprise) 3.3 cluster, please visit: https://github.com/haroldwongms/openshift-enterprise

### Generate SSH Keys

You'll need to generate a pair of SSH keys in order to provision this template. Ensure that you do not include a passcode with the private key. <br/>
If you are using a Windows computer, you can download puttygen.exe.  You will need to export to OpenSSH (from Conversions menu) to get a valid Private Key for use in the Template.<br/>
From a Linux or Mac, you can just use the ssh-keygen command.

### Create Key Vault to store SSH Private Key

You will need to create a Key Vault to store your SSH Private Key that will then be used as part of the deployment.

1. Create Key Vault using Powershell <br/>
  a.  Create new resource group: New-AzureRMResourceGroup -Name 'ResourceGroupName' -Location 'West US'<br/>
  b.  Create key vault: New-AzureRmKeyVault -VaultName 'KeyVaultName' -ResourceGroup 'ResourceGroupName' -Location 'West US'<br/>
  c.  Create variable with sshPrivateKey: $securesecret = ConvertTo-SecureString -String '[copy ssh Private Key here - including line feeds]' -AsPlainText -Force<br/>
  d.  Create Secret: Set-AzureKeyVaultSecret -Name 'SecretName' -SecretValue $securesecret -VaultName 'KeyVaultName'<br/>
  e.  Enable the Key Vault for Template Deployments: Set-AzureRmKeyVaultAccessPolicy -VaultName 'KeyVaultName' -ResourceGroupName 'ResourceGroupName' -EnabledForTemplateDeployment

2. Create Key Vault using Azure CLI - must be run from a Linux machine (can use Azure CLI container from Docker for Windows) or Mac<br/>
  a.  Create new Resource Group: azure group create \<name\> \<location\> <br/>
         Ex: [azure group create ResourceGroupName 'East US'] <br/>
  b.  Create Key Vault: azure keyvault create -u \<vault-name\> -g \<resource-group\> -l \<location\><br/>
         Ex: [azure keyvault create -u KeyVaultName -g ResourceGroupName -l 'East US'] <br/>
  c.  Create Secret: azure keyvault secret set -u \<vault-name\> -s \<secret-name\> --file \<private-key-file-name\><br/>
         Ex: [azure keyvault secret set -u KeyVaultName -s SecretName --file ~/.ssh/id_rsa <br/>
  d.  Enable the Key Vault for Template Deployments: azure keyvault set-policy -u \<vault-name\> --enabled-for-template-deployment true <br/>
         Ex: [azure keyvault set-policy -u KeyVaultName --enabled-for-template-deployment true] <br/>

### azuredeploy.Parameters.json File Explained

1.  _artifactsLocation: The base URL where artifacts required by this template are located
2.  masterVmSize: Select from one of the allowed VM sizes listed in the azuredeploy.json file
3.  nodeVmSize: Select from one of the allowed VM sizes listed in the azuredeploy.json file
4.  osImage: Select from CentOS or RHEL for the Operating System
5.  openshiftMasterHostName: Host name for the Master Node. Unique within your azure account
6.  openshiftMasterPublicIpDnsLabelPrefix: A unique Public DNS name to reference the Master Node by
7.  nodeLbPublicIpDnsLabelPrefix: A unique Public DNS name to reference the Node Load Balancer by.  Used to access deployed applications
8.  nodePrefix: prefix to be prepended to create host names for the Nodes. Unique within your azure account
9.  nodeInstanceCount: Number of Nodes to deploy
10. adminUsername: Admin username for both OS login and OpenShift login
11. adminPassword: Password for OpenShift login
12. sshPublicKey: Copy your SSH Public Key here
13. subscriptionId: Your Subscription ID<br/>
    a. PowerShell: get-AzureAccount
	b. Azure CLI: azure account show - Field is ID
14. keyVaultResourceGroup: The name of the Resource Group that contains the Key Vault
15. keyVaultName: The name of the Key Vault you created
16. keyVaultSecret: The Secret Name you used when creating the Secret
17. defaultSubDomainType: This will either be xipio (if you don't have your own domain) or custom if you have your own domain that you would like to use for routing
18. defaultSubDomain: The wildcard DNS name you would like to use for routing if you selected custom above.  If you selected xipio above, then this field will be ignored

## Deploy Template

Once you have collected all of the prerequisites for the template, you can deploy the template by populating the *azuredeploy.parameters.json* file and executing Resource Manager deployment commands with PowerShell or the xplat CLI.

### NOTE

The OpenShift Ansible playbook does take a while to run when using VMs backed by Standard Storage. VMs backed by Premium Storage are faster. If you want Premimum Storage, select a DS or GS series VM.
<hr />
Be sure to follow the OpenShift instructions to create the ncessary DNS entry for the OpenShift Router for access to applications.

## Post-Deployment Operations

This template creates an OpenShift user but does not make it a full OpenShift user.  To do that, please perform the following.

1. SSH in to master node
2. Execute the following command:

   ```sh
   sudo oadm policy add-cluster-role-to-user cluster-admin <user>
   ```
### Additional OpenShift Configuration Options
 
You can configure additional settings per the official [OpenShift Origin Documentation](https://docs.openshift.org/latest/welcome/index.html).

Few options you have

1. Deployment Output

  a. openshiftConsoleUrl the openshift console url<br/>
  b. openshiftMasterSsh  ssh command for master node<br/>
  c. openshiftNodeLoadBalancerFQDN node load balancer<br/>

  get the deployment output data

  a. portal.azure.com -> choose 'Resource groups' select your group select 'Deployments' and there the deployment 'Microsoft.Template'. As output from the deployment it contains information about the openshift console url, ssh command and load balancer url.<br/>
  b. With the Azure CLI : azure group deployment list &lt;resource group name> 

2. add additional users. you can find much detail about this in the openshift.org documentation under 'Cluster Administration' and 'Managing Users'. This installation uses htpasswd as the identity provider. To add more user ssh in to master node and execute following command:

   ```sh
   sudo htpasswd /etc/origin/master/htpasswd user1
   ```
  now this user can login with the 'oc' CLI tool or the openshift console url
