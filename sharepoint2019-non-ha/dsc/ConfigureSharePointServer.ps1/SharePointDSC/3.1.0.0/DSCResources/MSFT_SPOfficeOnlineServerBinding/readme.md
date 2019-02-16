# Description

**Type:** Distributed
**Requires CredSSP:** No

This resource will create a binding to an Office Online Server (formerly known
as Office Web Apps). The DnsName property can be a single server name, or a
FQDN of a load balanced end point that will direct traffic to a farm.

NOTE:
This resource is designed to be used where all WOPI bindings will be
targeted to the same Office Online Server farm. If used on a clean
environment, the new bindings will all point to the one DNS Name. If used on
an existing configuration that does not follow this rule, it will match only

The default value for the Ensure parameter is Present. When not specifying this
parameter, the zone is configured.
