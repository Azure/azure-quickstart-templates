# Mount ISO
configuration MountISO
{
    Import-DscResource -ModuleName xDiskImage
        xMountImage ISO
        {
           Name = 'SQL Disk'
           ImagePath = 'c:\Sources\SQL.iso'
           DriveLetter = 's:'
        }
}

MountISO -out c:\DSC\
Start-DscConfiguration -Wait -Force -Path c:\DSC\ -Verbose


# UnMount ISO
configuration UnMountISO
{
    Import-DscResource -ModuleName xDiskImage
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