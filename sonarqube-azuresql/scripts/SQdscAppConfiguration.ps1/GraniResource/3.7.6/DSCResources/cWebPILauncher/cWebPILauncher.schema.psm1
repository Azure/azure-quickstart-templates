configuration cWebPILauncher
{
    param
    (
        [Parameter(Mandatory = $false, helpMessage = "Install and search from Reg by Get-DSCModuleProductId")]
        [string]$ProductId = "4D84C195-86F0-4B34-8FDE-4A17EB41306A", 

        [Parameter(Mandatory = $false)]
        [string]$InstallerUri = "http://go.microsoft.com/fwlink/?LinkId=255386"
    )

    function Get-RedirectedUrl ([String]$URL)
    { 
        $request = [System.Net.WebRequest]::Create($InstallerUri)
        $request.AllowAutoRedirect = $false
        $response = $request.GetResponse()
        $response | where StatusCode -eq "Found" | % {$_.GetResponseHeader("Location")}
    }

    $name = "Web Platform Installer"
    $DownloadPath = Get-RedirectedUrl $InstallerUri

    Package InstallWebPILauncher
    {
        Name       = $name
        Path       = $DownloadPath
        ReturnCode = 0
        ProductId  = $productId
    }
}
