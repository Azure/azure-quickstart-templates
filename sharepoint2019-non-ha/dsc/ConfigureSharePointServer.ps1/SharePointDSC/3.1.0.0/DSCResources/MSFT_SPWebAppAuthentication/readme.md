# Description

**Type:** Distributed
**Requires CredSSP:** No

This resource is responsible for configuring the authentication on a web
application within the local SharePoint farm. The resource is able to
configure the five available zones (if they exist) separately and each
zone can have multiple authentication methods configured.

NOTE:
This resource cannot be used to convert a Classic web application
to Claims mode. You have to run Convert-SPWebApplication manually for that.

NOTE 2:
Updating the configuration can take a long time, up to five minutes.
The Set-SPWebApplication cmdlet sometimes requires several minutes to
complete its action. This is not a SharePointDsc issue.
