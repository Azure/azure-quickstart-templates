# Description

**Type:** Specific
**Requires CredSSP:** No

This resource is responsible for provisioning the distributed cache to the
service it runs on. This is required in your farm on at least one server (as
the behavior of SPCreateFarm and SPJoinFarm is to not enroll every server as a
cache server). The service will be provisioned or de-provisioned based on the
Ensure property, and when provisioned the CacheSizeInMB property and
ServiceAccount property will be used to configure it. The property
createFirewallRules is used to determine if exceptions should be added to the
windows firewall to allow communication between servers on the appropriate
ports.

The ServerProvisionOrder optional property is used when a pull server is
handing out configurations to nodes in order to tell this resource about a
specific order of enabling the caches. This allows for multiple servers to
receive the same configuration, but they will always check for the server
before them in the list first to ensure that it is running distributed cache.
By doing this you can ensure that you do not create conflicts with two or more
servers provisioning a cache at the same time. Note, this approach only makes
a server check the others for distributed cache, it does not provision the
cache automatically on all servers. If a previous server in the sequence does

The default value for the Ensure parameter is Present. When not specifying this
parameter, the distributed cache is provisioned.
