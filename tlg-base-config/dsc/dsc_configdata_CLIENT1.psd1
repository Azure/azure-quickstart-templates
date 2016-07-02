@{
    AllNodes = @(
        @{
            NodeName = "localhost"
            ServiceRoles = @{
                DomainController = $false
                MemberServer = $true
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