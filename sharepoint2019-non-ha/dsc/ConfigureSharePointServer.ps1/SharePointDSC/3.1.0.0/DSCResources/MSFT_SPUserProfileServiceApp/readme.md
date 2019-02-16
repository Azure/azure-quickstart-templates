# Description

**Type:** Distributed
**Requires CredSSP:** Yes

This resource will provision an instance of the user profile service to the
farm. It creates the required databases using the parameters that are passed
in to it (although these are only used during the initial provisioning).

The specified InstallAccount or PSDSCRunAsCredential cannot be the Farm Account.
The resource will throw an error when it is.

To allow successful provisioning, the farm account must be in the local
administrators group, however it is not best practice to leave this account in
the Administrators group. Therefore this resource will add the Farm Account
credential to the local administrators group at the beginning of the set method
and remove it again later on.

The default value for the Ensure parameter is Present. When not specifying this
parameter, the service application is provisioned.

The parameter SiteNamingConflictResolution accepts three values: Username_CollisionError,
Username_CollisionDomain and Domain_Username. More information on each of these
parameters can be found at:
https://docs.microsoft.com/en-us/dotnet/api/microsoft.office.server.userprofiles.sitenameformat?view=sharepoint-server

NOTE:
Due to the fact that SharePoint requires certain User Profile components to be
provisioned as the Farm account, this resource and SPUserProfileSyncService
retrieve the Farm account from the Managed Accounts.
This does however mean that CredSSP is required, which has some security
implications. More information about these risks can be found at:
http://www.powershellmagazine.com/2014/03/06/accidental-sabotage-beware-of-credssp/
