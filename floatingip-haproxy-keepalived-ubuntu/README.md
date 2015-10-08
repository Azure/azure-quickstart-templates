# Create a redundant load-balancer setup, with 2 Ubuntu VMs running haproxy/keepalived, each load balancing requests to 2 other Ubuntu VMs running Apache webserver.

This template creates 2 ubuntu (haproxy-lb) VMs under an *Azure load-balancer* (Azure-LB), which is configured with *floating IP*. The goal-state ensures only one of the haproxy-lb VMs is active and configured with the VIP (public IP) address. It also creates 2 other Ubuntu (application) VMs running Apache (default configuration) for a proof-of-concept. 

It uses *CustomScript Extension* to configure haproxy-lb VMs with haproxy/keepalived, and application VMs with apache2.

It also deploys a Storage Account, Virtual Network, Public IP address, Availability Sets and Network Interfaces as required.

This template uses the resource loops capability to create network interfaces, virtual machines and extensions

### Notes
* Topology: Azure-LB -> haproxy-lb VMs (2) -> application VMs (2)
* Azure-LB
  * Azure-LB is configured with *enableFloatingIP* set to true in *loadBalancingRules*. 
    * In this configuration, Azure-LB does not perform DNAT from public IP (VIP) to DIP of the pool members. Packets reach the pool member with destination IP set to public IP.
  * Public IP **should** be configured on a network adapater of the pool member VMs to receive/respond to the requests
* Haproxy-lb VMs
  * Public IP associated with Azure-LB is assigned to *only* one of the haproxy-lb VMs (MASTER as determined by keepalived).
  * Azure-LB probe on the other haproxy-lb VM (BACKUP) is explicitly disabled using a firewall(iptables) rule to block the LB probe port.
  * When a haproxy-lb VM status changes to MASTER, firewall rule(s) to block LB probe port is removed.
  * Custom keepalived verify and notify scripts are deployed to enable/disable probes as described above.
  * All configuration files are created as part of *CustomScript Extension*
* Application VMs
  * Apache webserver is deployed as part of *CustomScript Extension*. No changes are done to default configuration. 
  * This is only a proof-of-concept. The functionality of application VMs can be modified per requirement. Corresponding changes need to be done to *variables* section of the template.

