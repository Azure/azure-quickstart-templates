# Description

**Type:** Common
**Requires CredSSP:** No

This resource is used to perform the update step of installing SharePoint
updates, like Cumulative Updates and Service Packs. The SetupFile parameter
should point to the update file. The ShutdownServices parameter is used to
indicate if some services (Timer, Search and IIS services) have to be stopped
before installation of the update. This will speed up the installation. The
BinaryInstallDays and BinaryInstallTime parameters specify a window in which
the update can be installed. This module requires the Configuration Wizard
resource to fully complete the installation of the update, which can be done
through the use of SPConfigWizard.

NOTE:
When files are downloaded from the Internet, a Zone.Identifier alternate data
stream is added to indicate that the file is potentially from an unsafe source.
To use these files, make sure you first unblock them using Unblock-File.
SPProductUpdate will throw an error when it detects the file is blocked.

IMPORTANT:
This resource retrieves build information from the Configuration Database.
Therefore it requires SharePoint to be installed and a farm created. If you
like to deploy a new farm and install updates automatically, you need to
implement the following order:

1. Install the SharePoint Binaries (SPInstall)
2. (Optional) Install SharePoint Language Pack(s) Binaries
   (SPInstallLanguagePack)
3. Create SPFarm (SPFarm)
4. Install Cumulative Updates (SPProductUpdate)
5. Run the Configuration Wizard (SPConfigWizard)
