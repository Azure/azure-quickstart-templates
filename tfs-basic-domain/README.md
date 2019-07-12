# TFS - Single VM domain deployment

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Ftfs-basic-domain%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/> 
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Ftfs-basic-domain%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/> 
</a>

This template creates a self-contained single VM TFS deployment, including TFS, SQL Express, and a Domain Controller. It is meant to be used to evaluate TFS in Azure, not as a production deployment.

## After Deployment

The VM is created with a public IP. To access TFS you can RDP into the VM using that IP address and the username & password provided during the deployment. TFS will be available on port 8080 (e.g. http://vmName:8080/tfs)