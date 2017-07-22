# Azure Spinnaker [![Build Status](http://devops-ci.westcentralus.cloudapp.azure.com/job/qs/job/101-spinnaker/badge/icon)](http://devops-ci.westcentralus.cloudapp.azure.com/blue/organizations/jenkins/qs%2F101-spinnaker/activity)

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-spinnaker-existing-vnet%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-spinnaker-existing-vnet%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template allows you to deploy an instance of Spinnaker on a Linux Ubuntu 14.04 LTS VM to an existing Virtual Network. This will deploy a VM in the resource group location and return the FQDN of the VM. You will have to manually configure the instance to target a deployment environment.

## A. Deploy Spinnaker VM
1. Click the "Deploy to Azure" button. If you don't have an Azure subscription, you can follow instructions to signup for a free trial.
1. Enter a valid name for the VM, as well as a user name and [ssh public key](https://docs.microsoft.com/azure/virtual-machines/virtual-machines-linux-mac-create-ssh-keys) that you will use to login remotely to the VM via SSH.

## B. Login remotely to the VM via SSH
Once the VM has been deployed, note down the DNS Name generated in the Azure portal for the VM. To login:
- If you are using Windows, use Putty or any bash shell on Windows to login to the VM with the username and password you supplied.
- If you are using Linux or Mac, use Terminal to login to the VM with the username and password you supplied.

## C. Configure Spinnaker
In Azure, Spinnaker can target a Kubernetes cluster or VM Scale Sets.
- To target a Kubernetes cluster, follow instructions [here](https://aka.ms/azspinkubecreate) to deploy a Kubernetes cluster and [here](http://www.spinnaker.io/v1.0/docs/target-deployment-configuration#section-kubernetes) to configure Spinnaker.
- To target VM Scale Sets, follow instructions [here](http://www.spinnaker.io/v1.0/docs/target-deployment-configuration#section-azure) to configure Spinnaker.

## D. Setup SSH port forwarding
Once you have configured Spinnaker, you need to setup port forwarding to view the Spinnaker UI on your local machine. If you do not know the full DNS name of your instance, go to the Portal and find it in the deployment outputs here: `Resource Groups > {Resource Group Name} > Deployments > {Deployment Name, usually 'Microsoft.Template'} > Outputs`

### If you are using Windows:
Install Putty or use any bash shell for Windows (if using a bash shell, follow the instructions for Linux or Mac).

Run this command:
```
putty.exe -ssh -i <path to private key file> -L 9000:localhost:9000 -L 8084:localhost:8084 <User name>@<Public DNS name of instance you just created>
```

Or follow these manual steps:
1. Launch Putty and navigate to Change Settings > SSH > Tunnels
1. In the Options controlling SSH port forwarding window, enter 8084 for Source port. Then enter 127.0.0.1:8084 for the Destination. Click Add.
1. Repeat this process for port 9000
1. Navigate to 'Connection > SSH > Auth' and enter your private key file for authentication. For more information on using ssh keys with Putty, see [here](https://docs.microsoft.com/azure/virtual-machines/virtual-machines-linux-ssh-from-windows#create-a-private-key-for-putty).
1. Click Open to establish the connection.

### If you are using Linux or Mac:
Run this command:
```bash
ssh -i <path to private key file> -L 9000:localhost:9000 -L 8084:localhost:8084 <User name>@<Public DNS name of instance you just created>
```
> NOTE: Port 9000 and 8084 correspond to Spinnaker's deck and gate services, respectively.

## E. Connect to Spinnaker

1. After you have started your tunnel, navigate to http://localhost:9000/ on your local machine.
1. Check the [Troubleshooting Guide](http://www.spinnaker.io/docs/troubleshooting-guide) if you have any issues.

## Questions/Comments? azdevopspub@microsoft.com