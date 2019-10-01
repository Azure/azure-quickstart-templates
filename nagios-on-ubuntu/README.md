# Install Nagios Core on Ubuntu Virtual Machines using Custom Script Linux Extension

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/nagios-on-ubuntu/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/nagios-on-ubuntu/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/nagios-on-ubuntu/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/nagios-on-ubuntu/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/nagios-on-ubuntu/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/nagios-on-ubuntu/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fnagios-on-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fnagios-on-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This template deploys Nagios Core, a host/service/network monitoring solution released under the GNU General Public License. This template also provisions a storage account, virtual network, public IP addresses and network interfaces required by the installation.

Visit the Nagios homepage at http://www.nagios.org for documentation, new releases, bug reports, information on discussion forums, and more.

Topology
--------
The Nagios deployment topology is comprised of a single VM instance that can be customized and scaled up using the _tshirtSize_ parameter. The following table outlines the VM characteristics for each supported t-shirt size:

| T-Shirt Size | VM Size | CPU Cores | Memory |
|:--- |:---|:---|:---|
| Small | Standard_A1 | 1 | 1.75 GB |
| Medium | Standard_D1 | 1 | 3.5 GB |
| Large | Standard_D2 | 2 | 7 GB |
| XLarge | Standard_D3 | 4 | 14 GB |
| XXLarge | Standard_D3 | 8 | 28 GB |

##Known Issues and Limitations
- A single instance installation Nagios Core is performed by the template
- This template does not install any monitoring targets

