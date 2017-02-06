Configuration FileUploadConfiguration
{
param (
    [parameter(Mandatory = $true)]
    [String] $destinationPath,
    [parameter(Mandatory = $true)]
    [String] $sourcePath,
    [PSCredential] $credential,
    [String] $certificateThumbprint
)

Import-DscResource -modulename xPSDesiredStateConfiguration
node localhost 
{
    xFileUpload fileUpload 
    {
        destinationPath = $destinationPath
        sourcePath = $sourcePath
        credential = $credential
        certificateThumbprint = $certificateThumbprint
    }
}

}

#Sample use (please change values of parameters according to your scenario):

#$credential = New-Object System.Management.Automation.PSCredential -ArgumentList "domain\user", (ConvertTo-SecureString -String "password" -AsPlainText -Force)
#$certificateThumbprint = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
#FileUploadConfiguration -destinationPath "\\machinename\folder" -sourcePath "C:\folder\file.txt" -credential $credential -certificateThumbprint $certificateThumbprint
#Start-DscConfiguration -Path .\FileUploadConfiguration -wait -verbose -debug
