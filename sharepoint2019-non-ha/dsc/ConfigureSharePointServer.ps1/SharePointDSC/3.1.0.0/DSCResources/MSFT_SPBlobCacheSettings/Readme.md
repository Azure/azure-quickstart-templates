# Description

**Type:** Specific
**Requires CredSSP:** No

This resource is used to configure the Blob Cache settings for a web
application.

Important:
This resource only configures the local server. It changes the web.config
file directly and is NOT using the SPWebConfigModifications class. In order
to configure all WFE servers in the farm, you have to apply this resource
to all servers.

NOTE:
In order to prevent inconsistancy between different web front end servers,
make sure you configure this setting on all servers equally.
If the specified folder does not exist, the resource will create the folder.

Best practice:
Specify a directory that is not on the same drive as where either the server
operating system swap files or server log files are stored.
