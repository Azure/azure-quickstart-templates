#this will configure 'show advanced options' option of default instance on local machine

configuration SQLConfigSample
{
    Import-DscResource -ModuleName xSQLServer
    Node 'localhost'
    {
        
        LocalConfigurationManager
        {
            #this option should only be used during testing, remove it in production environment
            DebugMode = 'ForceModuleImport'
        }

        #to get all available options run sp_configure, or refer to https://msdn.microsoft.com/en-us/library/ms189631.aspx
        xSQLServerConfiguration test
        {
            InstanceName = 'MSSQLSERVER'
            OptionName = 'priority boost' 
            OptionValue = 1
            RestartService = $false
        }
    }
}

SQLConfigSample
Set-DscLocalConfigurationManager .\SQLConfigSample -Force -Verbose #only needed if using DebugMode
Start-DscConfiguration .\SQLConfigSample -Wait -Force -Verbose
