configuration Sample_xDnsClientGlobalSetting_SuffixSearchList
{
    param
    (
        [string[]]$NodeName = 'localhost',

        [Parameter(Mandatory)]
        [string[]]$SuffixSearchList,

        [Parameter(Mandatory)]
        [boolean]$UseDevolution = $true,

        [Parameter(Mandatory)]
        [uint32]$DevolutionLevel = 0
    )

    Import-DscResource -Module xDnsClientGlobalSetting

    Node $NodeName
    {
        xDhcpClient EnableDhcpClient
        {
            IsSingleInstance = 'Yes'
            SuffixSearchList = $SuffixSearchList
            UseDevolution    = $UseDevolution
            DevolutionLevel  = $DevolutionLevel
        }
    }
}

Sample_xDnsClientGlobalSetting_SuffixSearchList -SuffixSearchList 'contoso.com'
Start-DscConfiguration -Path Sample_xDnsClientGlobalSetting_SuffixSearchList -Wait -Verbose -Force
