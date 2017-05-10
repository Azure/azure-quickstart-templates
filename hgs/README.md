# Deploy Host Guardian Service (HGS) For Shielded VM in Windows Server 2016 in Standalone mode or High Availability using Failover Clustering.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-2-vms-loadbalancer-natrules%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-2-vms-loadbalancer-natrules%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template allows you to Deploy Host Guardian Service For Shielded VM in Windows Server 2016 in Standalone mode (numberOfInstances=1) or in High Availability mode (numberOfInstances=1+) using Windows Failover Clustering.

This template creates an Availability Set for SLA of 99.95% when deployed with high availability (i.e. numberOfInstances=2+ ) and configure NAT rules through the load balancer. 

The “Host Guardian Service” (HGS) is a new server role introduced in Windows Server 2016. HGS provides Attestation and Key Protection services that enable Hyper-V to run Shielded virtual machines. A Hyper-V host is known as a “guarded host” once the Attestation service affirmatively validates its identity & configuration. Once affirmatively attested, the Key Protection service provides the transport key (TK) needed to unlock & run Shielded VMs.

Shielded VMs protect VM data and state by supporting a virtual TPM (vTPM) device which allows BitLocker encryption of the VM’s disks. This vTPM device is encrypted with a transport key. HGS is a security critical component that protects the TK. In addition, there are significant security enhancements made across multiple components (including Hyper-V) that raise the security assurance levels for Shielded VMs. For more details on terms like Shielded VMs, guarded fabric, guarded hosts, etc. click here.