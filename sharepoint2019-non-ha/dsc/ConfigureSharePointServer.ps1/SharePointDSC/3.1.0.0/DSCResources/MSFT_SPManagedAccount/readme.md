# Description

**Type:** Distributed
**Requires CredSSP:** No

This resource will ensure a managed account is provisioned in to the SharePoint
farm. The Account object specific the credential to store (including username
and password) to set as the managed account. The settings for
EmailNotification, PreExpireDays and Schedule all relate to enabling automatic
password change for the managed account, leaving these option out of the
resource will ensure that no automatic password changing from SharePoint occurs.

The default value for the Ensure parameter is Present. When not specifying this
parameter, the managed account is created.
