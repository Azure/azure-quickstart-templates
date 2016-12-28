workflow inforunbook1{    
    param(
        
        [Parameter(Mandatory=$true)]
        [string]
        $ip,

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
        $user_email,

        [Parameter(Mandatory=$true)]
        [string]
        $user_firstName,

        [Parameter(Mandatory=$true)]
        [string]
        $user_lastName,

        [Parameter(Mandatory=$true)]
        [string]
        $user_title,

        [Parameter(Mandatory=$true)]
        [long]
        $user_phone,

        [Parameter(Mandatory=$true)]
        [string]
        $org_name,

        [Parameter(Mandatory=$true)]
        [string]
        $org_address,

        [Parameter(Mandatory=$true)]
        [string]
        $org_city,

        [Parameter(Mandatory=$true)]
        [string]
        $org_state,

        [Parameter(Mandatory=$true)]
        [long]
        $org_zipcode,

        [Parameter(Mandatory=$true)]
        [string]
        $org_country,

        [Parameter(Mandatory=$true)]
        [string]
        $org_employees

    )

    
    Write-Output $ip
    Write-Output $client_id
    Write-Output $sysgain_ms_email
    Write-Output $sysgain_ms_password
    Write-Output $informatica_user_name
    Write-Output $informatica_user_password
    Write-Output $user_email
    Write-Output $user_firstName
    Write-Output $user_lastName
    Write-Output $user_title  
    Write-Output $user_phone
    Write-Output $org_name
    Write-Output $org_address
    Write-Output $org_city
    Write-Output $org_state
    Write-Output $org_zipcode
    Write-Output $org_country
    Write-Output $org_employees
    Write-Output "------------------------------------------------------------------"



    InlineScript{
        [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
    }

    Write-Output "------------------------------------------------------------------"       
    Write-Output "Signing up into Sysgain..."
    Write-Output "------------------------------------------------------------------"
  
    $msSignUpUrl="https://$ip/api/users/v1/components/signup"
    #$msSignUpUrl="https://138.91.243.84:10011/api/users/v1/components/signup"

    $headSignUp = @{
        'Accept' = 'application/json'
    }

    $bodySignUp = @{
        email = "$sysgain_ms_email"
        password = "$sysgain_ms_password"
        connection_type = "Username-Password-Authentication"
        client_id = "$client_id"
    }
    
    $bodyJsonSignUp = $bodySignUp | ConvertTo-Json

    $res = Invoke-RestMethod -Uri $msSignUpUrl -Method Post -Headers $headSignUp -Body $bodyJsonSignUp -ContentType 'application/json'
    
    Write-Output $res | ConvertTo-Json
    Write-Output "Signed up successfully!"






    Write-Output "------------------------------------------------------------------"
    Write-Output "Logging into Sysgain..."
    Write-Output "------------------------------------------------------------------"

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
    Write-Output "Logged in successfully!"





    Write-Output "------------------------------------------------------------------"
    Write-Output "Signing up into informatica..."
    Write-Output "------------------------------------------------------------------"
    #Signup into Informatica

    #$infoSignUpUrl = "https://138.91.243.84:10011/api/users/v1/components/informatica/signup"
    $infoSignUpUrl = "https://$ip/api/users/v1/components/informatica/signup"

    $infoheadSignUp = @{
        'Accept'= 'application/json'
        'Authorization' = 'bearer '+$auth0.id_token
    }

    $infobodySignUp = '{
        "@type" : "registration",
        "user" : {
        "@type" : "user",'+ 
        '"name" : "'+$informatica_user_name+'",'+
        '"emails" : "'+$user_email+'",'+
        '"password" : "'+$informatica_user_password+'",'+
        '"firstName" : "'+$user_firstName+'",'+
        '"lastName" : "'+$user_lastName+'",'+
        '"title" : "'+$user_title+'",'+
        '"phone" : "'+$user_phone+'",'+
        '"timezone" : null'+
        '},
        "org" : {
        "@type" : "org",'+
        '"name" : "'+$org_name+'",'+
        '"address1" : "'+$org_address+'",'+
        '"city" : "'+$org_city+'",'+
        '"state" : "'+$org_state+'",'+
        '"zipcode" : "'+$org_zipcode+'",'+
        '"country" : "'+$org_country+'",'+
        '"employees" : "'+$org_employees+'"'+ 
        '}
    }'

    $response = Invoke-RestMethod -Uri $infoSignUpUrl -Method Post -Headers $infoheadSignUp -Body $infobodySignUp -ContentType 'application/json'
    Write-Output $response | ConvertTo-Json
    Write-Output "Signed up successfully!"

   
}