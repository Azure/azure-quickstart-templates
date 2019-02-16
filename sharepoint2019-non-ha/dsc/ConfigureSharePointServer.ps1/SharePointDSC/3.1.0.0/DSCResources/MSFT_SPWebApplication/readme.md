# Description

**Type:** Distributed
**Requires CredSSP:** No

This resource is responsible for creating a web application within the local
SharePoint farm. The resource will provision the web application with all of
the current settings, and then ensure that it stays part of the correct
application pool beyond that (additional checking and setting of properties)

The default value for the Ensure parameter is Present. When not specifying this
parameter, the web application is provisioned.

NOTE:
When using Host Header Site Collections, do not use the HostHeader
parameter in SPWebApplication. This will set the specified host header on your
IIS site and prevent the site from listening for the URL of the Host Header
Site Collection.
If you want to change the IIS website binding settings, please use the xWebsite
resource in the xWebAdministration module.
