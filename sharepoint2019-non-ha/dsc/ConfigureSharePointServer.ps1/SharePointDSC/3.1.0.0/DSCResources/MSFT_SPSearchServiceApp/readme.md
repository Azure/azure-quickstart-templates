# Description

**Type:** Distributed
**Requires CredSSP:** No

This resource is responsible for provisioning the search service application.
The current version lets you specify the database name and server, as well as
the application pool. If the application pool is changed the DSC resource will
set it back as per what is set in the resource. The database name parameter is
used as the prefix for all search databases (so you will end up with one for
the admin database which matches the name, and then
"_analyticsreportingstore", "_crawlstore" and "_linkstore" databases as well).

The default value for the Ensure parameter is Present. When not specifying this
parameter, the service application is provisioned.

NOTE: The WindowsServiceAccount parameter is deprecated and no longer does
anything. The functionality for changing this account has been moved to
SPSearchServiceSettings.
