# Description

**Type:** Distributed
**Requires CredSSP:** No

This resource is used to make sure that a specific farm solution is either
present or absent in a farm. The solution can be deployed to one or more web
application passing an array of URL's to the WebApplications property. If the
solution contains resources scoped for web applications and no WebApplications
are specified, the solution will be deployed to all web applications. If the
solution does not contain resources scoped for web applications the property

The default value for the Ensure parameter is Present. When not specifying this
parameter, the solution is deployed.
