# Description

**Type:** Distributed
**Requires CredSSP:** No

This resource is used to configure search result sources in the SharePoint
search service application. Result sources can be configured to be of the
following provider types:

* Exchange Search Provider
* Local People Provider
* Local SharePoint Provider
* OpenSearch Provider
* Remote People Provider
* Remote SharePoint Provider

The default value for the Ensure parameter is Present. When not specifying this
parameter, the result source is created.

To define a result source as global, use the value 'SSA' as the ScopeName
value.
