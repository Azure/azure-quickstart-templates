# Description

**Type:** Distributed
**Requires CredSSP:** No

This resource is used to set the SharePoint Designer settings for the local
farm or site collections. These settings will be used to control if users are
allowed to make changes using SharePoint Designer. Note that this will not
prevent users from installing SharePoint Designer, just from using SharePoint
Designer to connect to the farm.

Settings can be applied against an entire web application, or a specific site
collection. Use the "SettingsScope" property to set it to either
"WebApplication" or "SiteCollection" to define which you are targetting.

Known issue:
When using PowerShell v4 or PowerShell v5 with the InstallAccount switch
(instead of PsDscRunAsCredential), you cannot use the SettingsScope
"SiteCollection". Due to an issue with Remote PowerShell and SharePoint,
changing the Site Collection settings results in an Access Denied error.
Consider implementing PowerShell v5 and switching to the PsDscRunAsCredential
