# Description

**Type:** Utility
**Requires CredSSP:** No

This resource will help manage compliance of MinRole based servers. Each time
the resource runs it will investigate which service instances should be running
based on the role of servers anywhere in the farm, and if they are not in a
compliant state it will tell SharePoint to create timer jobs to make the
necesssary modifications to make the farm compliant again.
