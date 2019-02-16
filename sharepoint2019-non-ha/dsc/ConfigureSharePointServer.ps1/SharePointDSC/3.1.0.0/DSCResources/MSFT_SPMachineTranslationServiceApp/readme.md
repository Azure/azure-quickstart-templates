# Description

**Type:** Distributed
**Requires CredSSP:** No

This resource is used to provision and manage an instance of the Machine
Translation Service Application. It will identify an instance of the MT
app through the application display name. Currently the resource will
provision the app if it does not yet exist, and will change the service
account associated to the app if it does not match the configuration.

The default value for the Ensure parameter is Present. When not specifying this
parameter, the service application is provisioned.
