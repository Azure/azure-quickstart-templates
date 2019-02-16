# Description

**Type:** Distributed
**Requires CredSSP:** No

This resource is responsible for extending an existing web application into a new
zone. The resource will provision the web application extension with all of
the current settings, and then ensure that it stays present and will ensure the
AllowAnonymous and Authentication methods remain consistent. Please note that this
currently does not support changing the claims provider on an existing claims
enabled web application externsion.
