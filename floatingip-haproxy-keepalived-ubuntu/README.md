# Create 2 ubuntu VMs under a Load balancer, configure load balancing rules with floating IP for the VMs. 

## *NOTE*: This template is not available yet. See **Setup Details** page for more information on the setup.

This template allows you to create 2 ubuntu VMs under a Load balancer, configure load balancing rule on Port 80 with floating IP enabled. This template also deploys a Storage Account, Virtual Network, Public IP address, Availability Set and Network Interfaces.

Each VM is configured with haproxy and keepalived, where the Load balancer VIP is hosted only on the MASTER VM.

In this template, we use the resource loops capability to create the network interfaces and virtual machines
