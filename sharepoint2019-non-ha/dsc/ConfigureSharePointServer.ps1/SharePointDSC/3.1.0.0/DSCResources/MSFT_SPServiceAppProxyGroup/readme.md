# Description

**Type:** Distributed
**Requires CredSSP:** No

This resource is used to manage SharePoint Service Application Proxy Groups.
The "Ensure" parameter controls whether or not the Proxy Group should exist. A
proxy group cannot be removed if a web application is using it. The
"ServiceAppProxies" property will set a specific list of Service App Proxies
to be members of this Proxy Group. It will add and remove proxies to ensure
the group matches this list exactly. The "ServiceAppProxiesToInclude" and
"ServiceAppProxiesToExclude" properties will allow you to add and remove
proxies from the group, leaving other proxies that are in the group but not in
either list intact.

Use the proxy group name "Default" to manipulate the default proxy group.

Requirements:
At least one of the ServiceAppProxies, ServiceAppProxiesToInclude or
ServiceAppProxiesToExclude properties needs to be specified. Do not combine
the ServiceAppProxies property with the ServiceAppProxiesToInclude and

The default value for the Ensure parameter is Present. When not specifying this
parameter, the proxy group is created.
