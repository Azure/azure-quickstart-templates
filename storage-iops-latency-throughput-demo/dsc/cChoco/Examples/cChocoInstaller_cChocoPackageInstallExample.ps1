Configuration InstallChoco
{
    Import-DscResource -Module cChoco  
    Node "localhost"
    {
        cChocoPackageInstaller installSkypeWithChocoParams
        {
            Name                 = 'skype'
            Ensure               = 'Present'
            AutoUpgrade          = $True       
        }
    }
} 

$config = InstallChoco

Start-DscConfiguration -Path $config.psparentpath -Wait -Verbose -Force