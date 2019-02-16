# Description

**Type:** Distributed
**Requires CredSSP:** No

This resource is responsible for creating search indexes. It works by creating
the index topology components and updating the topology from the server that
runs this resource. For this reason this resource only needs to run from one
server and not from each server which will host the index component. The
search service application and existing search topology must be deployed
before creating additional indexes. The first index will be created through
the use of the SPSearchRoles resource. Additional search index partitions can
be created through using this resource.

Note that for the search topology to apply correctly, the path specified for
RootDirectory needs to exist on the server that is executing this resource. For
example, if the below example was executed on "Server1" it would also need to
ensure that it was able to create the index path at I:\. If no disk labeled I:
was available on server1, this would fail, even though it will not hold an
actual index component.
