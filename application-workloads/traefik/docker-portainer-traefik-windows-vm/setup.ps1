param (
    $mail,
    $publicdnsname,
    $adminPwd
)
# format disk and create folders
Get-Disk | Where-Object partitionstyle -eq 'raw' | Initialize-Disk -PartitionStyle MBR -PassThru | New-Partition -UseMaximumSize -DriveLetter F | Format-Volume -FileSystem NTFS -Confirm:$false -Force
New-Item -Path f:\le -ItemType Directory | Out-Null
New-Item -Path f:\le\acme.json | Out-Null
New-Item -Path f:\dockerdata -ItemType Directory | Out-Null
New-Item -Path f:\portainerdata -ItemType Directory | Out-Null
New-Item -Path f:\compose -ItemType Directory | Out-Null

# install vim and openssh using chocolatey
[DownloadWithRetry]::DoDownloadWithRetry("https://chocolatey.org/install.ps1", 5, 10, $null, ".\chocoInstall.ps1", $false)
& .\chocoInstall.ps1
choco feature enable -n allowGlobalConfirmation
choco install --no-progress --limit-output vim
choco install --no-progress --limit-output openssh -params '"/SSHServerFeature"'

# configure OpenSSH, make PS the default shell and restart sshd
Copy-Item '.\sshd_config_wpwd' 'C:\ProgramData\ssh\sshd_config'
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force
Restart-Service sshd

# relocate docker data
Stop-Service docker
$dockerDaemonConfig = @"
{
    `"data-root`": `"f:\\dockerdata`"
}
"@
$dockerDaemonConfig | Out-File "c:\programdata\docker\config\daemon.json" -Encoding ascii
Start-Service docker

# prepare password file for portainer
$adminPwd | Out-File -NoNewline -Encoding ascii "f:\portainerdata\passwordfile"

# download compose, the compose file and deploy it
[DownloadWithRetry]::DoDownloadWithRetry("https://github.com/docker/compose/releases/download/1.28.2/docker-compose-Windows-x86_64.exe", 5, 10, $null, "$($Env:ProgramFiles)\Docker\docker-compose.exe", $false)

$template = Get-Content '.\docker-compose.yml.template' -Raw
$expanded = Invoke-Expression "@`"`r`n$template`r`n`"@"
$expanded | Out-File "f:\compose\docker-compose.yml" -Encoding ASCII

Set-Location "f:\compose"
Invoke-Expression "docker-compose up -d"

class DownloadWithRetry {
    static [string] DoDownloadWithRetry([string] $uri, [int] $maxRetries, [int] $retryWaitInSeconds, [string] $authToken, [string] $outFile, [bool] $metadata) {
        $retryCount = 0
        $headers = @{}
        if (-not ([string]::IsNullOrEmpty($authToken))) {
            $headers = @{
                'Authorization' = $authToken
            }
        }
        if ($metadata) {
            $headers.Add('Metadata', 'true')
        }

        while ($retryCount -le $maxRetries) {
            try {
                if ($headers.Count -ne 0) {
                    if ([string]::IsNullOrEmpty($outFile)) {
                        $result = Invoke-WebRequest -Uri $uri -Headers $headers -UseBasicParsing
                        return $result.Content
                    }
                    else {
                        $result = Invoke-WebRequest -Uri $uri -Headers $headers -UseBasicParsing -OutFile $outFile
                        return ""
                    }
                }
                else {
                    throw;
                }
            }
            catch {
                if ($headers.Count -ne 0) {
                    write-host "download of $uri failed"
                }
                try {
                    if ([string]::IsNullOrEmpty($outFile)) {
                        $result = Invoke-WebRequest -Uri $uri -UseBasicParsing
                        return $result.Content
                    }
                    else {
                        $result = Invoke-WebRequest -Uri $uri -UseBasicParsing -OutFile $outFile
                        return ""
                    }
                }
                catch {
                    write-host "download of $uri failed"
                    $retryCount++;
                    if ($retryCount -le $maxRetries) {
                        Start-Sleep -Seconds $retryWaitInSeconds
                    }            
                }
            }
        }
        return ""
    }
}
