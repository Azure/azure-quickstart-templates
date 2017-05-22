<html>
<h>
This template is Step2 of 3 templates to build and Automate Secure Production like deployment on Azure Cloud and utilize best practice for creating IaaS V2 Infrastructure on Azure.
</h>
It creates a 2 Ubuntu Linux VM's per in each subnet Web, App and DB.
It also creates  Availability Sets for VM pairs in respective subnets for HA
It provides option to deploy Chef Agent extensions as part of the deployment.

Note: After this Template is deployed, Please login to portal and assosiate Subnets with NSG's, in-future release we will include this task within ARM template. This will make all FW rules effective e.g Assosiate WebNSG with WebSubnet

This Template builds up-on Next Template as Step3 for building your Infrastructure on Azure

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fsrakesh28%2Fdemo-working%2Fmaster%2Fstep2-linuxvm%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

Below are Steps for End-to-End Deployment using  Azure CLI Instructions:

azure login

Username: "your org login"

Pass : "your org pass"

azure account list

azure account set "Your Account Name"


Step1) azure group create <resource group name> <resource group location> westus
ex : azure group create demo1 westus

Step2) azure group deployment create --template-uri https://raw.githubusercontent.com/srakesh28/azure-iaasv2-arm/master/step1-network/azuredeploy.json demo1

Step3) azure group deployment create --template-uri https://raw.githubusercontent.com/srakesh28/azure-iaasv2-arm/master/step2-linuxvm/azuredeploy.json demo1 (This Template)

Step4) azure group deployment create --template-uri https://raw.githubusercontent.com/srakesh28/azure-iaasv2-arm/master/step3-lb/azuredeploy.json demo1


</html>
