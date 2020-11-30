# ARM Template for Deploying Jenkins Master/Slave Cluster

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-multiple-windows-vms-with-common-script%2Fazuredeploy.json)

[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-multiple-windows-vms-with-common-script%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-multiple-windows-vms-with-common-script%2Fazuredeploy.json)   


![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/101-multiple-windows-vms-with-common-script/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/101-multiple-windows-vms-with-common-script/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/101-multiple-windows-vms-with-common-script/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/101-multiple-windows-vms-with-common-script/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/101-multiple-windows-vms-with-common-script/BestPracticeResult.svg)

![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/101-multiple-windows-vms-with-common-script/CredScanResult.svg)

# Deploying Multiple VMs (NOT VMSS) with Common custom script 

1.  Use parameter 'vmCount' to define number of VMs to be provisioned.

2.  Use parameter 'scriptFilename' to use any of following pre-defined scripts

    - container-lab.ps1
    - jenkins-java8.ps1
    - container-vs2019-lab.ps1
    - az500.ps1