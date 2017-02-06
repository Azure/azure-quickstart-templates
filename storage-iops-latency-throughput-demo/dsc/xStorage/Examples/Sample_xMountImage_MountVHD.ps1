# This configuration will mount a VHD file and wait for it to become available.
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
