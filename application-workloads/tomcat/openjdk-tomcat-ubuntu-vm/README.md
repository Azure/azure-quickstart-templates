# VM-Ubuntu - Tomcat and Open JDK installation

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/tomcat/openjdk-tomcat-ubuntu-vm/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/tomcat/openjdk-tomcat-ubuntu-vm/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/tomcat/openjdk-tomcat-ubuntu-vm/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/tomcat/openjdk-tomcat-ubuntu-vm/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/tomcat/openjdk-tomcat-ubuntu-vm/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/tomcat/openjdk-tomcat-ubuntu-vm/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Ftomcat%2Fopenjdk-tomcat-ubuntu-vm%2Fazuredeploy.json) 
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Ftomcat%2Fopenjdk-tomcat-ubuntu-vm%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Ftomcat%2Fopenjdk-tomcat-ubuntu-vm%2Fazuredeploy.json)

This template allows you to create a Ubuntu VM with OpenJDK and Tomcat. 

This template deploys a **Linux VM Ubuntu** using the latest patched version. This will deploy a Standard_B2s size VM and a 18.04-LTS Version as defaultValue in the resource group location and will return the admin user name, Virtual Network Name, Network Security Group Name and FQDN.

The custom script file is pulled temporarily from java-tomcat-install.sh

Once the VM is successfully provisioned, tomcat installation can be verified by accessing the link http://<FQDN name or public IP>:8080/  

If you are new to Azure virtual machines, see:

- [Azure Virtual Machines](https://azure.microsoft.com/services/virtual-machines/).
- [Azure Linux Virtual Machines documentation](https://docs.microsoft.com/azure/virtual-machines/linux/)
- [Azure Windows Virtual Machines documentation](https://docs.microsoft.com/azure/virtual-machines/windows/)
- [Template reference](https://docs.microsoft.com/azure/templates/microsoft.compute/allversions)
- [Quickstart templates](https://azure.microsoft.com/resources/templates/?resourceType=Microsoft.Compute&pageNumber=1&sort=Popular)
- [Microsoft Learn Modules for Linux VMs](https://docs.microsoft.com/learn/browse/?term=linux%20Virtual%20Machine)

If you are new to template deployment, see:

[Azure Resource Manager documentation](https://docs.microsoft.com/azure/azure-resource-manager/)

`Tags: Azure4Student, virtual machine, Linux, Ubuntu Server, Beginner,Java, TomCat`  


