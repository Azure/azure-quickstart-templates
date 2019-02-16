# Description

**Type:** Distributed
**Requires CredSSP:** No

Creates a managed metadata service application. The application pool property
specifies which application pool it should use, and will reset the application
back to this pool if it is changed after its initial provisioning. The
database server and database name properties are only used during
provisioning, and will not be altered as part of the ongoing operation of the
set method.

The default value for the Ensure parameter is Present. When not specifying this
parameter, the service application is provisioned.

The content type hub url will be set or reset.

The language settings (default and working) are only changed if they are part of
the bound parameters. Otherwise they will not be altered.

ContentTypePushdownEnabled and ContentTypeSyndicationEnabled will only be altered
if they are part of the bound parameters.
