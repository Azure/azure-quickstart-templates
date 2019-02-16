# Description

**Type:** Distributed
**Requires CredSSP:** No

This resource is used to set the User Policies for web applications. The
usernames can be either specified in Classic or Claims format, both will be
accepted. There are a number of approaches to how this can be implemented. The
"Members" property will set a specific list of members for the group, making
sure that every user/group in the list is in the group and all others that are
members and who are not in this list will be removed. The "MembersToInclude"
and "MembersToExclude" properties will allow you to control a specific set of
users to add or remove, without changing any other members that are in the
group already that may not be specified here, allowing for some manual
management outside of this configuration resource.

Requirements:
At least one of the Members, MemberToInclude or MembersToExclude properties
needs to be specified. Do not combine the Members property with the
MemberToInclude and MembersToExclude properties. Do not set the
ActAsSystemAccount property to $true without setting the permission level to
