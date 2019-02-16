# Description

**Type:** Common
**Requires CredSSP:** No

This resource is used to install the SharePoint binaries. The BinaryDir
parameter should point to the path that setup.exe is located (not to setup.exe
itself). The ProductKey parameter is used to inject in to the configuration
file and validate the license key during the installation process. This module
depends on the prerequisites already being installed, which can be done

NOTE:
This resource only supports SharePoint Server. SharePoint Foundation
is not supported. For examples to install SharePoint Foundation using DSC, see:
https://github.com/PowerShell/SharePointDsc/wiki/SPInstall (Example 3)

## Installing from network locations

If you wish to install SharePoint from a network location this can
be done, however you must disable User Account Control (UAC) on the server
to allow DSC to run the executable from a remote location, and also set
the PsDscRunAsCredential value to run as an account with local admin
permissions as well as read access to the network location.

It is *not recommended* to disable UAC for security reasons. The recommended
approach is to copy the installation media to the local nodes first and
then execute the installation from there.

## Multilingual support

Where possible, resources in SharePointDsc have been written in a way that
they should support working with multiple language packs for multilingual
deployments. However due to constraints in how we set up and install the
product, only English ISOs are supported for installing SharePoint.
