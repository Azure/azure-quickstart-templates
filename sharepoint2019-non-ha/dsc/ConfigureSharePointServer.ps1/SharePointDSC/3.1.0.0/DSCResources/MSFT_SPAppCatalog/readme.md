# Description

**Type:** Distributed
**Requires CredSSP:** Yes

This resource will ensure that a specific site collection is marked as the app
catalog for the web application that the site is in. The catalog site needs to
have been created using the correct template (APPCATALOG#0).

This resource should NOT be run using the farm account. The resource will
retrieve the farm credentials from SharePoint and use that to update the
AppCatalog. This does mean it requires CredSSP to be setup!
