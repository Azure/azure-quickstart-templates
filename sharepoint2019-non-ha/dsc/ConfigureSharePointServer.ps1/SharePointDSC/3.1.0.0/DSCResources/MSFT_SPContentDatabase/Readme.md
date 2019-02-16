# Description

**Type:** Distributed
**Requires CredSSP:** No

This resource is used to add and remove Content Databases to web applications
and configure these databases.

NOTE:
The resource cannot be used to move the database to a different SQL instance.
It will throw an error when it detects that the specified SQL instance is a
different instance that is currently in use.

The default value for the Ensure parameter is Present. When not specifying this
parameter, the content database is provisioned.
