# script to create the Root Certificate and Client Certificates signed with root certificate.
# The script can run on Windows 11 or Windows Server
#
# input paramenters:
#   $pwdCertificates: specifies the password to export the digital certificates
# 
#
param(
    [Parameter(Mandatory = $false, HelpMessage = 'password certificate', ValueFromPipeline = $true)]
    [string]$pwdCertificates = '12345'

)

for ($selection = 1 ; $selection -le 3 ; $selection++) {

    switch ($selection) {
        1 { $certSubject = 'CN=cert@marketing.contoso.com'; $clientNumb = '1' }
        2 { $certSubject = 'CN=cert@sale.contoso.com'; $clientNumb = '2' }
        3 { $certSubject = 'CN=cert@engineering.contoso.com'; $clientNumb = '3' }
    }


    # The variable specifies the local folder to store the digital certificates
    $certPath = "C:\cert$clientNumb\"

    $pathFolder = [string](Split-Path -Path $certPath -Parent)
    $folderName = [string](Split-Path -Path $certPath -Leaf)
    Write-Host 'folder to store digital certificates: '$pathFolder$folderName


    # Create a local folder: 'C:\cert'
    New-Item -Path $pathFolder -Name $folderName -ItemType Directory -Force
    Write-Host '' 
    #
    # Create self-signed Root Certificate
    # It creates a self-signed root certificate named 'P2SRootCert' that is automatically installed in 'Certificates-Current User\Personal\Certificates'.
    # You can view the certificate by opening certmgr.msc, or Manage User Certificates.
    $params = @{
        Type              = 'Custom'
        Subject           = 'CN=P2SRootCert'
        KeySpec           = 'Signature'
        KeyExportPolicy   = 'Exportable'
        KeyUsage          = 'CertSign'
        KeyUsageProperty  = 'Sign'
        KeyLength         = 2048
        HashAlgorithm     = 'sha256'
        NotAfter          = (Get-Date).AddMonths(24)
        CertStoreLocation = 'Cert:\CurrentUser\My'
    }

    # Check if the Root Certificates already exists in the store:  Cert:\CurrentUser\My 
    Write-Host "$(Get-Date) - checking P2S Root certificate in Cert:\CurrentUser\My"
    $certRoot = Get-ChildItem -Path Cert:\CurrentUser\My | Where-Object { $_.Subject -eq 'CN=P2SRootCert' }
    If ($null -eq $certRoot) {
        # Create a new Root Certificate if it doesn't exist.
        $certRoot = New-SelfSignedCertificate @params
        Write-Host "$(Get-Date) - P2S Root certificate created"
    }
    Else { 
        # Root Certificate already exists in the store, skipping operation
        Write-Host "$(Get-Date) - P2S Root certificate already exists, skipping" 
    }


    # Fetch self-signed Root Certificate named 'P2SRootCert' from 'Certificates-Current User\Personal\Certificates'
    $mypwd = ConvertTo-SecureString -String $pwdCertificates -Force -AsPlainText
    $certRootThumbprint = (Get-ChildItem -Path "Cert:\CurrentUser\My" | where-Object  -Property Subject -eq  "CN=P2SRootCert" | Select-Object Thumbprint).Thumbprint
    $certRoot = Get-ChildItem -Path "Cert:\CurrentUser\My\$certRootThumbprint"

    # Export of the root certificate in format .pfx
    # The private key is included in the export. Password is required for export operation.
    Export-PfxCertificate -Cert $certRoot -FilePath $certPath'P2SRoot-with-privKey.pfx' -Password $mypwd 

    Write-Host "$(Get-Date) - start creation P2S Client cert: $certSubject" -ForegroundColor Yellow
     
    # Generate a client certificate
    # Each client computer that connects to a VNet using Point-to-Site must have a client certificate installed. 
    # You generate a client certificate from the self-signed root certificate, and then export and install the client certificate. 
    # If the client certificate isn't installed, authentication fails.
    $params = @{
        Type              = 'Custom'
        Subject           = $certSubject
        KeySpec           = 'Signature'
        KeyExportPolicy   = 'Exportable'
        KeyLength         = 2048
        HashAlgorithm     = 'sha256'
        NotAfter          = (Get-Date).AddMonths(18)
        CertStoreLocation = 'Cert:\CurrentUser\My'
        Signer            = $certRoot
        TextExtension     = @('2.5.29.37={text}1.3.6.1.5.5.7.3.2')
    }
    # Create client cert
    $certClient = Get-ChildItem -Path Cert:\CurrentUser\My | Where-Object { $_.Subject -eq $certSubject }
    If ($null -eq $certClient) {
        # getting client certificate
        New-SelfSignedCertificate @params
        Write-Host "$(Get-Date) - P2S Client cert: $certSubject created" -ForegroundColor Yellow
    }
    Else { Write-Host "$(Get-Date) - P2S Client cert: $certSubject already exists, skipping....." }


    # Save root certificate to file
    $FileCert = $certPath + 'P2SRoot' + $clientNumb + '.cert'
    $certRoot = Get-ChildItem -Path Cert:\CurrentUser\My | Where-Object { $_.Subject -eq "CN=P2SRootCert" }
    If ($null -eq $certRoot) {
        Write-Host "$(Get-Date) - Root Certificate CN=P2SRootCert not found "
        write-host "stop processing!"
        Exit
    }
    Else { 
        # Export of the root certificate in format .cer 
        # The private key is not included in the export. Password is not required for the export.
        Export-Certificate -Cert $certRoot -FilePath $FileCert -Force | Out-Null
        Write-Host "$(Get-Date) - Create the file: $FileCert" -ForegroundColor Green
    }

    # Convert to Base64 cer file
    $FileCer = $certPath + 'P2SRoot' + $clientNumb + '.cer'
    Write-Host "$(Get-Date) - Creating root certificate in $FileCer"
    If (-not (Test-Path -Path $FileCer)) {
        certutil -encode $FileCert $FileCer | Out-Null
        Write-Host "$(Get-Date) - Created root cer file"
    }
    Else { Write-Host "$(Get-Date) - Root .cer file exists, skipping" }

    $certFilePath = $certPath + 'certClient' + $clientNumb + '.pfx'

    ####### export user certificate in Personal Information Exchange - PKCS #12 (.PFX)
    $mypwd = ConvertTo-SecureString -String $pwdCertificates -Force -AsPlainText
    $certClient = Get-ChildItem -Path Cert:\CurrentUser\My | Where-Object { $_.Subject -eq $certSubject }
    Export-PfxCertificate -cert $certClient -FilePath $certFilePath -Password $mypwd

    ### To see the thumbprint of exported user certificate
    # (Get-PfxData -FilePath "$certPath\certClient.pfx" -Password $mypwd ).EndEntityCertificates[0]


    $pwdFile = $certPath + 'certpwd.txt'
    Write-Host ''
    Write-Host 'write password file: '$pwdFile
    Out-File -FilePath $pwdFile -Force -InputObject $pwdCertificates
}

