# Continuous Deployment to Kubernetes [![Build Status](http://devops-ci.westcentralus.cloudapp.azure.com/job/qs/job/301-jenkins-acr-spinnaker-k8s/badge/icon)](http://devops-ci.westcentralus.cloudapp.azure.com/blue/organizations/jenkins/qs%2F301-jenkins-acr-spinnaker-k8s/activity)

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F301-jenkins-acr-spinnaker-k8s%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F301-jenkins-acr-spinnaker-k8s%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template allows you to deploy and configure a DevOps pipeline from an Azure Container Registry to a Kubernetes cluster. It deploys an instance of Jenkins on a Linux Ubuntu 14.04 LTS VM and an instance of Spinnaker on the same Kubernetes cluster that your pipeline will target.

The Jenkins instance will include a basic pipeline that checks out a user-provided git repository, builds the Docker container based on the Dockerfile at the root of the repo, and pushes the image to the provisioned Azure Container Registry. The Spinnaker instance will include a basic pipeline that is triggered by any new tag in the registry and deploys the image to the provisioned Kubernetes cluster.

> NOTE: The Spinnaker pipeline assumes your app is listening on port 8000. You can clone this template and modify the 'pipelinePort' variable in azuredepoy.json to target a different port.

## A. Deploy
1. Click the "Deploy to Azure" button. If you don't have an Azure subscription, you can follow instructions to signup for a free trial.
1. Enter a valid name for the VM, as well as a user name and [ssh public key](https://docs.microsoft.com/azure/virtual-machines/virtual-machines-linux-mac-create-ssh-keys) that you will use to login remotely to the VM via SSH.
1. Enter the appId and appKey for your Service Principal (used to access your ACR and by your Kubernetes cluster to dynamically manage resources). If you don't have a service principal, use the [Azure CLI 2.0](https://docs.microsoft.com/cli/azure/install-azure-cli) to create one (see [here](https://docs.microsoft.com/cli/azure/create-an-azure-service-principal-azure-cli?toc=%2fazure%2fazure-resource-manager%2ftoc.json) for more details):
    ```bash
    az login
    az account set --subscription <Subscription ID>
    az ad sp create-for-rbac --name "Spinnaker"
    ```
    > NOTE: You can run `az account list` after you login to get a list of subscription IDs for your account.
1. Leave the git repository as the [sample app](https://github.com/azure-devops/spin-kub-demo) or change it to target your own app's repository. The repo must have a Dockerfile in its root.
1. Leave the docker repository as the sample name or change it to the name you desire. A repo with this name will be created in your ACR.

## C. Setup SSH port forwarding
**By default the Jenkins instance is using the http protocol and listens on port 8080. Users shouldn't authenticate over unsecured protocols!**

You need to setup port forwarding to view the Jenkins and Spinnaker UI on your local machine. If you do not know the full DNS name of your instance, go to the Portal and find it in the deployment outputs here: `Resource Groups > {Resource Group Name} > Deployments > {Deployment Name, usually 'Microsoft.Template'} > Outputs`

### If you are using Windows:
Install Putty or use any bash shell for Windows (if using a bash shell, follow the instructions for Linux or Mac).

Run this command:
```
putty.exe -ssh -i <path to private key file> -L 8080:localhost:8080 -L 9000:localhost:9000 -L 8084:localhost:8084 -L 8001:localhost:8001 <User name>@<Public DNS name of instance you just created>
```

Or follow these manual steps:
1. Launch Putty and navigate to 'Connection > SSH > Tunnels'
1. In the Options controlling SSH port forwarding window, enter 8084 for Source port. Then enter 127.0.0.1:8084 for the Destination. Click Add.
1. Repeat this process for port 8080, 9000 and 8001.
1. Navigate to 'Connection > SSH > Auth' and enter your private key file for authentication. For more information on using ssh keys with Putty, see [here](https://docs.microsoft.com/azure/virtual-machines/virtual-machines-linux-ssh-from-windows#create-a-private-key-for-putty).
1. Click Open to establish the connection.

### If you are using Linux or Mac:
Run this command:
```bash
ssh -i <path to private key file> -L 8080:localhost:8080 -L 9000:localhost:9000 -L 8084:localhost:8084 -L 8001:localhost:8001 <User name>@<Public DNS name of instance you just created>
```
> NOTE: Port 8080 corresponds to your Jenkins instance. Port 9000 and 8084 correspond to Spinnaker's deck and gate services, respectively. Port 8001 is used to view the dashboard for your Kubernetes cluster - just run `kubectl proxy` on the VM before navigating to http://localhost:8001/ui on your local machine.

## D. Connect to Jenkins

1. After you have started your tunnel, navigate to http://localhost:8080/ on your local machine.
1. Unlock the Jenkins dashboard for the first time with the initial admin password. To get this token, SSH into the VM and run `sudo cat /var/lib/jenkins/secrets/initialAdminPassword`
1. Your Jenkins instance is now ready to use! You can access a read-only view by going to http://< Public DNS name of instance you just created >.
1. Go to http://aka.ms/azjenkinsagents if you want to build/CI from this Jenkins master using Azure VM agents.

## E. Connect to Spinnaker

1. After you have started your tunnel, navigate to http://localhost:9000/ on your local machine.
1. Navigate to 'Applications -> {Application Name} -> Pipelines' to see your pipeline. Follow steps [here](http://www.spinnaker.io/docs/kubernetes-source-to-prod#section-1-create-a-spinnaker-application) to create a pipeline manually.
1. Check the [Troubleshooting Guide](http://www.spinnaker.io/docs/troubleshooting-guide) if you have any issues.

## Questions/Comments? azdevopspub@microsoft.com