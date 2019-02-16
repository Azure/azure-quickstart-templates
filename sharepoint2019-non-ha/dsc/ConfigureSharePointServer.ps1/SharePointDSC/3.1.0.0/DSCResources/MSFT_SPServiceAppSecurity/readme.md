# Description

**Type:** Distributed
**Requires CredSSP:** No

This resource is used to manage the sharing security settings of a specific
service application. There are a number of approaches to how this can be
implemented. Firstly you can set permissions for the app administrators, or
for the sharing permission by specifying the SecurityType attribute. These
options correlate to the buttons seen in the ribbon on the "manage service
applications" page in Central Administration after you select a specific
service app. The "Members" property will set a specific list of members for
the service app, making sure that every user/group in the list is in the group
and all others that are members and who are not in this list will be removed.
The "MembersToInclude" and "MembersToExclude" properties will allow you to
control a specific set of users to add or remove, without changing any other
members that are in the group already that may not be specified here, allowing

NOTE:
In order to specify Local Farm you can use the token "\{LocalFarm\}"
as the username. The token is case sensitive.

## Permission overview

Available permissions for Administrators are Full Control except for these
service applications:

Secure Store Service Application:

- Full Control
- Create Target Application
- Delete Target Application
- Manage Target Application
- All Target Applications

User Profile Service Application:

- Full Control
- Manage Profiles
- Manage Audiences
- Manage Permissions
- Retrieve People Data for Search Crawlers
- Manage Social Data

Search Service Application:

- Full Control
- Read (Diagnostics Pages Only)

Permissions for Sharing Permissions are Full Control except for these
service applications:

Managed Metadata Service Application:

- Read Access to Term Store
- Read and Restricted Write Access to Term Store
- Full Access to Term Store

NOTE:
Multiple permissions can be specified for each principal. Full Control
will include all other permissions. It is not required to specify all
available permissions if Full Control is specified.
