configuration Sample_xHostsFile_AddEntry
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
          Ensure    = 'Present'
        }
    }
 }

Sample_xHostsFile_AddEntry
Start-DscConfiguration -Path Sample_xHostsFile_AddEntry -Wait -Verbose -Force
