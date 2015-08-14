# Docker Swarm Cluster

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdocker-swarm-cluster%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

*(Built by: [ahmetalpbalkan](https://github.com/ahmetalpbalkan), [garimakhulbe](https://github.com/garimakhulbe))*

This template deploys a [Docker Swarm](http://docs.docker.com/swarm) cluster
on Azure with multiple manager nodes and specified number of slave nodes in
the location of the resource group.

If you are not familiar with Docker Swarm, please
[read Swarm documentation](http://docs.docker.com/swarm).

## Parameters

| Name   | Description |
|:--- |:---|
| `slaveCount`  | Number of the nodes in the Swarm node pool. |
| `newStorageAccountName`  | Unique name for a new storage account where the VM disks will be stored. |
| `adminUsername` | SSH user for the Virtual Machines.  |
| `sshPublicKey` | SSH key for the Virtual Machines.  |
| `dnsName` | Unique DNS Name for the Swarm Management endpoint and the load balancer for slave nodes. |
| `dockerCa`  | Base64-encoded Docker CA certificate (`ca.pem`) for the Docker engines and Swarm managers. |
| `dockerCert`  | Base64-encoded Docker TLS Certificate (`cert.pem`) for the Docker engines and Swarm managers. |
| `dockerKey` | Base64-encoded Docker TLS Key (`key.pem`) for the Docker engines and Swarm managers. |

## Cluster Properties

#### Swarm Managers (High Availability Setup)

The template provisions 3 Swarm manager VMs that use [Consul](https://consul.io/)
for discovery and leader election. These VMs are in an [Avabilability Set][av-set]
to achieve the highest uptime.

Each Swarm manager VM is of size `Standard_A0` as they are not running any workloads
except the Swarm Manager and Consul containers. Manager node VMs have static private IP addresses
`10.0.0.4`, `10.0.0.5` and `10.0.0.6` and they are in the same [Virtual Network][az-vnet] as slave nodes.

**Accessing manager VMs:** Swarm manager nodes (`swarm-master-*` VMs) do not have
public IP addresses. However they are NAT'ted behind an Azure Load Balancer. You
can SSH into them using the domain name (emitted in the template deployment output) or
the Public IP address of `swarm-lb-masters` (can be found on the Azure Portal).

Port numbers of each master VM is described in the following table:

| VM   | SSH command |
|:--- |:---|
| `swarm-master-0`  | `ssh <username>@<IP> -p 2200` |
| `swarm-master-1`  | `ssh <username>@<IP> -p 2201` |
| `swarm-master-2`  | `ssh <username>@<IP> -p 2202` |

#### Configuring Authentication

It is highly recommended to provide `dockerCa`, `dockerCert`, `dockerKey` parameters
in the template. Otherwise the created Docker Swarm cluster will be open to anyone
in public Internet without any authentication.

These certificates are used to configure each Docker Engine and Docker Swarm
Manager endpoints using TLS authentication. Once the cluster is created, you
can use the DNS address in the output as follows to talk to the Docker Swarm Managers:

    docker -H tcp://<dnsName>-manage.cloudapp.azure.com:2376 --tls ps

#### Swarm Slave Nodes

You can configure `slaveCount` parameter to create as many instances you like.
Each Swarm slave VM is of size `Standard_A2`.

Slave nodes do not have public IP addresses, and are accessible through Swarm
manager VMs over SSH. In order to access a slave VM, you need to SSH into a
master VM and use slave VMs private IP address to SSH from there (using the
same SSH key you used for authenticating into master). Alternatively, you can
establish an SSH Tunnel on your development machine and directly connect to
the slave VM using its private IP address.

Slave node VMs have private IP addresses `192.168.0.*` and are in the same
[Virtual Network][az-vnet] with the manager nodes. Slave nodes are in an
[Availability Set][av-set] to ensure highest uptime and fault domains.

Slave node VMs have are behind a load balancer (called `swarm-lb-slaves`). Any
multi-instance services deployed across slave VMs can be served to the public
internet by creating probes and load balancing rules on this Load Balancer
resource. Load balancer's public DNS address is emitted as an output of the
template deployment.

## Output

The template deployment will output two values:

#### 1. `SwarmManagerDockerEndpoint`

This is in `tcp://<hostname>:2376` format and can be directly used in Docker
client to target managers of the Swarm cluster.

#### 2. `SwarmSlavesDNS`

This is a [Load Balancer][az-lb] endpoint for the slave nodes in the
Swarm cluster and has no load balancing rules by default. As you deploy services
to the cluster, you can create new Load Balancing Rules and Probes from Azure
Portal.

-----------------

![Docker Swarm logo](https://github.com/docker/swarm/raw/master/logo.png?raw=true)

[av-set]: https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-manage-availability/
[az-lb]: https://azure.microsoft.com/en-us/documentation/articles/load-balancer-overview/
[az-vnet]: http://azure.microsoft.com/en-us/documentation/services/virtual-network/
