# Description

**Type:** Distributed
**Requires CredSSP:** No

This resource is used to associate a web application to a service application
proxy group. Use the proxy group name "Default" to associate the web
application to the default proxy group. A web applicaiton can only connect to
a single service application proxy group. This resource will overright the
existing service application proxy group association.

This resource is used in conjunction with the SPServiceAppProxyGroup resource,
which creates the proxy groups and associates the desired service application
proxies with it. Within your configuration, that resource should be a
