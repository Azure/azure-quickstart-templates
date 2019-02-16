# Description

**Type:** Distributed
**Requires CredSSP:** No

This resource is used to add or remove provider realms to
SPTrustedIdentityTokenIssuer in a SharePoint farm. The "ProviderRealms"
property will set a specific list of realms, making sure
that every realm in the list is set and all others that are
already configured but not in this list will be removed.
The "ProviderRealmsToInclude" and "ProviderRealmsToExclude" properties
will allow you to control a specific set of realms to add or remove,
without changing any other realms that are set already. Include and
Exclude can be combined together. RealmUrl is the key and should be
unique, otherwise existing RealmUrn value will be updated/replaced.
