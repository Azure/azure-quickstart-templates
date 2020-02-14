# download and unzip the ROS to the desired location
$outputPath = Join-Path $(Get-Location) -ChildPath "output"
$downloadPath = Join-Path $outputPath -ChildPath "sfx-installer.zip"
$vcRedistPath = Join-Path $outputPath -ChildPath "vc_redist.x64.exe"

$latestBuildUrl = 'https://dev.azure.com/ros-win/ros-win/_apis/build/builds?definitions=54&$top=1&resultFilter=succeeded&api-version=5.1'
$vcRedistUrl = 'https://aka.ms/vs/16/release/vc_redist.x64.exe'

New-Item -ItemType directory -Path $outputPath

$retryCount = 3
$retries = 1
Write-Verbose "Downloading ROS install files" -verbose
do
{
    try
    {
        $response = Invoke-RestMethod $latestBuildUrl -Method Get -ContentType 'application/json'
        $buildId = $response.value[0].id

        $artifactUrl = "https://ros-win.visualstudio.com/bed058dd-46da-4029-bb85-25eae7674d09/_apis/build/builds/$buildId/artifacts?artifactName=sfx-installer&api-version=5.2-preview.5&%24format=zip"

        $download = New-Object net.webclient
        $download.Downloadfile($artifactUrl, $downloadPath)
        $download.DownloadFile($vcRedistUrl, $vcRedistPath)
        Write-Verbose "Downloaded install files successfully on attempt $retries" -verbose
        break
    }
    catch
    {
        $exceptionText = ($_ | Out-String).Trim()
        Write-Verbose "Exception occured downloading install files: $exceptionText in try number $retries" -verbose
        $retries++
        Start-Sleep -Seconds 30
    }
}
while ($retries -le $retryCount)

Expand-Archive -path $downloadPath -destinationpath $outputPath
$sfxPath = Join-Path $outputPath -ChildPath "sfx-installer/ros-melodic-desktop_full.exe"

Write-Verbose "Installing Visual C++ redistributable packages" -verbose
Start-Process "$vcRedistPath" -ArgumentList "/q","/norestart","/log","vcredistinstall.log" -NoNewWindow -Wait

Write-Verbose "Installing ROS binaries" -verbose
Start-Process "$sfxPath" -ArgumentList "-oc:\","-y" -NoNewWindow -Wait

# finally enable RemotePS
Enable-PSRemoting -Force -SkipNetworkProfileCheck
New-NetFirewallRule -Name "Allow WinRM HTTPS" -DisplayName "WinRM HTTPS" -Enabled True -Profile Any -Action Allow -Direction Inbound -LocalPort 5986 -Protocol TCP
$thumbprint = (New-SelfSignedCertificate -DnsName $env:COMPUTERNAME -CertStoreLocation Cert:\LocalMachine\My).Thumbprint
$command = "winrm create winrm/config/Listener?Address=*+Transport=HTTPS @{Hostname=""$env:computername""; CertificateThumbprint=""$thumbprint""}"
cmd.exe /C $command
