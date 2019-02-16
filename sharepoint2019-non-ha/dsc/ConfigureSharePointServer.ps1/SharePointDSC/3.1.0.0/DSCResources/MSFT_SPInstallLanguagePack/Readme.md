# Description

**Type:** Distributed
**Requires CredSSP:** No

This resource is used to install the SharePoint Language Pack binaries. The
BinaryDir parameter should point to the path that setup.exe is located (not to
setup.exe itself).

The BinaryInstallDays and BinaryInstallTime parameters specify a window in which
the update can be installed.

Starting with SharePoint 2016, the Language Packs are offered as an EXE package.
You have to extract this package before installing, using the following command:
.\serverlanguagepack.exe /extract:[Extract Folder]
