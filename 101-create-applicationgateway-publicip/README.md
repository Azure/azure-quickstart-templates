# Application Gateway With Public IP and HTTP Listener

Built by: [puneetsaraswat](https://github.com/puneetsaraswat)

This template creates an Application Gateway, Public IP address for the Application Gateway, and the Virtual Network in which Application Gateway is deployed. Also configures Application Gateway for Http Load balancing with Two backend servers.

Below are the parameters that the template expects

| Name                      | Description                                               |
|:-------------------------:|:---------------------------------------------------------:|
| location                  | Azure region where the resource will be deployed to       |
| applicationGatewayName    | Name of Application Gateway                               |
| publicIPAddressName       | Name of Public IP address resource                        |
| virtualNetworkName        | Name of Virtual Network                                   |
| subnetName                | Name of Subnet                                            |
| addressPrefix             | Prefix for the address in CIDR format                     |
| subnetPrefix              | Prefix for the subnet in CIDR format                      |
| skuName                   | Sku Name                                                  |
| capacity                  | Number of instances                                       |
| backendIpAddress1         | IP Address for Backend Server 1                           |
| backendIpAddress1         | IP Address for Backend Server 2                           |
