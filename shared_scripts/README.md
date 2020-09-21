# Shared Scripts

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/shared_scripts/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/shared_scripts/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/shared_scripts/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/shared_scripts/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/shared_scripts/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/shared_scripts/CredScanResult.svg)

This folder contains a set of reusable scripts to perform tasks that are common across a number of resource templates.  Given the fact that these scripts are used by multiple resource templates, please take care in making changes.  The goal is to promote reuse and have a set of very well tested, reviewed, and resilient scripts to use when performing those common tasks, like formatting a data disk.

##Versioning
- Do not bump the version on the file name when making backwards compatible bug fixes
- Create a copy of the file and bump the minor version when adding functionality that is backwards compatible
- Create a copy of the file and bump the major version when making changes that are not backwards compatible

| Name                        | Author                 | Description                                           |
|:----------------------------|:-----------------------|:------------------------------------------------------|
| ubuntu/vm-disk-utils | [trentmswanson](https://github.com/trentmswanson) | This script automates the partitioning and formatting of data disks as individual disks or in a RAID0 configuration.|

