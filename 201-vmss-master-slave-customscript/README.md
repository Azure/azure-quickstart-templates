# Deploy a VM Scale Set of Linux VMs with a custom script extension in master / slave architecture

This template allows you to deploy a VM Scale Set of Linux VMs and create a new virtual network at the same time. These VMs have a custom script extension for customization and are behind a load balancer with NAT rules for rdp connections. This allows to specify the master node number and data node number, adapt to any master / slave architecture

PARAMETER RESTRICTIONS
======================

vmssName must be 3-10 characters in length. If it isn't globally unique, it is possible that this template will still deploy properly, but we don't recommend relying on this pseudo-probabilistic behavior.
instanceCount must be 20 or less. VM Scale Set supports upto 100 VMs and one should add more storage accounts to support this number.
