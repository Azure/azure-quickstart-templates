configuration Sample_xHostsFile_RemoveEntry
{
    param
    (
        [string[]]$NodeName = 'localhost'
    )

    Import-DSCResource -ModuleName xNetworking

    Node $NodeName
    {
        xHostsFile HostEntry
        {
          HostName  = 'Host01'
          IPAddress = '192.168.0.1'
          Ensure    = 'Absent'
        }
    }
 }

Sample_xHostsFile_RemoveEntry
Start-DscConfiguration -Path Sample_xHostsFile_RemoveEntry -Wait -Verbose -Force
