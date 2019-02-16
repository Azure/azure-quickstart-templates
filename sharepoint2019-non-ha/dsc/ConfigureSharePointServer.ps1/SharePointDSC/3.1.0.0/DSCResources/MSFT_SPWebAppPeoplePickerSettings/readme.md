# Description

**Type:** Distributed
**Requires CredSSP:** No

This resource is used to configure the People Picker settings for a web
application.

NOTE:
If the forest or domain on which SharePoint is installed has a one-way
trust with another forest or domain, you must first set the credentials
for an account that can authenticate with the forest or domain to be
queried before you can configure the SearchActiveDirectoryDomains.

The encryption key must be set on every front-end web server in the farm
on which SharePoint is installed:
https://technet.microsoft.com/en-us/library/gg602075(v=office.15).aspx#section3
