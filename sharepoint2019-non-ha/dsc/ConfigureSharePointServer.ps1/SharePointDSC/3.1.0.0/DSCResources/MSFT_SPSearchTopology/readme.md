# Description

**Type:** Distributed
**Requires CredSSP:** No

This resource is responsible for provisioning a search topology in to the
current farm. It allows the configuration to dictate the search topology roles
that the current server should be running. Any combination of roles can be
specified and the topology will be upaded to reflect the current servers new
roles. If this is the first server to apply topology to a farm, then at least
one search index must be provided.

You only need to run the topology resource on a single server in the farm.
It will enable the components on each server in the farm, as specified in
the configuration. It is not required to also include SPServiceInstance as
the SPSearchTopology will make sure they are started when applying the
topology. However, it can be a good idea to include it so that the services
will be started later on if they are ever found to be stopped.

Note that for the search topology to apply correctly, the path specified for
FirstPartitionDirectory needs to exist on the server that is executing this
resource. For example, if a configuration was executed on "Server1" it would
also need to ensure that it was able to create the index path at I:\. If no
disk labeled I: was available on server1, this would fail, even though it will
not hold an actual index component.
