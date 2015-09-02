# Docker Swarm Cluster

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdocker-swarm-cluster%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template deploys a [Docker Swarm](http://docs.docker.com/swarm) cluster
on Azure with multiple manager nodes and specified number of slave nodes in
the location of the resource group.

If you are not familiar with Docker Swarm, please
[read Swarm documentation](http://docs.docker.com/swarm).

The template uses [CoreOS](https://coreos.com) as the host operating system for
running containers on Swarm managers and nodes.

## Cluster Properties

#### Swarm Managers (High Availability Setup)

The template provisions 3 Swarm manager VMs that use
[Consul](https://consul.io/) for discovery and leader election. These VMs are in
an [Avabilability Set][av-set] to achieve the highest uptime.

Each Swarm manager VM is of size `Standard_A0` as they are not running any
workloads except the Swarm Manager and Consul containers. Manager node VMs have
static private IP addresses `10.0.0.4`, `10.0.0.5` and `10.0.0.6` and they are
in the same [Virtual Network][az-vnet] as slave nodes.

#### How to SSH into Swarm Manager Nodes

 Swarm manager nodes (`swarm-master-*` VMs) do not
have public IP addresses. However they are NAT'ted behind an Azure Load
Balancer. You can SSH into them using the domain name (emitted in the template
deployment output) or the Public IP address of `swarm-lb-masters` (can be found
on the Azure Portal).

Port numbers of each master VM is described in the following table:

| VM   | SSH command |
|:--- |:---|
| `swarm-master-0`  | `ssh <username>@<IP> -p 2200` |
| `swarm-master-1`  | `ssh <username>@<IP> -p 2201` |
| `swarm-master-2`  | `ssh <username>@<IP> -p 2202` |

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

#### How to SSH into Swarm Slave Nodes

Since Swarm slave VMs do not have public IP addresses, you first need to SSH
into Swarm manager VMs (described above) to SSH into Swarm nodes.

You just need to use `ssh -A` to SSH into one of the masters, and from that
point on you can reach any other VM in the cluster as shown below:

```sh
$ ## <-- You are on your development machine
$
$ ssh -A <username>@<masters-IP> -p 2200
azureuser@swarm-master-0 ~ $ ## <-- You are on Swarm master
azureuser@swarm-master-0 ~ $ ssh <username>@swarm-node-3
azureuser@swarm-node-3 ~ $ ## <-- You are now on a Swarm slave
```

Swarm node hostnames are numbered starting from 0, such as: `swarm-node-0`,
`swarm-node-1`, ..., `swarm-node-19` etc. You can see the VM names on the
Azure Portal as well.

## Connecting the Cluster

If the template deploys successfully it will have output values `"sshTunnelCmd"`
and `"dockerCmd"`. The tunnel command will create a SSH tunnel to Docker Swarm
Manager (this command will keep running with no output):

    ssh -L 2375:swarm-master-0:2375 -N core@<<DNSNAME>>-manage.westus.cloudapp.azure.com -p 2200

After this you can refer to `dockerCmd` output which shows you how to run
commands on the Docker Swarm cluster:

    docker -H tcp://localhost:2375 info

This also can be executed in the shorthand form:

    export DOCKER_HOST=:2375
    docker info

[av-set]: https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-manage-availability/
[az-lb]: https://azure.microsoft.com/en-us/documentation/articles/load-balancer-overview/
[az-vnet]: http://azure.microsoft.com/en-us/documentation/services/virtual-network/
