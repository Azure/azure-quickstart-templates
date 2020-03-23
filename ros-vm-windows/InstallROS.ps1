# download and unzip the ROS to the desired location
$outputPath = Join-Path $(Get-Location) -ChildPath "output"
$ros1DownloadPath = Join-Path $outputPath -ChildPath "melodic-sfx-installer.zip"
$ros2DownloadPath = Join-Path $outputPath -ChildPath "eloquent-sfx-installer.zip"
$vcRedistPath = Join-Path $outputPath -ChildPath "vc_redist.x64.exe"
$vcRedistPath_vs2010 = Join-Path $outputPath -ChildPath "vcredist_x64.exe"

$ros1LatestBuildUrl = 'https://dev.azure.com/ros-win/ros-win/_apis/build/builds?definitions=54&$top=1&resultFilter=succeeded&api-version=5.1'
$ros2LatestBuildUrl = 'https://dev.azure.com/ros-win/ros-win/_apis/build/builds?definitions=74&$top=1&resultFilter=succeeded&api-version=5.1'
$vcRedistUrl = 'https://aka.ms/vs/16/release/vc_redist.x64.exe'
$vcRedistUrl_vs2010 = 'https://download.microsoft.com/download/3/2/2/3224B87F-CFA0-4E70-BDA3-3DE650EFEBA5/vcredist_x64.exe'

New-Item -ItemType directory -Path $outputPath

$retryCount = 3
$retries = 1
Write-Verbose "Downloading ROS install files" -verbose
do
{
    try
    {
        $response1 = Invoke-RestMethod $ros1LatestBuildUrl -Method Get -ContentType 'application/json'
        $buildId1 = $response1.value[0].id
        
        $response2 = Invoke-RestMethod $ros2LatestBuildUrl -Method Get -ContentType 'application/json'
        $buildId2 = $response2.value[0].id

        $artifactUrl1 = "https://ros-win.visualstudio.com/bed058dd-46da-4029-bb85-25eae7674d09/_apis/build/builds/$buildId1/artifacts?artifactName=sfx-installer&api-version=5.2-preview.5&%24format=zip"
        $artifactUrl2 = "https://ros-win.visualstudio.com/bed058dd-46da-4029-bb85-25eae7674d09/_apis/build/builds/$buildId2/artifacts?artifactName=sfx-installer&api-version=5.2-preview.5&%24format=zip"

        $download = New-Object net.webclient
        $download.Downloadfile($artifactUrl1, $ros1DownloadPath)
        $download.Downloadfile($artifactUrl2, $ros2DownloadPath)
        $download.DownloadFile($vcRedistUrl, $vcRedistPath)
        $download.DownloadFile($vcRedistUrl_vs2010, $vcRedistPath_vs2010)
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

Expand-Archive -path $ros1DownloadPath -destinationpath $outputPath
$sfxPath1 = Join-Path $outputPath -ChildPath "sfx-installer/ros-melodic-desktop_full.exe"

Expand-Archive -path $ros2DownloadPath -destinationpath $outputPath
$sfxPath2 = Join-Path $outputPath -ChildPath "sfx-installer/ros-eloquent-desktop.exe"

Write-Verbose "Installing Microsoft Visual C++ 2015-2019 redistributable packages" -verbose
Start-Process "$vcRedistPath" -ArgumentList "/q","/norestart","/log","vcredistinstall.log" -NoNewWindow -Wait

Write-Verbose "Installing Microsoft Visual C++ 2010 redistributable packages" -verbose
Start-Process "$vcRedistPath_vs2010" -ArgumentList "/q","/norestart","/log","vcredistinstall.log" -NoNewWindow -Wait

Write-Verbose "Installing ROS1 binaries" -verbose
Start-Process "$sfxPath1" -ArgumentList "-oc:\","-y" -NoNewWindow -Wait

Write-Verbose "Installing ROS2 binaries" -verbose
Start-Process "$sfxPath2" -ArgumentList "-oc:\","-y" -NoNewWindow -Wait

# finally enable RemotePS 
Enable-PSRemoting -Force -SkipNetworkProfileCheck
New-NetFirewallRule -Name "Allow WinRM HTTPS" -DisplayName "WinRM HTTPS" -Enabled True -Profile Any -Action Allow -Direction Inbound -LocalPort 5986 -Protocol TCP
$thumbprint = (New-SelfSignedCertificate -DnsName $env:COMPUTERNAME -CertStoreLocation Cert:\LocalMachine\My).Thumbprint
$command = "winrm create winrm/config/Listener?Address=*+Transport=HTTPS @{Hostname=""$env:computername""; CertificateThumbprint=""$thumbprint""}"
cmd.exe /C $command
