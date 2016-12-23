# CoScale Single VM Template : Setup the CoScale platform on a single VM.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fcoscale-dev-env%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fcoscale-dev-env%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

CoScale is a full-stack monitoring solution tailored towards production environments running microservices, see https://www.coscale.com/ for more information.
This template installs the CoScale platform on a single VM and should only be used for Proof-Of-Concept environments.

This template automatically creates all required objects, such as a storage account, virtual network, nic, load balancer, public ip.

The following parameters should be provided by the user:
* coscaleKey: a CoScale registration key that can be retrieved at https://www.coscale.com/azure/
* coscaleEmail: email address for the super user on your private CoScale instance
* coscalePassword: password for the super user on your private CoScale instance

Once the template finishes it will output the URL of your private CoScale instance.

##Install agent
This directory also contains a deploy-agent.sh script to deploy the CoScale agent on all VMs in a resource group.

##Limitations
- This single VM deployment should only be used for Proof-Of-Concept environments.
- There is no backup of the data that is collected using this setup.
- Since the created objects have fixed names they can be deployed only once per resource group.
