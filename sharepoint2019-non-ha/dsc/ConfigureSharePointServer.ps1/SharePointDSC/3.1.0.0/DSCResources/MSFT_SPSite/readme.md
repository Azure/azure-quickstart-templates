# Description

**Type:** Distributed
**Requires CredSSP:** No

This resource will provision a site collection to the current farm, based on
the settings that are passed through. These settings map to the New-SPSite
cmdlet and accept the same values and types.

The current version of SharePointDsc is only able to check for the existence
of a site collection, the additional parameters are not checked for yet, but
will be in a later release

NOTE:
When creating Host Header Site Collections, do not use the HostHeader
parameter in SPWebApplication. This will set the specified host header on your
IIS site and prevent the site from listening for the URL of the Host Header
Site Collection.
If you want to change the IIS website binding settings, please use the xWebsite
resource in the xWebAdministration module.

NOTE2:
The CreateDefaultGroups parameter is only used for creating default site
groups. It will not remove or change the default groups if they already exist.

NOTE3:
AdministrationSiteType is used in combination with the resource
SPWebAppClientCallableSettings. The required proxy library must be configured
before the administration site type has any effect.
