# Jenkins and Spinnaker VM template

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fdcaro%2Fspinnakerhackfest%2Fmaster%2Fazuredeploy.json" target="_blank">
  <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fdcaro%2Fspinnakerhackfest%2Fmaster%2Fazuredeploy.json" target="_blank">
  <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template will allow the automated deployment of Jenkins + Spinnaker in two different VMs in Azure.  This guide uses the Azure-Cli 2.0.  Instructions to install/update to the latest version can be found [here](https://docs.microsoft.com/en-us/cli/azure/install-az-cli2).
 
In order to deploy here are the steps to follow: 

## A. Create a Service Principal
1. Run `az login` to login to your subscription
1. Run the script ./create_spn.sh passing in the name of your subscription as a parameter (-n parameter).  See script for usage documentation regarding optional parameters.
1. For more information or to follow manual steps, see [here](https://docs.microsoft.com/en-us/azure/container-service/container-service-kubernetes-service-principal#create-a-service-principal-in-azure-active-directory)

## B. Deploy Spinnaker and Jenkins VMs
Deploying with a browser on Azure portal 
1. Click the "Deploy to Azure" button. If you don't have an Azure subscription, you can follow instructions to signup for a free trial.
1. Enter a valid name for the Spinnaker VM and Jenkins VM, as well as a user name a password you will use for both.
1. Enter the client id and key for your service principal created above.

Deploying from the command line
1. Create a resource group: 

` az group create -n spinnakergroup -l westus `

1. Fill in the parameters in your copy of the ` azuredeploy.parameters.json ` file. The Spinnaker VM and Jenkins VM will use the same username and password. The client id and key for your service principal are the once that have been created above.
1. Deploy the solution with the following command: 

` az group deployment create -g spinnakergroup -n deploy --template-file ./azuredeploy.json --parameters @./azuredeploy.parameters.json `

**Note**: If you use a local parameters file, you must prefix the path with the '@' signe as indicated in the sample above.

## C. Unlock Jenkins
1. SSH to the JenkinsVM and run `sudo vim /var/lib/jenkins/secrets/initialAdminPassword` to get the initial password.
1. Navigate to 'http://jenkinsdnslabel.region.cloudapp.azure.com:8080' and enter the password to unlock Jenkins for the first time.
1. Follow prompts to install the default plugins and create a jenkins user **with the same parameters as the ones entered at the deployment of the VM**.

## D. Initialize Jenkins 
1. SSH to Jenkins and run the following command: ``/opt/azure_jenkins_config/init_jenkins.sh `` 
1. Open an ssh tunnel to your spinnaker host and access http://localhost:9000

