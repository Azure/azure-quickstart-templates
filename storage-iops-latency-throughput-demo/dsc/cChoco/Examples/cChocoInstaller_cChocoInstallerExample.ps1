Configuration InstallChoco
{
    Import-DscResource -Module cChoco  
    Node "localhost"
    {
        cChocoInstaller InstallChoco
        {
            InstallDir = "c:\choco"
        }
        cChocoPackageInstaller installSkypeWithChocoParams
        {
            Name                 = 'skype'
            Ensure               = 'Present'
            DependsOn            = '[cChocoInstaller]installChoco'
        }
    }
} 

$config = InstallChoco

Start-DscConfiguration -Path $config.psparentpath -Wait -Verbose -Force