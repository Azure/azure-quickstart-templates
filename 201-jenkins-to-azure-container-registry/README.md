# Jenkins to Azure Container Registry

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-jenkins-to-azure-container-registry%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-jenkins-to-azure-container-registry%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

The template allows you to host an instance of Jenkins on a DS1_v2 size Linux Ubuntu 14.04 LTS VM in Azure. It will also create an Azure Container Registry and return the full registry URL.

You can optionally include a basic Jenkins pipeline that will checkout a user-provided git repository with a Dockerfile embedded and it will build and push the Docker container in the provisioned Azure Container Registry.

## A. Deploy a Jenkins VM and an Azure Container Registry
1. Click the "Deploy to Azure" button. If you don't have an Azure subscription, you can follow instructions to signup for a free trial.
1. Enter the desired user name and password for the VM that's going to host the Jenkins instance. Also provide a DNS prefix for your VM.
1. Pick 'Exclude' for the 'Push To ACR Pipeline' dropdown. You can ignore the rest of the fields

## B. Deploy an Azure Container Registry and a Jenkins VM with an embedded Docker build and publish pipeline
1. Follow all the steps from section A.
1. Pick 'Include' for the 'Push To ACR Pipeline' dropdown.
1. Create a [service principal](https://docs.microsoft.com/azure/container-service/container-service-kubernetes-service-principal#create-a-service-principal-in-azure-active-directory).
1. Fill in the service principal client id and secret. These will be used by the Jenkins pipeline to push the built docker container.
1. Enter a public git repository. The repository must have a Dockerfile in its root.

After the deployment is completed, get the Jenkins DNS from the “Public IP address/DNS name label” field in the Essentials section of your Jenkins VM in the Azure portal. You can now now browse to the Jenkins instance in your browser by going to http://< your_jenkins_vm_dns >:8080.

The first time you do this, you will be asked to get the login token from /var/lib/jenkins/secrets/initialAdminPassword. To get this token, SSH into the VM using the admin user name and password you provided and run: sudo cat /var/lib/jenkins/secrets/initialAdminPassword. Copy the token provided. Go back to the Jenkins instance in the browser and paste the token provided.

Your Jenkins instance is now ready to use! Go to http://aka.ms/azjenkinsagents if you want to build/CI from this Jenkins master using Azure VM agents.

## Questions/Comments? azdevopspub@microsoft.com