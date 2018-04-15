[![Build status](https://ci.appveyor.com/api/projects/status/1j95juvceu39ekm7/branch/master?svg=true)](https://ci.appveyor.com/project/PowerShell/xstorage/branch/master)


# xStorage

?The **xStorage** module is a part of the Windows PowerShell Desired State Configuration (DSC) Resource Kit, which is a collection of DSC Resources.

This module contains the **xMountImage, xDisk, and xWaitForDisk** resources.  The xMountImage resource can be used to mount or unmount an ISO/VHD disk image to the local file system, with simple declarative language.  The xDisk and xWaitforDisk resources enable you to wait for a disk to become available and then initialize, format, and bring it online using PowerShell DSC.

**NOTE:** The xDisk resource follows a process to detect the existance of a RAW disk, initialize the disk, create a volume, assign a drive letter of specific size (if provided) or maximum size, then format the new volume using NTFS and assign a volume label if one is provided.
Before beginning that operation, the disk is marked 'Online' and if it is set to 'Read-Only', that property is removed.
While this is intended to be non-destructive, as with all expiremental resources the scripts contained should be thoroughly evaluated and well understood before implementing in a production environment or where disk modifications could result in lost data.

**All of the resources in the DSC Resource Kit are provided AS IS, and are not supported through any Microsoft standard support program or service. The "x" in xDiskImage stands for experimental**, which means that these resources will be **fix forward** and monitored by the module owner(s).

Please leave comments, feature requests, and bug reports in the Q & A tab for
this module.

If you would like to modify this module, feel free. When modifying, please update the module name, resource friendly name, and MOF class name (instructions below). As specified in the license, you may copy or modify this resource as long as they are used on the Windows Platform.

For more information about Windows PowerShell Desired State Configuration, check out the blog posts on the [PowerShell Blog](http://blogs.msdn.com/b/powershell/) ([this](http://blogs.msdn.com/b/powershell/archive/2013/11/01/configuration-in-a-devops-world-windows-powershell-desired-state-configuration.aspx) is a good starting point). There are also great community resources, such as [PowerShell.org](http://powershell.org/wp/tag/dsc/), or [PowerShell Magazine](http://www.powershellmagazine.com/tag/dsc/). For more information on the DSC Resource Kit, checkout [this blog post](http://go.microsoft.com/fwlink/?LinkID=389546).

Installation
------------

To install **xstorage** module

-   If you are using WMF4 / PowerShell Version 4: Unzip the content under $env:ProgramFilesWindowsPowerShellModules folder

-   If you are using WMF5 Preview: From an elevated PowerShell session run ‘Install-Module xDiskImage’

To confirm installation

-   Run Get-DSCResource to see that the resources listed above are among the DSC Resources displayed

Requirements
------------

This module requires the latest version of PowerShell (v4.0, which ships in
Windows 8.1 or Windows Server 2012R2). To easily use PowerShell 4.0 on older
operating systems, install WMF 4.0. Please read the installation instructions
that are present on both the download page and the release notes for WMF 4.0.

Details
-------

**xMountImage** resource has following properties

- **Name**: This setting provides a unique name for the configuration
- **ImagePath**: Specifies the path of the VHD or ISO file
- **DriveLetter**: Specifies the drive letter after the ISO is mounted
- **Ensure**: Determines whether the setting should be applied or removed

**xDisk** resource has following properties:

*   **DiskNumber**: Specifies the identifier for which disk to modify.
*   **DriveLetter**: Specifies the preffered letter to assign to the disk volume.
*   **Size**: Specifies the size of new volume (use all available space on disk if not provided).
*   **FSLabel**: Define volume label if required.
*   **AllocationUnitSize**: Specifies the allocation unit size to use when formatting the volume.


**xWaitforDisk** resource has following properties:

*   **DiskNumber**: Specifies the identifer for which disk to wait for.
*   **RetryIntervalSec**: Specifies the number of secods to wait for the disk to become available.
*   **RetryCount**: The number of times to loop the retry interval while waiting for the disk.

Renaming Requirements
---------------------

When making changes to these resources, we suggest the following practice

1. Update the following names by replacing MSFT with your company/community name
and replacing the **"x" with **"c" (short for "Community") or another prefix of your
choice
 -	Module name (ex: xModule becomes cModule)
 -	Resource folder (ex: MSFT\_xResource becomes Contoso\_xResource)
 -	Resource Name (ex: MSFT\_xResource becomes Contoso\_cResource)
 -	Resource Friendly Name (ex: xResource becomes cResource)
 -	MOF class name (ex: MSFT\_xResource becomes Contoso\_cResource)
 -	Filename for the <resource\>.schema.mof (ex: MSFT\_xResource.schema.mof becomes Contoso\_cResource.schema.mof)

2. Update module and metadata information in the module manifest  
3. Update any configuration that use these resources

We reserve resource and module names without prefixes ("x" or "c") for future use (e.g. "MSFT_Resource"). If the next version of Windows Server ships with a "DiskImage" resource, we don't want to break any configurations that use any community modifications. Please keep a prefix such as "c" on all community modifications.

## Versions

### Unreleased

### 2.4.0.0

* Fixed bug where AllocationUnitSize was not used

### 2.3.0.0

* Added support for `AllocationUnitSize` in `xDisk`.

### 2.2.0.0

* Updated documentation: changed parameter name Count to RetryCount in xWaitForDisk resource

### 2.1.0.0

* Fixed encoding

### 2.0.0.0

* Breaking change: Added support for following properties: DriveLetter, Size, FSLabel. DriveLetter is a new key property.

### 1.0.0.0
This module was previously named **xDisk**, the version is regressing to a "1.0.0.0" release with the addition of xMountImage.

* Initial release of xStorage module with following resources (contains resources from deprecated xDisk module):
* xDisk (from xDisk)
* xMountImage
* xWaitForDisk (from xDisk)


Examples
--------

**Example 1**:  Wait for disk 2 to become available, and then make the disk available as two new formatted volumes, with J using all available space after 'G' has been created.


```powershell
Configuration DataDisk
{
    
    Import-DSCResource -ModuleName xStorage
 
    Node localhost
    {
        xWaitforDisk Disk2
        {
             DiskNumber = 2
             RetryIntervalSec = 60
             Count = 60
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
			 FSLabel = 'Data
			 DependsOn = [xDisk]GVolume
        }
        
        xDisk DataVolume
        {
             DiskNumber = 3
             DriveLetter = 'S'
			 Size = 100GB
             AllocationUnitSize = 64kb
        }
    }
}
 
DataDisk -outputpath C:\DataDisk
Start-DscConfiguration -Path C:\DataDisk -Wait -Force -Verbose
```

**Example 2**:  Mount ISO as local drive S

```powershell
    # Mount ISO
    configuration MountISO
    {
        Import-DscResource -ModuleName xStorage
            xMountImage ISO
            {
               Name = 'SQL Disk'
               ImagePath = 'c:\Sources\SQL.iso'
               DriveLetter = 's:'
            }
    }

    MountISO -out c:\DSC\
    Start-DscConfiguration -Wait -Force -Path c:\DSC\ -Verbose
```

**Example 3**:  UnMount ISO file and remove drive letter

```powershell
    # UnMount ISO
    configuration UnMountISO
    {
        Import-DscResource -ModuleName xStorage
            xMountImage ISO
            {
               Name = 'SQL Disk'
               ImagePath = 'c:\Sources\SQL.iso'
               DriveLetter = 's:'
               Ensure = 'Absent'
            }
    }

    UnMountISO -out c:\DSC\
    Start-DscConfiguration -Wait -Force -Path c:\DSC\ -Verbose
```

## Contributing
Please check out common DSC Resources [contributing guidelines](https://github.com/PowerShell/DscResource.Kit/blob/master/CONTRIBUTING.md).

