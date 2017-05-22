<html>
<h>
This template is Step3 of 3 templates to build and Automate Secure Production like deployment on Azure Cloud and utilize best practice for creating IaaS V2 Infrastructure on Azure.
</h>
It creates a Fronted LoadBalancer with a Public IP Address
Creates LB Rules and Associates with Web Subnet

Note: After deployment of this Template, Please login to Portal, Navigate to this LB and Add LB Probes and Load Balancing Rules and Associate Backend Address Pools to Web0 and Web1 VM's, In future these steps will be added to ARM Template.

This Template is the last step for building your Infrastructure on Azure

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fsrakesh28%2Fdemo-working%2Fmaster%2Fstep3-lb%2Fazuredeploy.json" target="_blank">
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

Step3) azure group deployment create --template-uri https://raw.githubusercontent.com/srakesh28/azure-iaasv2-arm/master/step2-linuxvm/azuredeploy.json demo1

Step4) azure group deployment create --template-uri https://raw.githubusercontent.com/srakesh28/azure-iaasv2-arm/master/step3-lb/azuredeploy.json  demo1 (This Template)

</html>
