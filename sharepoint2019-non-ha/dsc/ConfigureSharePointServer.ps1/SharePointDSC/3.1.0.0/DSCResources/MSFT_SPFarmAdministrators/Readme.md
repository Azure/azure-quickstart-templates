# Description

**Type:** Common
**Requires CredSSP:** No

This resource is used to manage the membership of the farm administrators
group. There are a number of approaches to how this can be implemented. The
"members" property will set a specific list of members for the group, making
sure that every user/group in the list is in the group and all others that are
members and who are not in this list will be removed. The "MembersToInclude"
and "MembersToExclude" properties will allow you to control a specific set of
users to add or remove, without changing any other members that are in the
group already that may not be specified here, allowing for some manual
management outside of this configuration resource.
