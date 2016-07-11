# Configuration to install Sql server database engine and management tools.
# 
# A. Prepare a local self signed certificate with the following steps:
# 1. Get MakeCert.exe if you don't have. ( MakeCert.exe is shipped with windows SDK: http://msdn.microsoft.com/en-us/windows/desktop/bg162891.aspx)
# 2. Open console with Administrator elevation, run the following:
#     makecert -r -pe -n "CN=DSCDemo" -sky exchange -ss my -sr localMachine

# B. Prepare software and run the configuration.
# 1. On the machine, create a folder as Software
# 2. On the machine, please copy Windows Server 2012 R2 source\sxs to C:\Software\sxs
# 3. copy sql software to C:\Software\sql
# 4. copy xSqlPs to $env:ProgramFiles\WindowsPowershell\Modules
# 5. Copy this file (sql101.ps1) to c:\demo
# 6. in powershell with administrator elevation, go to c:\demo, run .\sql101.ps1


$certSubject = "CN=DSCDemo"
$keysFolder = Join-Path $env:SystemDrive -ChildPath "Keys"
$cert = dir Cert:\LocalMachine\My | ? { $_.Subject -eq $certSubject }
if (! (Test-Path $keysFolder ))
{
    md $keysFolder | Out-Null
}
$certPath = Export-Certificate -Cert $cert -FilePath (Join-Path $keysFolder -ChildPath "Dscdemo.cer")


$ConfigData=
@{
    AllNodes = @(

       @{
           NodeName = "localhost"
           CertificateFile = $certPath
           Thumbprint = $cert.Thumbprint
        }
    )
 }

Configuration Sql101
{
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullorEmpty()]
        [PsCredential] $credential
        )

    Import-DscResource -Module xSqlPs

   Node $AllNodes.NodeName
   {
    
    # Install SQL Server
    WindowsFeature installdotNet35
    {            
        Ensure = "Present"
        Name = "Net-Framework-Core"
        Source = "c:\software\sxs"
    }
        
    xSqlServerInstall installSqlServer
    {
        InstanceName = "PowerPivot"

        SourcePath = "c:\software\sql"
            
        Features= "SQLEngine,SSMS"

        SqlAdministratorCredential = $credential

        DependsOn = "[WindowsFeature]installdotNet35"
    }

    LocalConfigurationManager 
    { 
        CertificateId = $node.Thumbprint 
    } 
 }    
}

Sql101 -ConfigurationData $ConfigData -OutputPath .\Mof -credential (Get-Credential -UserName "sa" -Message "Enter password for SqlAdministrator sa")

Set-DscLocalConfigurationManager .\Mof

Start-DscConfiguration -Path .\Mof -ComputerName localhost -Wait -Verbose