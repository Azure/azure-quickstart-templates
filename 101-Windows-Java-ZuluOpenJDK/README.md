# VM-Windows - Azul Zulu OpenJDK installation

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-Windows-Java-ZuluOpenJDK/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-Windows-Java-ZuluOpenJDK/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-Windows-Java-ZuluOpenJDK/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-Windows-Java-ZuluOpenJDK/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-Windows-Java-ZuluOpenJDK/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-Windows-Java-ZuluOpenJDK/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-Windows-Java-ZuluOpenJDK%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-Windows-Java-ZuluOpenJDK%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

## Overview

This template deploys a Windows VM with the Azul Zulu for Azure - Enterprise Edition, a supported OpenJDK JVM from Azul.<br/>
The VM can be configured using new or existing resources for Storage, the Virtual Network and Public IP Address.<br/>

Choices for Windows are Server 2019 Datacenter, Server 2016 Datacenter, Desktop 10 Enterprise, Desktop 10 Enterprise N, Desktop 10 Pro, and Desktop 10 Pro N.<br/>
The default is Server 2019 Datacenter.

Choices for the Zulu OpenJDK JVM are the JDK or JRE for the latest release of Java 7, 8, 11, or 13.<br/>
The default is the Zulu Java 8 JDK.

The VM is deployed in the resource group location by default using the latest patched version of Windows 2019-Datacenter and a Standard_D2s_v3 size VM as the default value.

The Zulu installation script is pulled from https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-Windows-Java-ZuluOpenJDK/zulu-install.sh

**Related Templates**
- [101-Linux-Java-ZuluOpenJDK](https://github.com/Azure/azure-quickstart-templates/tree/master/101-Linux-Java-ZuluOpenJDK)

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

- [Azure Resource Manager documentation](https://docs.microsoft.com/azure/azure-resource-manager/)

`Tags: Windows, Java, OpenJDK, Zulu`  
