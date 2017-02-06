# xStorage

[![Build status](https://ci.appveyor.com/api/projects/status/1j95juvceu39ekm7/branch/master?svg=true)](https://ci.appveyor.com/project/PowerShell/xstorage/branch/master)

The **xStorage** module is a part of the Windows PowerShell Desired State Configuration (DSC) Resource Kit, which is a collection of DSC Resources.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

This module contains the **xMountImage, xDisk, and xWaitForDisk** resources.  The xMountImage resource can be used to mount or unmount an ISO/VHD disk image to the local file system, with simple declarative language.  The xDisk and xWaitforDisk resources enable you to wait for a disk to become available and then initialize, format, and bring it online using PowerShell DSC.

**NOTE:** The xDisk resource follows a process to detect the existance of a RAW disk, initialize the disk, create a volume, assign a drive letter of specific size (if provided) or maximum size, then format the new volume using NTFS and assign a volume label if one is provided.
Before beginning that operation, the disk is marked 'Online' and if it is set to 'Read-Only', that property is removed.
While this is intended to be non-destructive, as with all experimental resources the scripts contained should be thoroughly evaluated and well understood before implementing in a production environment or where disk modifications could result in lost data.

**All of the resources in the DSC Resource Kit are provided AS IS, and are not supported through any Microsoft standard support program or service. The "x" in xStorage stands for experimental**, which means that these resources will be **fix forward** and monitored by the module owner(s).

Please leave comments, feature requests, and bug reports in the Q & A tab for this module.

If you would like to modify this module, feel free. When modifying, please update the module name, resource friendly name, and MOF class name (instructions below). As specified in the license, you may copy or modify this resource as long as they are used on the Windows Platform.

For more information about Windows PowerShell Desired State Configuration, check out the blog posts on the [PowerShell Blog](http://blogs.msdn.com/b/powershell/) ([this](http://blogs.msdn.com/b/powershell/archive/2013/11/01/configuration-in-a-devops-world-windows-powershell-desired-state-configuration.aspx) is a good starting point). There are also great community resources, such as [PowerShell.org](http://powershell.org/wp/tag/dsc/), or [PowerShell Magazine](http://www.powershellmagazine.com/tag/dsc/). For more information on the DSC Resource Kit, checkout [this blog post](http://go.microsoft.com/fwlink/?LinkID=389546).

## Installation

To install the **xStorage** module

- If you are using WMF4 / PowerShell Version 4: Unzip the content under $env:ProgramFilesWindowsPowerShellModules folder

- If you are using WMF5 Preview: From an elevated PowerShell session run ```Install-Module xStorage```

To confirm installation

- Run Get-DSCResource to see that the resources listed above are among the DSC Resources displayed

## How to Contribute

If you would like to contribute to this repository, please read the DSC Resource Kit [contributing guidelines](https://github.com/PowerShell/DscResource.Kit/blob/master/CONTRIBUTING.md).

## Resources

- **xMountImage**: used to mount or unmount an ISO/VHD disk image. It can be mounted as read-only (ISO, VHD, VHDx) or read/write (VHD, VHDx).
- **xDisk**: used to initialize, format and mount the partition as a drive letter.
- **xDiskAccessPath**: used to initialize, format and mount the partition to a folder access path.
- **xWaitForDisk** wait for a disk to become available.
- **xWaitForVolume** wait for a drive to be mounted and become available.

### xMountImage

- **`[String]` ImagePath** _(Key)_: Specifies the path of the VHD or ISO file.
- **`[String]` DriveLetter** _(Write)_: Specifies the drive letter to mount this VHD or ISO to. Must be empty if Ensure is Absent.
- **`[String]` StorageType** _(Write)_: Specifies the storage type of a file. If the StorageType parameter is not specified, then the storage type is determined by file extension. { ISO | VHD | VHDx | VHDSet }.
- **`[String]` Access** _(Write)_: Allows a VHD file to be mounted in read-only or read-write mode. ISO files are mounted in read-only mode regardless of what parameter value you provide. { ReadOnly | ReadWrite }.
- **`[String]` Ensure** _(Write)_: Determines whether the VHD or ISO should be mounted or not. { *Present* | Absent }. Defaults to Present.

### xDisk

- **`[String]` DriveLetter** _(Key)_: Specifies the preferred letter to assign to the disk volume.
- **`[UInt32]` DiskNumber** _(Required)_: Specifies the disk number for which disk to modify.
- **`[Uint64]` Size** _(Write)_: Specifies the size of new volume (use all available space on disk if not provided).
- **`[String]` FSLabel** _(Write)_: Define volume label if required.
- **`[UInt32]` AllocationUnitSize** _(Write)_: Specifies the allocation unit size to use when formatting the volume.
- **`[String]` FSFormat** _(Write)_: Define file system type if required. { *NTFS* | ReFS }. Defaults to NTFS.

### xDiskAccessPath

- **`[String]` AccessPath** _(Key)_: Specifies the access path folder to the assign the disk volume to.
- **`[UInt32]` DiskNumber** _(Required)_: Specifies the disk number for which disk to modify.
- **`[Uint64]` Size** _(Write)_: Specifies the size of new volume (use all available space on disk if not provided).
- **`[String]` FSLabel** _(Write)_: Define volume label if required.
- **`[UInt32]` AllocationUnitSize** _(Write)_: Specifies the allocation unit size to use when formatting the volume.
- **`[String]` FSFormat** _(Write)_: Define volume label if required. { *NTFS* | ReFS }. Defaults to NTFS.

### xWaitforDisk

- **`[UInt32]` DiskNumber** _(Key)_: Specifies the identifier for which disk to wait for.
- **`[UInt64]` RetryIntervalSec** _(Write)_: Specifies the number of seconds to wait for the disk to become available. Defaults to 10 seconds.
- **`[UInt32]` RetryCount** _(Write)_: The number of times to loop the retry interval while waiting for the disk. Defaults to 60 times.

### xWaitForVolume

- **`[String]` DriveLetter** _(Key)_: Specifies the name of the drive to wait for.
- **`[UInt64]` RetryIntervalSec** _(Write)_: Specifies the number of seconds to wait for the drive to become available. Defaults to 10 seconds.
- **`[UInt32]` RetryCount** _(Write)_: The number of times to loop the retry interval while waiting for the drive. Defaults to 60 times.

## Versions

### Unreleased

### 2.9.0.0

- Updated readme.md to remove markdown best practice rule violations.
- Updated readme.md to match DSCResources/DscResource.Template/README.md.
- xDiskAccessPath:
  - Fix bug when re-attaching disk after mount point removed or detatched.
  - Additional log entries added for improved diagnostics.
  - Additional integration tests added.
  - Improve timeout loop.
- Converted integration tests to use ```$TestDrive``` as working folder or ```temp``` folder when persistence across tests is required.
- Suppress ```PSUseShouldProcessForStateChangingFunctions``` rule violations in resources.
- Rename ```Test-AccessPath``` function to ```Assert-AccessPathValid```.
- Rename ```Test-DriveLetter``` function to ```Assert-DriveLetterValid```.
- Added ```CommonResourceHelper.psm1``` module (based on PSDscResources).
- Added ```CommonTestsHelper.psm1``` module  (based on PSDscResources).
- Converted all modules to load localization data using ```Get-LocalizedData``` from CommonResourceHelper.
- Converted all exception calls and tests to use functions in ```CommonResourceHelper.psm1``` and ```CommonTestsHelper.psm1``` respectively.
- Fixed examples:
  - Sample_InitializeDataDisk.ps1
  - Sample_InitializeDataDiskWithAccessPath.ps1
  - Sample_xMountImage_DismountISO.ps1
- xDisk:
  - Improve timeout loop.

### 2.8.0.0

- added test for existing file system and no drive letter assignment to allow simple drive letter assignment in MSFT_xDisk.psm1
- added unit test for volume with existing partition and no drive letter assigned for MSFT_xDisk.psm1
- xMountImage: Fixed mounting disk images on Windows 10 Anniversary Edition
- Updated to meet HQRM guidelines.
- Moved all strings into localization files.
- Fixed examples to import xStorage module.
- Fixed Readme.md layout issues.
- xWaitForDisk:
  - Added support for setting DriveLetter parameter with or without colon.
  - MOF Class version updated to 1.0.0.0.
- xWaitForVolume:
  - Added new resource.
- StorageCommon:
  - Added helper function module.
  - Corrected name of unit tests file.
- xDisk:
  - Added validation of DriveLetter parameter.
  - Added support for setting DriveLetter parameter with or without colon.
  - Removed obfuscation of drive/partition errors by eliminating try/catch block.
  - Improved code commenting.
  - Reordered tests so they are in same order as module functions to ease creation.
  - Added FSFormat parameter to allow disk format to be specified.
  - Size or AllocationUnitSize mismatches no longer trigger Set-TargetResource because these values can't be changed (yet).
  - MOF Class version updated to 1.0.0.0.
  - Unit tests changed to match xDiskAccessPath methods.
  - Added additional unit tests to Get-TargetResource.
  - Fixed bug in Get-TargetResource when disk did not contain any partitions.
  - Added missing cmdletbinding() to functions.
- xMountImage (Breaking Change):
  - Removed Name parameter (Breaking Change)
  - Added validation of DriveLetter parameter.
  - Added support for setting DriveLetter parameter with or without colon.
  - MOF Class version updated to 1.0.0.0.
  - Enabled mounting of VHD/VHDx/VHDSet disk images.
  - Added StorageType and Access parameters to allow mounting VHD and VHDx disks as read/write.
- xDiskAccessPath:
  - Added new resource.
  - Added support for changing/setting volume label.

### 2.7.0.0

- Converted appveyor.yml to install Pester from PSGallery instead of from Chocolatey.

### 2.6.0.0

- MSFT_xDisk: Replaced Get-WmiObject with Get-CimInstance

### 2.5.0.0

- added test for existing file system to allow simple drive letter assignment in MSFT_xDisk.psm1
- modified Test verbose message to correctly reflect blocksize value in MSFT_xDisk.psm1 line 217
- added unit test for new volume with out existing partition for MSFT_xDisk.psm1
- Fixed error propagation

### 2.4.0.0

- Fixed bug where AllocationUnitSize was not used

### 2.3.0.0

- Added support for `AllocationUnitSize` in `xDisk`.

### 2.2.0.0

- Updated documentation: changed parameter name Count to RetryCount in xWaitForDisk resource

### 2.1.0.0

- Fixed encoding

### 2.0.0.0

- Breaking change: Added support for following properties: DriveLetter, Size, FSLabel. DriveLetter is a new key property.

### 1.0.0.0

This module was previously named **xDisk**, the version is regressing to a "1.0.0.0" release with the addition of xMountImage.

- Initial release of xStorage module with following resources (contains resources from deprecated xDisk module):
- xDisk (from xDisk)
- xMountImage
- xWaitForDisk (from xDisk)


## Examples

### Example - xWaitForDisk, xDisk

This configuration will wait for disk 2 to become available, and then make the disk available as two new formatted volumes, 'G' and 'J', with 'J' using all available space after 'G' has been created.
It also creates a new ReFS formated volume on Disk 3 attached as drive letter 'S'.

```powershell
Configuration Sample_DataDisk
{

    Import-DSCResource -ModuleName xStorage

    Node localhost
    {
        xWaitforDisk Disk2
        {
             DiskNumber = 2
             RetryIntervalSec = 60
             RetryCount = 60
        }

        xDisk GVolume
        {
             DiskNumber = 2
             DriveLetter = 'G'
             Size = 10GB
        }

        xDisk JVolume
        {
             DiskNumber = 2
             DriveLetter = 'J'
             FSLabel = 'Data'
             DependsOn = '[xDisk]GVolume'
        }

        xDisk DataVolume
        {
             DiskNumber = 3
             DriveLetter = 'S'
             Size = 100GB
             FSFormat = 'ReFS'
             AllocationUnitSize = 64KB
        }
    }
}

DataDisk -outputpath C:\Sample_DataDisk
Start-DscConfiguration -Path C:\Sample_DataDisk -Wait -Force -Verbose
```

### Example - xWaitForDisk, xDiskAccessPath

This configuration will wait for disk 2 to become available, and then make the disk available as two new formatted volumes mounted to folders c:\SQLData and c:\SQLLog, with c:\SQLLog using all available space after c:\SQLData has been created.

```powershell
Configuration Sample_DataDiskwithAccessPath
{

    Import-DSCResource -ModuleName xStorage

    Node localhost
    {
        xWaitforDisk Disk2
        {
             DiskNumber = 2
             RetryIntervalSec = 60
             RetryCount = 60
        }

        xDiskAccessPath DataVolume
        {
             DiskNumber = 2
             AccessPath = 'c:\SQLData'
             Size = 10GB
             FSLabel = 'SQLData1'
        }

        xDiskAccessPath LogVolume
        {
             DiskNumber = 2
             AccessPath = 'c:\SQLLog'
             FSLabel = 'SQLLog1'
             DependsOn = '[xDisk]DataVolume'
        }
    }
}

DataDisk -outputpath C:\Sample_DataDiskwithAccessPath
Start-DscConfiguration -Path C:\Sample_DataDiskwithAccessPath -Wait -Force -Verbose
```

### Example - xMountImage ISO

This configuration will mount an ISO file as drive S:.

```powershell
configuration Sample_xMountImage_MountISO
{
    Import-DscResource -ModuleName xStorage
    xMountImage ISO
    {
        ImagePath   = 'c:\Sources\SQL.iso'
        DriveLetter = 'S'
    }

    xWaitForVolume WaitForISO
    {
        DriveLetter      = 'S'
        RetryIntervalSec = 5
        RetryCount       = 10
    }
}

Sample_xMountImage_MountISO
Start-DscConfiguration -Path Sample_xMountImage_MountISO -Wait -Force -Verbose

```

### Example - xDismountImage

This configuration will unmount an ISO file that is mounted in S:.

```powershell
configuration Sample_xMountImage_DismountISO
{
    Import-DscResource -ModuleName xStorage
    xMountImage ISO
    {
        ImagePath = 'c:\Sources\SQL.iso'
        DriveLetter = 'S'
        Ensure = 'Absent'
    }
}

Sample_xMountImage_DismountISO
Start-DscConfiguration -Path Sample_xMountImage_DismountISO -Wait -Force -Verbose
```

### Example - xMountImage VHD

This configuration will mount a VHD file and wait for it to become available.

```powershell
configuration Sample_xMountImage_MountVHD
{
    Import-DscResource -ModuleName xStorage
    xMountImage MountVHD
    {
        ImagePath   = 'd:\Data\Disk1.vhd'
        DriveLetter = 'V'
    }

    xWaitForVolume WaitForVHD
    {
        DriveLetter      = 'V'
        RetryIntervalSec = 5
        RetryCount       = 10
    }
}

Sample_xMountImage_MountVHD
Start-DscConfiguration -Path Sample_xMountImage_MountVHD -Wait -Force -Verbose
```
