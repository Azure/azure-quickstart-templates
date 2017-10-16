configuration SQLSettings
{   
    Import-DscResource -ModuleName 'xSQLServer'

    Node 'localhost'
    { 
        xSQLServerScript SqlSettings
        {
            ServerInstance = "$env:COMPUTERNAME\SMA"
            SetFilePath = "C:\temp\Set-SQlsettings.sql"
            TestFilePath = "C:\temp\Test-SQlsettings.sql"
            GetFilePath = "C:\temp\Get-SQlsettings.sql"
            Variable = @("FilePath=C:\temp\log\AuditFiles")
        } 
    } 
}

$configData = @{ 
    AllNodes = @(  
        @{ 
            NodeName = 'localhost'
        }
    ) 
}

SQLSettings -ConfigurationData $configData

Start-DscConfiguration -Path .\SQLSettings -Wait -Force -Verbose
