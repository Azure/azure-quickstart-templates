# Description

**Type:** Distributed
**Requires CredSSP:** No

This resource is used to specify a managed account to be used to run a service instance.
You can also specify LocalService, LocalSystem or NetworkService as ManagedAccount.
The name is the typename of the service as shown in the Central Admin website.
This resource only needs to be run on one server in the farm, as the process identity
update method will apply the settings to all instances of the service.
