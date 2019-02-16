# Description

**Type:** Common
**Requires CredSSP:** No

This resource is responsible for ensuring the installation of all SharePoint
prerequisites. It makes use of the PrerequisiteInstaller.exe file that is part
of the SharePoint binaries, and will install the required Windows features as
well as additional software. The OnlineMode boolean will tell the prerequisite
installer which mode to run in, if it is online you do not need to list any
other parameters for this resource. If you do not use online mode, you must
include all other parameters to specify where the installation files are
located. These additional parameters map directly to the options passed to
prerequisiteinstaller.exe. For installations with no connectivity to Windows
Update, use the SXSpath parameter to specify the path to the SXS store of your
Windows Server install media.

Additionally, the process of installing the prerequisites on a Windows Server
usually results in 2-3 restarts of the system being required. To ensure the
DSC configuration is able to restart the server when needed, ensure the below
settings for the local configuration manager are included in your DSC file.

    LocalConfigurationManager
    {
        RebootNodeIfNeeded = $true
    }

## Installing from network locations

If you wish to install the prerequisites from a network location this can
be done, however you must disable User Account Control (UAC) on the server
to allow DSC to run the executable from a remote location, and also set
the PsDscRunAsCredential value to run as an account with local admin
permissions as well as read access to the network location.

It is *not recommended* to disable UAC for security reasons. The recommended
approach is to copy the installation media to the local nodes first and
then execute the installation from there.

## Downloading prerequisites

The SharePoint prerequisites can be downloaded from the following locations:

SharePoint 2013:
https://docs.microsoft.com/en-us/SharePoint/install/hardware-and-software-requirements-0#section5

SharePoint 2016:
https://docs.microsoft.com/en-us/SharePoint/install/hardware-and-software-requirements#section5

SharePoint 2019:
https://docs.microsoft.com/en-us/sharepoint/install/hardware-and-software-requirements-2019#links-to-applicable-software
