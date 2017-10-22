# Cassandra Cluster using Docker

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-cassandra-existing-vnet%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-cassandra-existing-vnet%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template allows you to deploy a Docker enabled Cassandra Cluster running on Virtual Machine Scale Sets.
The template will deploy to an existing VNET and allows you to choose the Cassandra version to use.

## A. Deploy Cassandra Cluster
1. Click the "Deploy to Azure" button. If you don't have an Azure subscription, you can follow instructions to signup for a free trial.
1. Enter a valid name for the cluster name, as well as a user name and [ssh public key](https://docs.microsoft.com/azure/virtual-machines/virtual-machines-linux-mac-create-ssh-keys) that you will use to login remotely to the VM via SSH.

This will create a Scale Set running a Cassandra Host and Seed nodes using Docker.
The cluster if fronted by a public Azure Load Balancer.

## B. Login remotely to a VM via SSH
To connect from the load balancer to a VM in the scale set, you would go to the Azure Portal, find the load balancer of your scale set, examine the NAT rules, then connect using the NAT rule you want. For example, if there is a NAT rule on port 50000, you could use the following command to connect to that VM:

```
ssh -p 50000 {username}@{public-ip-address}
```

## C. Connect to Cassandra

The load balancer of the cluster scale set has a Load Balance rule for port 9042.
To connect to your cluster simply access {loadbalancer-public-up-address}:9042