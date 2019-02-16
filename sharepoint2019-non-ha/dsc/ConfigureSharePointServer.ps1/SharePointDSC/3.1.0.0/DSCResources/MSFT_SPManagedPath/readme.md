# Description

**Type:** Distributed
**Requires CredSSP:** No

This resource is responsible for creating managed paths associated with a
specific web application. The WebAppUrl parameter is used to specify the web
application to create the path against, and the RelativeUrl parameter lets you
set the URL. Explicit when set to true will create an explicit inclusion path,
if set to false the path is created as wildcard inclusion. If you are using
host named site collections set HostHeader to true and the path will be
created as a host header path to be applied for host named site collections.

The default value for the Ensure parameter is Present. When not specifying this
parameter, the managed path is created.
