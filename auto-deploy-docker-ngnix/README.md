# Auto deployment of an Ubuntu VM with Ngnix Docker container 

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fauto-deploy-docker-ngnix%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fauto-deploy-docker-ngnix%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template deploy an Ubuntu VM with Docker (using the Docker, and  custom-script Extension). The script will download HTML file(s), configure, and run Ngnix container.

![Diagram](/auto-deploy-docker-ngnix/images/Docker-in-Azure2.png "Complete diagram with external resources")

### Prerequisites

- Create a secure Azure acount Storage and have the access key.
- Edit the `mynginx.sh` script and change EXISTING_STORAGE_ACCOUNTNAME and  EXISTING_SCRIPT_STORAGE_ACCOUNT_KEY.


### The deployment

This solution can be deployed using  Azure-CLI.  Assuming the subscription name is `myproject` and that the resource group name is `frankdemo-rg` in the East US region here the commands to be ready for the deployment.

    # Login
    azure login

    # Set the working account to myproject
    azure account set myproject

    #Create a new Resource Group to deploy
    azure group create frankdemo-rg eastus

    # Deploy in the previously created RG
    azure group deployment create --template-uri https://frankdockerdemo.blob.core.windows.net/deploymentpublic/azuredeploy.json -e azuredeploy.parameters.json -g frankdemo-rg -v



### Notes

You can read more about all the steps on the blog post [Automating Docker Deployment with Azure Resource Manager](http://www.frankysnotes.com/2016/06/automating-docker-deployment-with-azure.html).