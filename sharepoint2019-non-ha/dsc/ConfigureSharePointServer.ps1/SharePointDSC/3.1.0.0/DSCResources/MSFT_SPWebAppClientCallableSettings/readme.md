# Description

**Type:** Distributed
**Requires CredSSP:** No

This resource sets the client callable settings for the web application.
It can set the proxy libraries and specific properties for the client
callable settings. The resource can for example be used to increase the
timeout for client code, and to enable the tenant administration
functionality.

Tenant administration functionality enables client code to work with
the namespace Microsoft.Online.SharePoint.Client.Tenant from the
assembly with the same name. This enables client code to create site
collection, list all site collections, and more.

In order to use the tenant administration client code a site collection
within the web application needs to be designated as a tenant
administration site collection. This can be done using the SPSite
resource setting the AdministrationSiteType to TenantAdministration.
Use this site collection when creating a client side connection.

More information about the tenant can be found in a [blog
post]
(https://blogs.msdn.microsoft.com/vesku/2015/12/04/sharepoint-tenant-csom-object-support-in-sharepoint-2013-and-2016/)
by Vesa Juvonen. In another [blog post]
(https://blogs.msdn.microsoft.com/vesku/2014/06/09/provisioning-site-collections-using-sp-app-model-in-on-premises-with-just-csom/)
he goes into more details of
the setup and architecture, and includes sample code for how to use.

NOTE:
Proxy library used for enabling tenant administration:

**SharePoint 2013** (Requires mininum April 2014 Cumulative Update):
Microsoft.Online.SharePoint.Dedicated.TenantAdmin.ServerStub
, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c

**SharePoint 2016/2019**:
Microsoft.Online.SharePoint.Dedicated.TenantAdmin.ServerStub
, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c

In both version set the SupportAppAuthentication property to true.

NOTE2:
An IIS reset needs to be performed on all servers in the farm after
modifying the registered proxy libraries.
