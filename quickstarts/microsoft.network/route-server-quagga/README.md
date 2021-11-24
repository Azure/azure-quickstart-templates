# Azure Route Server in BGP peering with Quagga

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/route-server-quagga/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/route-server-quagga/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/route-server-quagga/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/route-server-quagga/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/route-server-quagga/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.network/route-server-quagga/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Froute-server-quagga%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.network%2Froute-server-quagga%2Fazuredeploy.json)


The purpose of setup is shown interoperability between Quagga and Azure Route server. This template deployes in the same Azure Virtual Network (VNet) a Route Server in the **RouteServerSubnet** and an Ubuntu Azure VM with Quagga. Once the BGP (Border Gateway Protocol) sessions between the Route Server and Quagga are established, the Route Server advertises to Quagga the address space of the VNet, and Quagga advertises few network prefixes to the Route Servers. 


## Network diagram

[![1]][1]


## Note1
- Route Server is currently in Public Preview.
- Route Server is not currently available in the US Government regions.
- The ASN of Azure Route Server is **65515** and it can't be changed.
- Setup of Quagga is executed by Azure customer script extension for linux, through the bash script **quaggadeploy.sh** stored in the folder **script**

## Note2
After completion of the deployment, it is possible to check the network prefixes advertised from Quagga to the Router Server by powershell command:

```powershell
Get-AzVirtualRouterPeerLearnedRoute -ResourceGroupName <Name_Resource_Group> -VirtualRouterName routesrv1 -PeerName bgp-conn1 | ft
``` 
where
- <Name_Resource_Group>: name of the resource group
- routesrv1: name of the router server
- bgp-conn1: bgp connection of router server with Quagga

A complementary check can be done in the Quagga VM. Login with root credential in the VM and get in Quagga vty shell:
```bash
root@vm1:~# vtysh
```

Inside the vtysh shell, run the command to visualize the BGP table:
```
vm1# show ip bgp
```

To remove the peering in the Route Server:
```powershell
Remove-AzVirtualRouterPeer -ResourceGroupName <Resource_Group_Name> -PeerName <BGP_Connection_Name> -VirtualRouterName <Route_Server_Name>
```

To remove the Route Server:
```powershell
Remove-AzVirtualRouter -ResourceGroupName <Resource_Group_Name> -RouterName <Route_Server_Name>
```

`Tags: route server, BGP`

<!--Image References-->

[1]: ./images/1.png "network diagram"

<!--Link References-->


