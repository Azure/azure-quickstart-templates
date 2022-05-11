param (
    [string]$p4Path="C:\p4depots",
    [string]$p4Port="",
    [string]$p4Username="",
    [string]$p4Password="",
    [string]$p4Workspace="",
    [string]$p4Stream="",
    [string]$p4ClientViews="")


if ($p4Port -and $p4Username -and $p4Password)
{

  try {
    $driveLetter = (Get-StoragePool | Get-Volume).DriveLetter
    if ($driveLetter)
    {
        $p4Path = $driveLetter + ':' + (Split-Path -Path $p4Path -NoQualifier)
    }

    $viewsAdded=$false
    $clientViews = [System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String($p4ClientViews))

    $configFile = "p4config.config"
    New-Item -ItemType 'directory' -Path $p4Path
    Add-Content -Path "$p4Path\$configFile" -Value "P4PORT=$p4port"
    Add-Content -Path "$p4Path\$configFile" -Value "P4USER=$p4Username"
    Add-Content -Path "$p4Path\$configFile" -Value "P4CLIENT=$p4Workspace"

    & "C:\Program Files\Perforce\p4.exe" set -s P4CONFIG="$p4Path\$configFile"

    if ($p4Port.ToLower().StartsWith("ssl:"))
    {
        & "C:\Program Files\Perforce\p4.exe" trust -y
    }

    echo $p4Password | p4 login

    $p4ClientSpec = & "C:\Program Files\Perforce\p4.exe" client -o
    $p4ClientSpec = $p4ClientSpec -replace '^Root:.+$', "Root:`t$p4Path"
    $p4ClientSpec = $p4ClientSpec -replace '^Host:.+$', "Host:`t$env:Computername"

    $p4ClientSpecUpdate = @()
    for($i = 0; $i -lt $p4ClientSpec.Length; $i++)
    {
        $p4ClientSpecUpdate += $p4ClientSpec[$i]

        if($p4ClientSpec[$i] -eq "View:")
        {
            $viewsJson = ConvertFrom-Json -InputObject $clientViews.Replace("\", "")
            for($j = 0; $j -lt $viewsJson.length; $j++)
            {
            $p4ClientSpecUpdate += "`t" + $viewsJson[$j].depotPath + "`t//" + $p4Workspace + $viewsJson[$j].clientPath
            }
            $viewsAdded=$true
            break
        }
    
    }

    if (-Not $viewsAdded)
    {
        $p4ClientSpecUpdate += "View:"

        $viewsJson = ConvertFrom-Json -InputObject $clientViews.Replace("\", "")
        for($j = 0; $j -lt $viewsJson.length; $j++)
        {
            $p4ClientSpecUpdate += "`t" + $viewsJson[$j].depotPath + "`t//" + $p4Workspace + $viewsJson[$j].clientPath
        }
    }

    if ($p4Stream)
    {
        $p4ClientSpecUpdate = $p4ClientSpecUpdate -replace '^Stream:.+$', ""
        $p4ClientSpecUpdate += "Stream:`t$p4Stream"
    }

    $p4ClientSpecUpdate | & "C:\Program Files\Perforce\p4.exe" client -i
    Start-Process -FilePath "C:\Program Files\Perforce\p4.exe" -ArgumentList " sync -f" -WindowStyle Hidden
  }
  catch [Exception]{
    Add-Content 'C:\Users\Public\Desktop\INSTALLED_SOFTWARE.txt' 'ERROR: Perforce depot sync has failed. Please use Perforce client tools to manually sync your depot.'
  }
}