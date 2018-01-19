# Cisco Cloud Services Router 1000v

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fcisco-csr-1000v-existing-vnet%2Fazuredeploy.json" target="_blank">
<img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fcisco-csr-1000v-existing-vnet%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.png"
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fcisco-csr-1000v-existing-vnet%2Fazuredeploy.json" target="_blank">
<img src="http://armviz.io/visualizebutton.png"/>
</a>

The Cisco Cloud Services Router (CSR) 1000v is a full-featured Cisco IOS XE router, enabling enterprise-class networking services in the Azure cloud. The following are examples of how the CSR is being used to enable enterprise-class hybrid clouds.

Extend enterprise VPN architectures into your private cloud: The CSR 1000v supports IPsec, DMVPN, FlexVPN, Easy VPN, and SSLVPN, and configuration, monitoring, and troubleshooting with familiar IOS commands. No per-tunnel VPN fees.
Interconnect multiple regions and clouds: Using dynamic routing protocols such as EIGRP, OSPF, and BGP for multi-tier architectures within Azure, and interconnect with corporate locations or other clouds.
Secure, inspect, and audit hybrid cloud network traffic: Zone Based Firewall provides an application-aware firewall. IP SLA and Application Visibility and Control (AVC) can discover performance issues, fingerprint application flows, and export detailed flow data.

!!!!! Note - Important Update - Please Read !!!!!

Azure now requires that the CSR 1000v be deployed in a new Resource Group. The CSR 1000v will be attached to an existing network that must have at least 2 subnets.
The existing network's route tables will not be altered.

This deployment creates a CSR with 2 NICs, plus public and private subnets.  It requires an existing virtual network with at least 2 subnets.  User defined routes are created on the subnets to ensure the CSR is used as the default gateway for virtual machines in the private subnet. Finally, the IP Forwarding flag is set on Azure to allow the CSR to properly pass traffic.

`Tags: Cisco, CSR, 1000v`