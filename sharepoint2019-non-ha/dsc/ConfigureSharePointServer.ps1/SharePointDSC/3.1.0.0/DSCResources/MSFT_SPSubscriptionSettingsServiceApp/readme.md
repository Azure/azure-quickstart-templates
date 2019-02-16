# Description

**Type:** Distributed
**Requires CredSSP:** No

This resource is used to provision and manage an instance of the App Management
Services Service Application. It will identify an instance of the subscription
settings service app through the application display name. Currently the
resource will provision the app if it does not yet exist, and will change the
service account associated to the app if it does not match the configuration.
Database names or server name will not be changed if the configuration does
not match, these parameters are only used for the initial provisioning of the
service application.

The default value for the Ensure parameter is Present. When not specifying this
parameter, the service application is provisioned.
