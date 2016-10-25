# Create 2 Virtual Machines in an Availability Set and Configure NAT Rules through the Load balancer

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-2-vms-loadbalancer-natrules%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-2-vms-loadbalancer-natrules%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template allows you to create (n) Host Guardian Service  in an Availability Set and configure NAT rules through the load balancer. This template also deploys a Storage Account, Virtual Network, Public IP address and Network Interfaces.

In this template, we use the resource loops capability to create the network interfaces and virtual machines.


The “Host Guardian Service” (HGS) is a new server role introduced in Windows Server 2016. HGS provides Attestation and Key Protection services that enable Hyper-V to run Shielded virtual machines. A Hyper-V host is known as a “guarded host” once the Attestation service affirmatively validates its identity & configuration. Once affirmatively attested, the Key Protection service provides the transport key (TK) needed to unlock & run Shielded VMs.

Shielded VMs protect VM data and state by supporting a virtual TPM (vTPM) device which allows BitLocker encryption of the VM’s disks. This vTPM device is encrypted with a transport key. HGS is a security critical component that protects the TK. In addition, there are significant security enhancements made across multiple components (including Hyper-V) that raise the security assurance levels for Shielded VMs. For more details on terms like Shielded VMs, guarded fabric, guarded hosts, etc. click here.