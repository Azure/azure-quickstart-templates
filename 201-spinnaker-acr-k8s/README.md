# Azure Spinnaker to Kubernetes [DEPRECATED]

**IMPORTANT**: This template has been deprecated. Please use the [Azure Spinnaker](https://github.com/Azure/azure-quickstart-templates/tree/master/101-spinnaker) or [Continuous Deployment to Kubernetes](https://github.com/Azure/azure-quickstart-templates/tree/master/301-jenkins-acr-spinnaker-k8s) templates instead.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-spinnaker-acr-k8s%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-spinnaker-acr-k8s%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template allows you to deploy an instance of Spinnaker on a Linux Ubuntu 14.04 LTS VM automatically configured to target a Kubernetes cluster. This will deploy a D3_v2 size VM and a Kubernetes cluster in the resource group location and return the FQDN of both. It will also create an Azure Container Registry and return the full registry name.

> NOTE: The Spinnaker pipeline assumes your app is listening on port 8000. You can clone this template and modify the 'pipelinePort' variable in azuredepoy.json to target a different port.

## A. Deploy Spinnaker VM
1. Click the "Deploy to Azure" button. If you don't have an Azure subscription, you can follow instructions to signup for a free trial.
1. Enter a valid name for the Spinnaker VM, a user name, and a [ssh public key](https://docs.microsoft.com/azure/virtual-machines/virtual-machines-linux-mac-create-ssh-keys) that you will use to login remotely to both.
1. Enter the appId and appKey for your Service Principal (used to access your ACR and by your Kubernetes cluster to dynamically manage resources). If you don't have a service principal, use the [Azure CLI 2.0](https://docs.microsoft.com/cli/azure/install-azure-cli) to create one (see [here](https://docs.microsoft.com/cli/azure/create-an-azure-service-principal-azure-cli?toc=%2fazure%2fazure-resource-manager%2ftoc.json) for more details):
    ```bash
    az login
    az account set --subscription <Subscription ID>
    az ad sp create-for-rbac --name "Spinnaker"
    ```
    > NOTE: You can run `az account list` after you login to get a list of subscription IDs for your account.

## B. Setup SSH port forwarding
You need to setup port forwarding to view the Spinnaker UI on your local machine. If you do not know the full DNS name of your instance, go to the Portal and find it in the deployment outputs here: `Resource Groups > {Resource Group Name} > Deployments > {Deployment Name, usually 'Microsoft.Template'} > Outputs`

### If you are using Windows:
Install Putty or use any bash shell for Windows (if using a bash shell, follow the instructions for Linux or Mac).

Run this command:
```
putty.exe -ssh -i <path to private key file> -L 9000:localhost:9000 -L 8084:localhost:8084 -L 8001:localhost:8001 <User name>@<Public DNS name of instance you just created>
```

Or follow these manual steps:
1. Launch Putty and navigate to 'Connection > SSH > Tunnels'
1. In the Options controlling SSH port forwarding window, enter 8084 for Source port. Then enter 127.0.0.1:8084 for the Destination. Click Add.
1. Repeat this process for port 9000 and 8001.
1. Navigate to 'Connection > SSH > Auth' and enter your private key file for authentication. For more information on using ssh keys with Putty, see [here](https://docs.microsoft.com/azure/virtual-machines/virtual-machines-linux-ssh-from-windows#create-a-private-key-for-putty).
1. Click Open to establish the connection.

### If you are using Linux or Mac:
Run this command:
```bash
ssh -i <path to private key file> -L 9000:localhost:9000 -L 8084:localhost:8084 -L 8001:localhost:8001 <User name>@<Public DNS name of instance you just created>
```
> NOTE: Port 9000 and 8084 correspond to Spinnaker's deck and gate services, respectively. Port 8001 is used to view the dashboard for your Kubernetes cluster - just run `kubectl proxy` on the VM before navigating to http://localhost:8001/ui on your local machine.

## C. Connect to Spinnaker

1. After you have started your tunnel, navigate to http://localhost:9000/ on your local machine.
1. If you included a Kubernetes Pipeline when creating the template, navigate to 'Applications -> {Application Name} -> Pipelines' to see your pipeline. Follow steps [here](http://www.spinnaker.io/docs/kubernetes-source-to-prod#section-1-create-a-spinnaker-application) to create a pipeline manually.
1. You can trigger the pipeline by pushing an image with a new tag to the configured repository or simply clicking 'Start Manual Execution' and selecting an existing tag.
  1. By default, Spinnaker has been targeted to use the [repository](https://hub.docker.com/r/lwander/spin-kub-demo/) in the sample pipeline. Follow steps [here](http://www.spinnaker.io/v1.0/docs/target-deployment-configuration#section-docker-registry) to target different repositories.
  1. If your Kubernetes pipeline targets your Azure Container Registry, follow steps [here](https://docs.microsoft.com/azure/container-registry/container-registry-get-started-docker-cli) to push your first image. You can find the registry url in the portal at 'Resource Groups -> {Resource Group Name} -> Overview -> Deployments -> Microsoft.Template -> Outputs'.
1. Check the [Troubleshooting Guide](http://www.spinnaker.io/docs/troubleshooting-guide) if you have any issues.

## Questions/Comments? azdevopspub@microsoft.com