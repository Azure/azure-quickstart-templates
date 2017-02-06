# This configuration will unmount an ISO file that is mounted in S:.
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
