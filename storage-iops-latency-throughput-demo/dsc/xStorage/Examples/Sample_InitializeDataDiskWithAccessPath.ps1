# This configuration will wait for disk 2 to become available, and then make the disk available as
# two new formatted volumes mounted to folders c:\SQLData and c:\SQLLog, with c:\SQLLog using all
# available space after c:\SQLData has been created.
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
