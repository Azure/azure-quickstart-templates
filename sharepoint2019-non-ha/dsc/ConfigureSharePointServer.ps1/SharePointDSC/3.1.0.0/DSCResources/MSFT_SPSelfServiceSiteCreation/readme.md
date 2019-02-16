# Description

**Type:** Distributed
**Requires CredSSP:** No

This resource is used to configure self-service site creation on a web
application.

NOTE:
The web application needs a root level ("/") site collection for the
self-service site creation to function properly. It is not required to have this
site collection present in the web application to succesfully configure this
resource.

NOTE2:
If Enabled is set to false, ShowStartASiteMenuItem is automatically set to false
by the resource if ShowStartASiteMenuItem is not specified. Setting
ShowStartASiteMenuItem to true at the same time as Enabled is set to false
will generate an error.

## Hybrid self-service site creation

It is possible to configure self-service site creation to create sites in
SharePoint Online. This requires that [hybrid self-service site creation](https://docs.microsoft.com/en-us/sharepoint/hybrid/hybrid-self-service-site-creation)
is configured using the Hybrid Picker.
