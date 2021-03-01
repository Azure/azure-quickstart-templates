# Continuous Deployment to VM Scale Sets or AKS

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/301-spinnaker-vmss-or-aks/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/301-spinnaker-vmss-or-aks/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/301-spinnaker-vmss-or-aks/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/301-spinnaker-vmss-or-aks/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/301-spinnaker-vmss-or-aks/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/301-spinnaker-vmss-or-aks/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2F301-spinnaker-vmss-or-aks%2Fazuredeploy.json" target="_blank">
  <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2F301-spinnaker-vmss-or-aks%2Fazuredeploy.json" target="_blank">
  <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true"/>
</a>

This template allows you to deploy and config a DevOps pipeline to a VM Scale Set in Azure by leveraging Spinnaker. The Spinnaker setup environment could be either a single VM or an AKS cluster, which depends on whether you provide the parameter of the AKS cluster that is provisioned in advance.

> NOTE: Both of below scenarios use SshPublicKey to provision VM and VMSS, the latter of which is the deployment target in the Spinnaker pipeline after installing Spinnaker. If you prefer to use Password instead of SshPublicKey, change the value of the parameter Authentication Type to 'password' and leave the value of the parameter SshPublicKey as empty.

# Scenario I - Setup Spinnaker on VM
A Jenkins instance and Spinnaker will be deployed on a Linux Ubuntu 16.04 LTS VM. The Jenkins instance will include a basic pipeline that checks out a [sample git repository](https://github.com/azure-devops/hello-karyon-rxnetty.git), builds the debian package, and pushes the package to an Aptly repository hosted on the VM. The Spinnaker instance will automatically be setup to listen to that Jenkins instance and to deploy VM Scale Sets.

## A. Deploy
1. Click the "Deploy to Azure" button. If you don't have an Azure subscription, you can follow instructions to signup for a free trial.
2. Enter a DNS name for the VM, as well as a user name and ssh public key that you will use to login remotely to the VM via SSH.
3. Enter a password. You will use this password and the above user name to login the Jenkins instance.
4. Enter the appId and appKey for your Service Principal (used by Spinnaker to dynamically manage resources). If you don't have a service principal, use the [Azure CLI 2.0](https://docs.microsoft.com/cli/azure/install-azure-cli) to create one (see [here](https://docs.microsoft.com/cli/azure/create-an-azure-service-principal-azure-cli?toc=%2fazure%2fazure-resource-manager%2ftoc.json) for more details):
    ```bash
    az login
    az account set --subscription <Subscription ID>
    az ad sp create-for-rbac --name "Spinnaker"
    ```
    > NOTE: You can run `az account list` after you login to get a list of subscription IDs for your account.
5. Leave the parameter of the AKS cluster name as empty, otherwise the flow is going to enter the scenario of installing Spinnaker on AKS.

## B. Deploy from the command line

1. Create a resource group: 
` az group create -n spinnakergroup -l westus `
2. Fill in the parameters in your copy of the ` azuredeploy.parameters.json ` file.
3. Deploy the solution with the following command: 
` az group deployment create -g spinnakergroup -n deploy --template-file ./azuredeploy.json --parameters @./azuredeploy.parameters.json `

  > Note: If you use a local parameters file, you must prefix the path with the '@' sign as indicated in the sample above.

## C. Setup SSH port forwarding
**By default the Jenkins instance is using the http protocol and in this template it listens on port 8082. Users shouldn't authenticate over unsecured protocols!**

You need to setup port forwarding to view the Jenkins and Spinnaker UI on your local machine. If you do not know the full DNS name of your instance, go to the Portal and find it in the deployment outputs here: `Resource Groups > {Resource Group Name} > Deployments > {Deployment Name, usually 'Microsoft.Template'} > Outputs`

### If you are using Windows:
Install Putty or use any bash shell for Windows (if using a bash shell, follow the instructions for Linux or Mac).

Run this command:
```
putty.exe -ssh -i <path to private key file> -L 8082:localhost:8082 -L 9000:localhost:9000 -L 8084:localhost:8084 <User name>@<Public DNS name of instance you just created>
```

Or follow these manual steps:
1. Launch Putty and navigate to 'Connection > SSH > Tunnels'
2. In the Options controlling SSH port forwarding window, enter 8082 for Source port. Then enter 127.0.0.1:8082 for the Destination. Click Add.
3. Repeat this process for port 9000 and 8084.
4. Navigate to 'Connection > SSH > Auth' and enter your private key file for authentication. For more information on using ssh keys with Putty, see [here](https://docs.microsoft.com/azure/virtual-machines/virtual-machines-linux-ssh-from-windows#create-a-private-key-for-putty).
1. Click Open to establish the connection.

### If you are using Linux or Mac:
Run this command:
```bash
ssh -i <path to private key file> -L 8082:localhost:8082 -L 9000:localhost:9000 -L 8084:localhost:8084 <User name>@<Public DNS name of instance you just created>
```
> NOTE: Port 8082 corresponds to your Jenkins instance. Port 9000 and 8084 correspond to Spinnaker's deck and gate services, respectively.

## D. Connect to Jenkins

1. After you have started your tunnel, navigate to http://localhost:8082/ on your local machine.
2. The instance should already be unlocked and your first account setup. Login with the credentials you specified when deploying the template.
3. Your Jenkins instance is now ready to use! You can access a read-only view by going to http://< Public DNS name of instance you just created >:8082.
4. Go to http://aka.ms/azjenkinsagents if you want to build/CI from this Jenkins master using Azure VM agents.

## E. Connect to Spinnaker 

1. After you have started your tunnel, navigate to http://localhost:9000/ on your local machine.
2. Documentation to create a sample pipeline is forthcoming.

# Scenario II - Setup Spinnaker on AKS
An AKS cluster should be prepared in advance. A VM will be provisioned then it will install Spinnaker on the provided AKS cluster. In this scenario, there is no Jenkins installed.

## A. Deploy
1. Click the "Deploy to Azure" button. If you don't have an Azure subscription, you can follow instructions to signup for a free trial.
2. Enter a DNS name for the VM, as well as a user name and ssh public key that you will use to login remotely to the VM via SSH.
3. Enter the appId and appKey for your Service Principal (These should be the ones used to provision your AKS cluster. This scenario is also going to use them for Spinnaker to dynamically manage resources).
4. Enter the name and the resource group of your AKS cluster.

## B. Deploy from the command line
The same as that in Scenario I.

## C. Setup SSH port forwarding
Similar as that in Scenario I, with the only difference of not having to forward port 8082 since there is no Jenkins installed in this scenario.

## D. Connect to Spinnaker
1. After you have started your tunnel connecting with the provisioned VM, navigate to http://localhost:9000/ on your local machine.
2. Documentation to create a sample pipeline is forthcoming.

# Questions/Comments? azurespinnaker@microsoft.com

