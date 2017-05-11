<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsap-hana-express%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsap-hana-express%2Fazuredeploy.json" target="_blank">
  <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template deploys a single virtual machine instance and installs SAP HANA Express and all required dependencies in this Virtual Machine. The Virtual Machine sizes are defined based on the requirements for SAP HANA Express. Before being able to deploy the template, you need to download the SAP HANA Express Setup packages from the SAP Homepage (scripts tested for HANA Express without XA-Advanced services).

-----------

Follow these steps to use this template:
----------------------------------------

1. Navigate to <https://www.sap.com/developer/topics/sap-hana-express.html>

2. Register for HANA Express and use the "Download Manager" Option as shown below:

3. Select the "Server only virtual machine" option and save the ".tgz" TAR-archive to your local machine.

4. Create a new Azure Resource Group, e.g. by using the Azure CLI as shown in the snippet below as part of the next bullet.

5. Execute the script "prep-hxe-setup-files.sh" shipping with this quick start template to upload the previously acquired (step 3 above) HANA Express Setup TAR archives to an Azure Storage Account and generate a Shared Access Signature for it:

    ```
    az group create --name "sampleresourcegroupname" --location "westeurope"

    ./prepare-hxe-setup-files.sh sampleresourcegroupname samplestorageaccountname samplecontainer westeurope /home/mydirectory/hxe.tgz
    ```

6. Deploy the template and specify the previously generated Shared Access Signature URL in the respective parameter "hxeSetupFileUrl" of the Azure Resource Manager Template Parameters File!