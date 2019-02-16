# Description

**Type:** Specific
**Requires CredSSP:** Yes

This resource is responsible for ensuring that the user profile sync service
has been provisioned (Ensure = "Present") or is not running (Ensure =
"Absent") on the current server.

The specified InstallAccount or PSDSCRunAsCredential cannot be the Farm Account.
The resource will throw an error when it is.

To allow successful provisioning, the farm account must be in the local
administrators group, however it is not best practice to leave this account in
the Administrators group. Therefore this resource will add the Farm Account
credential to the local administrators group at the beginning of the set method
and remove it again later on.

The default value for the Ensure parameter is Present. When not specifying this
parameter, the user profile sync service is provisioned.

NOTE:
Due to the fact that SharePoint requires certain User Profile components to be
provisioned as the Farm account, this resource and SPUserProfileServiceApp
retrieve the Farm account from the Managed Accounts.
This does however mean that CredSSP is required, which has some security
implications. More information about these risks can be found at:
http://www.powershellmagazine.com/2014/03/06/accidental-sabotage-beware-of-credssp/
