# Description

**Type:** Distributed
**Requires CredSSP:** No

This resource will configure the site url for a host named site collection.
There are four available zones to configure: Intranet, Internet, Extranet
and Custom.

It is not possible to change the site url for the Default zone, since this
means changing the url that is used as identity. A site collection rename
is required for that:
$site = Get-SPSite "http://old.contoso.com"
$new = "http://new.contoso.com"
$site.Rename($new)
((Get-SPSite $new).contentdatabase).RefreshSitesInConfigurationDatabase
