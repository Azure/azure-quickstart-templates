# Install Nagios Core on Ubuntu Virtual Machines using Custom Script Linux Extension

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/nagios/nagios-on-ubuntu/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/nagios/nagios-on-ubuntu/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/nagios/nagios-on-ubuntu/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/nagios/nagios-on-ubuntu/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/nagios/nagios-on-ubuntu/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/nagios/nagios-on-ubuntu/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fnagios%2Fnagios-on-ubuntu%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fnagios%2Fnagios-on-ubuntu%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fnagios%2Fnagios-on-ubuntu%2Fazuredeploy.json)

This template deploys Nagios Core, a host/service/network monitoring solution released under the GNU General Public License. This template also provisions a storage account, virtual network, public IP addresses and network interfaces required by the installation.

Visit the Nagios homepage at http://www.nagios.org for documentation, new releases, bug reports, information on discussion forums, and more.

Topology
--------
The Nagios deployment topology is comprised of a single VM instance that can be customized and scaled up using the _tshirtSize_ parameter. The following table outlines the VM characteristics for each supported t-shirt size:

| T-Shirt Size | VM Size | CPU Cores | Memory |
|:--- |:---|:---|:---|
| Small | Standard_A1_v2 | 1 | 1.75 GB |
| Medium | Standard_D1_v2 | 1 | 3.5 GB |
| Large | Standard_D2_v2 | 2 | 7 GB |
| XLarge | Standard_D3_v2 | 4 | 14 GB |
| XXLarge | Standard_D3_v2 | 8 | 28 GB |

Known Issues and Limitations
--------
- A single instance installation Nagios Core is performed by the template
- This template does not install any monitoring targets
