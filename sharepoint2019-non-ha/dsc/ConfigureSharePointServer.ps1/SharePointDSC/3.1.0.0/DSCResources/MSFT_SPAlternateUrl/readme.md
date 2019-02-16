# Description

**Type:** Distributed
**Requires CredSSP:** No

This resource is used to define an alternate access mapping URL for a specified
web application. These can be assigned to specific zones for each web
application. Alternatively a URL can be removed from a zone to ensure that it
will remain empty and have no alternate URL.

The default value for the Ensure parameter is Present. When not specifying this
parameter, the setting is configured.

## Central Administration

To select the Central Administration site, use the following command to retrieve
the correct web application name:
(Get-SPWebApplication -IncludeCentralAdministration | Where-Object {
     $_.IsAdministrationWebApplication
 }).DisplayName

To update the existing Default Zone AAM for Central Administration (e.g. to
implement HTTPS), use the above command to retrieve the web application name
(by default, it will be "SharePoint Central Administration v4") and specify
"Default" as the Zone. If you wish to add AAM's instead, you may use the other
zones to do so.

Using SPAlternateUrl to update the Default Zone AAM for Central Administration
will update the AAM in SharePoint as well as the CentralAdministrationUrl value
in the registry. It will not, however, update bindings in IIS. It is recommended
to use the xWebsite resource from the xWebAdministration module to configure the
appropriate bindings in IIS.
