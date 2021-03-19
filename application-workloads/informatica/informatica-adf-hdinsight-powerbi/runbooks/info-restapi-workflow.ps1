workflow inforunbook2{
param(
        [Parameter(Mandatory=$true)]
        [string]
        $ip,

        [Parameter(Mandatory=$true)]
        [string]
        $credentialName,

        [Parameter(Mandatory=$true)]
        [string]
        $client_id,

        [Parameter(Mandatory=$true)]
        [string]
        $sysgain_ms_email,

        [Parameter(Mandatory=$true)]
        [string]
        $sysgain_ms_password,

        [Parameter(Mandatory=$true)]
        [string]
        $informatica_user_name,

        [Parameter(Mandatory=$true)]
        [string]
        $informatica_user_password,

        [Parameter(Mandatory=$true)]
        [string]
        $informatica_csa_vmname,

        [Parameter(Mandatory=$true)]
        [string]
        $adfStorageAccName,

        [Parameter(Mandatory=$true)]
        [string]
        $adfStorageAccKey
)
  
    Write-Output $ip
    Write-Output $client_id
    Write-Output $sysgain_ms_email
    Write-Output $sysgain_ms_password
    Write-Output $informatica_user_name
    Write-Output $informatica_user_password
    Write-Output $informatica_csa_vmname
    Write-Output $adfStorageAccName
    Write-Output $adfStorageAccKey
    Write-Output "------------------------------------------------------"

    InlineScript{
        [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
    }

    Write-Output "Logging into Sysgain..."
    Write-Output "------------------------------------------------------"

    #$msLoginUrl="https://138.91.243.84:10011/api/users/v1/components/login"
    $msLoginUrl="https://$ip/api/users/v1/components/login"

    $headLogin = @{
        'Accept' = 'application/json'
    }

    $bodyLogin = @{
        username = "$sysgain_ms_email"
        password = "$sysgain_ms_password"
        grant_type = "password"
        connection_type = "Username-Password-Authentication"
        scope = "openid"
        client_id = "$client_id"
    }

    $bodyJsonLogin = $bodyLogin | ConvertTo-Json

    $auth0 = Invoke-RestMethod -Uri $msLoginUrl -Method Post -Headers $headLogin -Body $bodyJsonLogin -ContentType 'application/json'

    Write-Output $auth0 | ConvertTo-Json

    Write-Output "Logging into informatica..."
    Write-Output "------------------------------------------------------"

    #Login into Informatica

    #$infoLoginUrl = "https://138.91.243.84:10011/api/users/v1/components/informatica/login"
    $infoLoginUrl = "https://$ip/api/users/v1/components/informatica/login"

    $infoheadLogin = @{
        'Authorization' = 'bearer '+$auth0.id_token
    }

    $infobodyLogin = @{
        username = "$informatica_user_name"
        password = "$informatica_user_password"
    }
    
    $infobodyJsonLogin = $infobodyLogin | ConvertTo-Json

    $responseLogin = Invoke-RestMethod -Uri $infoLoginUrl -Method Post -Headers $infoheadLogin -Body $infobodyJsonLogin -ContentType 'application/json'
    Write-Output $responseLogin | ConvertTo-Json

    $icSessionId = $responseLogin.infoData.icSessionId
    $serverUrl = $responseLogin.infoData.serverUrl
    $authToken = $responseLogin.auth0_token

    Write-Output "------------------------------------------------------"
    Write-Output "Logged in successfully..."
    Write-Output "------------------------------------------------------"

    Write-Output "The session id is "$icSessionId
    Write-Output "------------------------------------------------------"
    Write-Output "The server url is "$serverUrl
    Write-Output "------------------------------------------------------"
    Write-Output "The auth token is "$authToken




    #$workflowUrl = "https://138.91.243.84:10011/api/users/v1/components/informatica/workflow/ignitep2p"
    $workflowUrl = "https://$ip/api/users/v1/components/informatica/workflow/ignitep2p"

    $workflowHead = @{
        'Accept' = 'application/json'
        'Authorization' = 'bearer '+$auth0.id_token
    }

    $workflowBody = @{
        sessionId = "$icSessionId"
        serverUrl = "$serverUrl"
        csa_name = "$informatica_csa_vmname"
        storageAccountName = "$adfStorageAccName"
        storageAccountkey = "$adfStorageAccKey"
    }
    
    $workflowBodyJson = $workflowBody | ConvertTo-Json
    Start-Sleep -Seconds 90
    $workres = Invoke-RestMethod -Uri $workflowUrl -Method Post -Headers $workflowHead -Body $workflowBodyJson -ContentType 'application/json' 
    Write-Output $workres | ConvertTo-Json

}
