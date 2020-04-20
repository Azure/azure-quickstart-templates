# VM-Ubuntu - Tomcat and Open JDK installation

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/openjdk-tomcat-ubuntu-vm/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/openjdk-tomcat-ubuntu-vm/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/openjdk-tomcat-ubuntu-vm/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/openjdk-tomcat-ubuntu-vm/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/openjdk-tomcat-ubuntu-vm/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/openjdk-tomcat-ubuntu-vm/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fselvasingh%2Fazure-quickstart-templates%2Fjava-dev-linux%2Fopenjdk-tomcat-ubuntu-vm%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fopenjdk-tomcat-ubuntu-vm%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

# Overview

This template deploys a Ubuntu VM with the Azul Zulu for Azure - Enterprise Edition, a supported OpenJDK JVM from Azul, and Tomcat.<br/> 
Authentication can be done using an sshPublicKey or a Password.

hoices for Ubuntu are version 18.04-LTS, 16.04-LTS, or 14.04-LTS.<br/>
The default is Ubuntu 18.04-LTS.

Choices for the Zulu OpenJDK JVM are the JDK, JRE, or Headless JRE for the latest release of Java 7, 8, 11, or 13.<br/>
The default is the Zulu Java 8 JDK.

Choices for Tomcat are version 7, 8, or 9.<br/>
The default is Tomcat version 9.

The VM is deployed in the resource group location using the latest patched version of the Ubuntu 18.04-LTS distribution using a Standard_B2s size VM as the default value and will return the admin user name, virtual network name, network security group name and FQDN.

The custom script file is pulled from https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/openjdk-tomcat-ubuntu-vm/java-tomcat-install.sh

Once the VM is successfully provisioned, tomcat installation can be verified by accessing the link http://<FQDN name or public IP>:8080/  

**If you are new to the Azul Zulu OpenJDK JVM, see:**

- [Azul Zulu for Azure - Enterprise Edition FAQ](https://assets.azul.com/files/Zulu-for-Azure-FAQ.pdf)
- [Azul Zulu for Azure - Enterprise Edition](https://www.azul.com/downloads/azure-only/zulu/)
- [Java on Azure](https://azure.microsoft.com/en-us/develop/java/)
- [Azure for Java Developers](https://docs.microsoft.com/en-us/java/azure/?view=azure-java-stable)
- [Azul](https://www.azul.com/)
- [Azul Zulu Enterprise](https://www.azul.com/products/zulu-enterprise/)
- [Azul Zulu Embedded](https://www.azul.com/products/zulu-embedded/)

**If you are new to Azure virtual machines, see:**

- [Azure Virtual Machines](https://azure.microsoft.com/services/virtual-machines/).
- [Azure Linux Virtual Machines documentation](https://docs.microsoft.com/azure/virtual-machines/linux/)
- [Azure Windows Virtual Machines documentation](https://docs.microsoft.com/azure/virtual-machines/windows/)
- [Template reference](https://docs.microsoft.com/azure/templates/microsoft.compute/allversions)
- [Quickstart templates](https://azure.microsoft.com/resources/templates/?resourceType=Microsoft.Compute&pageNumber=1&sort=Popular)
- [Microsoft Learn Modules for Linux VMs](https://docs.microsoft.com/learn/browse/?term=linux%20Virtual%20Machine)

**If you are new to template deployment, see:**

[Azure Resource Manager documentation](https://docs.microsoft.com/azure/azure-resource-manager/)

`Tags: Azure4Student, virtual machine, Linux, Ubuntu Server, Beginner, TomCat, Java, Zulu, OpenJDK`
