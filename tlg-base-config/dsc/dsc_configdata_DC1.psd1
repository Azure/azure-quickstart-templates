@{
    AllNodes = @(
        @{
            NodeName = "localhost"
            ServiceRoles = @{
                DomainController = $true
                MemberServer = $false
                WebServer = $false
            }
        }
    )
    NonNodeData = @{
        DomainDetails = @{
            DomainName = "corp.contoso.com"
            NetbiosName = "CORP"
            DatabasePath = "F:\NTDS"
            SysvolPath = "F:\SYSVOL"
        }
    }
}