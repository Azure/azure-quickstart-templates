#
# Skype2016_Install.ps1
#
Param (		
		[Parameter(Mandatory)]
        [String]$DomainName,

        [Parameter(Mandatory)]
        [string]$Username,

	    [Parameter(Mandatory)]
        [string]$Password,

		[Parameter(Mandatory)]
        [string]$Share,

		[Parameter(Mandatory)]
        [string]$sasToken

       )

$SecurePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force
[PSCredential ]$DomainCreds = New-Object PSCredential ("$DomainName\$Username", $SecurePassword)
$User=$Share
$Share="\\"+$Share+".file.core.windows.net\skype"

#connect to file share on storage account
net use G: $Share /u:$User $sasToken
#copy the setup file
Copy-Item G:\SfB2016\setup.exe C:\
#Install Skype
Start-Process -FilePath cmd -ArgumentList /c, "C:\setup.exe setup", /q -Verb RunAs

net use G: /d