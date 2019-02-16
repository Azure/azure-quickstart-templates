# Description

**Type:** Distributed
**Requires CredSSP:** No

This resource is responsible for provisioning and configuring the secure store
service application. The parameters passed in (except those related to database
specifics) are validated and set when the resource is run, the database values
are only used in provisioning of the service application.

The default value for the Ensure parameter is Present. When not specifying this
parameter, the service application is provisioned.
