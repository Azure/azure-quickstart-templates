##Setup
###Overview
* A load balancer with a public VIP, load balancing rules & NAT rules
  * Load balancing rules direct publicVIP:80 to port 80 of one of the backend pool servers.
  * Floating IP is enabled on the load balancing rules.
  * NAT rules provide SSH access to the backend pool VMs
* haproxy and keepalived are configured on each of the VMs
* keepalived ensures only one VM is in MASTER state. The floating IP (public VIP) is announced from this MASTER VM.
  * A firewall rule is added on the BACKUP VM so that load balancer probes fail and the VM is disabled in the pool. This ensures all requests are sent only to the MASTER VM.
* haproxy on each VM will further load balance the requests among its backend pool members
