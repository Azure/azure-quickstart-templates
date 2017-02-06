configuration Sample_xRemoteFile_DownloadFileUsingProxy
{
    param
    (
        [string[]] $nodeName = 'localhost',

        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String] $destinationPath,

        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String] $uri,

        [String] $userAgent,

        [Hashtable] $headers,

        [String] $proxy
    )

    Import-DscResource -Name MSFT_xRemoteFile -ModuleName xPSDesiredStateConfiguration

    Node $nodeName
    {
        xRemoteFile DownloadFile
        {
            DestinationPath = $destinationPath
            Uri             = $uri
            UserAgent       = $userAgent
            Headers         = $headers
            Proxy           = $proxy
        }
    }
}

<#
Sample use (parameter values need to be changed according to your scenario):

Sample_xRemoteFile_DownloadFileUsingProxy `
    -destinationPath "$env:SystemDrive\fileName.jpg" `
    -uri "http://www.contoso.com/image.jpg"

Sample_xRemoteFile_DownloadFileUsingProxy `
    -destinationPath "$env:SystemDrive\fileName.jpg" `
    -uri "http://www.contoso.com/image.jpg" `
    -userAgent [Microsoft.PowerShell.Commands.PSUserAgent]::InternetExplorer `
    -headers @{"Accept-Language" = "en-US"} `
    -proxy 'http://10.22.93.1'
#>
