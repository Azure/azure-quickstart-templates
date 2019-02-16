# Description

**Type:** Distributed
**Requires CredSSP:** No

This resource is responsible for controlling the blocked file type setting on a
specific web application. It has two modes of operation, the first is to use
the "blocked" property, where you are able to define a specific list of file
types that will be blocked. In this mode when it is detected that the list
does not match the local farm, it is set to match this list exactly. The
second mode is to use the "EnsureBlocked" and "EnsureAllowed" properties.
EnsureBlocked will check to make sure that the specified file types are on the
list, and if not they will be added. EnsureAllowed checks to make sure that a
file type is not on the list, and if it is it will be removed. Both of these
properties will only make changes to the file types in their list and will
leave the full list as it is otherwise, whereas the blocked property resets
