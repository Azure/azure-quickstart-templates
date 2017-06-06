# Jenkins to Azure Container Registry [![Build Status](http://devops-ci.westcentralus.cloudapp.azure.com/job/qs/job/201-jenkins-acr/badge/icon)](http://devops-ci.westcentralus.cloudapp.azure.com/blue/organizations/jenkins/qs%2F201-jenkins-acr/activity)

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-jenkins-acr%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-jenkins-acr%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

The template allows you to host an instance of Jenkins on a DS1_v2 size Linux Ubuntu 14.04 LTS VM in Azure. It will also create an Azure Container Registry and return the full registry URL.

You can optionally include a basic Jenkins pipeline that will checkout a user-provided git repository with a Dockerfile embedded and it will build and push the Docker container in the provisioned Azure Container Registry.

## A. Deploy an Azure Container Registry and a Jenkins VM with an embedded Docker build and publish pipeline
1. Click the "Deploy to Azure" button. If you don't have an Azure subscription, you can follow instructions to signup for a free trial.
1. Enter the desired user name and password for the VM that's going to host the Jenkins instance. Also provide a DNS prefix for your VM.
1. Enter the appId and appKey for your Service Principal (used by the Jenkins pipeline to push the built docker container). If you don't have a service principal, use the [Azure CLI 2.0](https://docs.microsoft.com/cli/azure/install-azure-cli) to create one (see [here](https://docs.microsoft.com/cli/azure/create-an-azure-service-principal-azure-cli?toc=%2fazure%2fazure-resource-manager%2ftoc.json) for more details):
    ```bash
    az login
    az account set --subscription <Subscription ID>
    az ad sp create-for-rbac --name "Jenkins"
    ```
    > NOTE: You can run `az account list` after you login to get a list of subscription IDs for your account.
1. Enter a public git repository. The repository must have a Dockerfile in its root.

## B. Setup SSH port forwarding
**By default the Jenkins instance is using the http protocol and listens on port 8080. Users shouldn't authenticate over unsecured protocols!**

You need to setup port forwarding to view the Jenkins UI on your local machine. If you do not know the full DNS name of your instance, go to the Portal and find it in the deployment outputs here: `Resource Groups > {Resource Group Name} > Deployments > {Deployment Name, usually 'Microsoft.Template'} > Outputs`

### If you are using Windows:
Install Putty or use any bash shell for Windows (if using a bash shell, follow the instructions for Linux or Mac).

Run this command:
```
putty.exe -ssh -L 8080:localhost:8080 <User name>@<Public DNS name of instance you just created>
```

Or follow these manual steps:
1. Launch Putty and navigate to 'Connection > SSH > Tunnels'
1. In the Options controlling SSH port forwarding window, enter 8080 for Source port. Then enter 127.0.0.1:8080 for the Destination. Click Add.
1. Click Open to establish the connection.

### If you are using Linux or Mac:
Run this command:
```bash
ssh -L 8080:localhost:8080 <User name>@<Public DNS name of instance you just created>
```

## C. Connect to Jenkins

1. After you have started your tunnel, navigate to http://localhost:8080/ on your local machine.
1. Unlock the Jenkins dashboard for the first time with the initial admin password. To get this token, SSH into the VM and run `sudo cat /var/lib/jenkins/secrets/initialAdminPassword`
1. Your Jenkins instance is now ready to use! You can access a read-only view by going to http://< Public DNS name of instance you just created >.
1. Go to http://aka.ms/azjenkinsagents if you want to build/CI from this Jenkins master using Azure VM agents.

## Questions/Comments? azdevopspub@microsoft.com