# Description

**Type:** Distributed
**Requires CredSSP:** No

This resource is used to specify if a specific service application should be
published (Ensure = "Present") or not published (Ensure = "Absent") on the
current server. The name is the display name of the service application as
shown in the Central Admin website.

You can publish the following service applications in a SharePoint Server
2013/2016/2019 farm:

* Business Data Connectivity
* Machine Translation
* Managed Metadata
* User Profile
* Search
* Secure Store

The default value for the Ensure parameter is Present. When not specifying this
parameter, the service application is provisioned.
