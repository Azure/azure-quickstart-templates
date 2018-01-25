# Continuous Deployment to VM Scale Sets [![Build Status](http://devops-ci.westcentralus.cloudapp.azure.com/job/qs/job/301-jenkins-aptly-spinnaker-vmss/badge/icon)](http://devops-ci.westcentralus.cloudapp.azure.com/blue/organizations/jenkins/qs%2F301-jenkins-aptly-spinnaker-vmss/activity)

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2F301-jenkins-aptly-spinnaker-vmss%2Fazuredeploy.json" target="_blank">
  <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2F301-jenkins-aptly-spinnaker-vmss%2Fazuredeploy.json" target="_blank">
  <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template allows you to deploy and configure a DevOps pipeline from an Aptly repository to a VM Scale Set in Azure. It deploys an instance of Jenkins and Spinnaker on a Linux Ubuntu 14.04 LTS VM.

The Jenkins instance will include a basic pipeline that checks out a [sample git repository](https://github.com/azure-devops/hello-karyon-rxnetty.git), builds the debian package, and pushes the package to an Aptly repository hosted on the VM. The Spinnaker instance will automatically be setup to listen to that Jenkins instance and to deploy VM Scale Sets.

## A. Deploy
1. Click the "Deploy to Azure" button. If you don't have an Azure subscription, you can follow instructions to signup for a free trial.
1. Enter a valid name for the VM, as well as a user name and password that you will use to login remotely to the VM via SSH and to the Jenkins instance.
1. Enter the appId and appKey for your Service Principal (used by Spinnaker to dynamically manage resources). If you don't have a service principal, use the [Azure CLI 2.0](https://docs.microsoft.com/cli/azure/install-azure-cli) to create one (see [here](https://docs.microsoft.com/cli/azure/create-an-azure-service-principal-azure-cli?toc=%2fazure%2fazure-resource-manager%2ftoc.json) for more details):
    ```bash
    az login
    az account set --subscription <Subscription ID>
    az ad sp create-for-rbac --name "Spinnaker"
    ```
    > NOTE: You can run `az account list` after you login to get a list of subscription IDs for your account.

Deploying from the command line

1. Create a resource group: 
` az group create -n spinnakergroup -l westus `
1. Fill in the parameters in your copy of the ` azuredeploy.parameters.json ` file.
1. Deploy the solution with the following command: 
` az group deployment create -g spinnakergroup -n deploy --template-file ./azuredeploy.json --parameters @./azuredeploy.parameters.json `

**Note**: If you use a local parameters file, you must prefix the path with the '@' sign as indicated in the sample above.

## C. Setup SSH port forwarding
**By default the Jenkins instance is using the http protocol and listens on port 8080. Users shouldn't authenticate over unsecured protocols!**

You need to setup port forwarding to view the Jenkins and Spinnaker UI on your local machine. If you do not know the full DNS name of your instance, go to the Portal and find it in the deployment outputs here: `Resource Groups > {Resource Group Name} > Deployments > {Deployment Name, usually 'Microsoft.Template'} > Outputs`

### If you are using Windows:
Install Putty or use any bash shell for Windows (if using a bash shell, follow the instructions for Linux or Mac).

Run this command:
```
putty.exe -ssh -i <path to private key file> -L 8080:localhost:8080 -L 9000:localhost:9000 -L 8084:localhost:8084 -L 8087:localhost:8087 <User name>@<Public DNS name of instance you just created>
```

Or follow these manual steps:
1. Launch Putty and navigate to 'Connection > SSH > Tunnels'
1. In the Options controlling SSH port forwarding window, enter 8084 for Source port. Then enter 127.0.0.1:8084 for the Destination. Click Add.
1. Repeat this process for port 8080, 9000 and 8087.
1. Navigate to 'Connection > SSH > Auth' and enter your private key file for authentication. For more information on using ssh keys with Putty, see [here](https://docs.microsoft.com/azure/virtual-machines/virtual-machines-linux-ssh-from-windows#create-a-private-key-for-putty).
1. Click Open to establish the connection.

### If you are using Linux or Mac:
Run this command:
```bash
ssh -i <path to private key file> -L 8080:localhost:8080 -L 9000:localhost:9000 -L 8084:localhost:8084 -L 8087:localhost:8087 <User name>@<Public DNS name of instance you just created>
```
> NOTE: Port 8080 corresponds to your Jenkins instance. Port 9000, 8084, and 8087 correspond to Spinnaker's deck, gate and rosco services, respectively.

## D. Connect to Jenkins

1. After you have started your tunnel, navigate to http://localhost:8080/ on your local machine.
1. The instance should already be unlocked and your first account setup. Login with the credentials you specified when deploying the template.
1. Your Jenkins instance is now ready to use! You can access a read-only view by going to http://< Public DNS name of instance you just created >.
1. Go to http://aka.ms/azjenkinsagents if you want to build/CI from this Jenkins master using Azure VM agents.

## E. Connect to Spinnaker 

1. After you have started your tunnel, navigate to http://localhost:9000/ on your local machine.
1. Documention to create a sample pipeline is forthcoming.

## Questions/Comments? azdevopspub@microsoft.com
