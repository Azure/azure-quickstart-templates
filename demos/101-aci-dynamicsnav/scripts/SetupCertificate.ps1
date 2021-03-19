# This is a copy of https://github.com/NAVDEMO/LetsEncrypt/blob/master/SetupCertificate.ps1 because for the quickstart templates everything needs to be in this repo
# All credit goes to Freddy Kristiansen of Microsoft, the main author of this script

# INPUT
#     $runPath
#     $myPath
#     $env:ContactEMailForLetsEncrypt
#     $env:CerificatePfxPassword
#     $env:CerificatePfxUrl
#
# OUTPUT
#     $certificateCerFile (if self signed)
#     $certificateThumbprint
#     $dnsIdentity

$ContactEMailForLetsEncrypt = "$env:ContactEMailForLetsEncrypt"
$CertificatePfxPassword = "$env:CertificatePfxPassword"
$certificatePfxUrl = "$env:certificatePfxUrl"
$certificatePfxFile = ""

if ("$certificatePfxUrl" -ne "" -and "$CertificatePfxPassword" -ne "") {

    $certificatePfxFile = Join-Path $myPath "certificate.pfx"
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    (New-Object System.Net.WebClient).DownloadFile($certificatePfxUrl, $certificatePfxFile)
    $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($certificatePfxFile, $certificatePfxPassword)
    $certificateThumbprint = $cert.Thumbprint
    Write-Host "Certificate File Thumbprint $certificateThumbprint"
    if (!(Get-Item Cert:\LocalMachine\my\$certificateThumbprint -ErrorAction SilentlyContinue)) {
        Write-Host "Importing Certificate to LocalMachine\my"
        Import-PfxCertificate -FilePath $certificatePfxFile -CertStoreLocation cert:\localMachine\my -Password (ConvertTo-SecureString -String $certificatePfxPassword -AsPlainText -Force) | Out-Null
    }
    $dnsidentity = $cert.GetNameInfo("SimpleName",$false)
    if ($dnsidentity.StartsWith("*")) {
        $dnsidentity = $dnsidentity.Substring($dnsidentity.IndexOf(".")+1)
    }
    Write-Host "DNS identity $dnsidentity"

} elseif ("$ContactEMailForLetsEncrypt" -ne "") {

    try {
        Write-Host "Using LetsEncrypt to create SSL Certificate"

        Write-Host "Using default website for LetsEncrypt"
        
        Write-Host "Installing NuGet PackageProvider"
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force | Out-Null
        
        Write-Host "Installing ACMESharp PowerShell modules"
        Install-Module -Name ACMESharp -AllowClobber -force | Out-Null
        Install-Module -Name ACMESharp.Providers.IIS -force | Out-Null
        Import-Module ACMESharp
        Enable-ACMEExtensionModule -ModuleName ACMESharp.Providers.IIS | Out-Null
        Write-Host "Initializing ACMEVault"
        Initialize-ACMEVault
                    
        Write-Host "Registering Contact EMail address and accept Terms Of Service"
        New-ACMERegistration -Contacts "mailto:$ContactEMailForLetsEncrypt" -AcceptTos | Out-Null
                    
        Write-Host "Creating new dns Identifier"
        $dnsAlias = "dnsAlias"
        New-ACMEIdentifier -Dns $publicDnsName -Alias $dnsAlias | Out-Null
        
        Write-Host "Performing Lets Encrypt challenge to default web site"
        Complete-ACMEChallenge -IdentifierRef $dnsAlias -ChallengeType http-01 -Handler iis -HandlerParameters @{ WebSiteRef = 'Default Web Site' } | Out-Null
        Submit-ACMEChallenge -IdentifierRef $dnsAlias -ChallengeType http-01 | Out-Null
        sleep -s 60
        Update-ACMEIdentifier -IdentifierRef $dnsAlias | Out-Null
        
        Write-Host "Requesting certificate"
        $certAlias = "certAlias"
        $certificatePfxPassword = [GUID]::NewGuid().ToString()
        $certificatePfxFile = Join-Path $myPath "certificate.pfx"
        New-ACMECertificate -Generate -IdentifierRef $dnsAlias -Alias $certAlias | Out-Null
        Submit-ACMECertificate -CertificateRef $certAlias | Out-Null
        Update-ACMECertificate -CertificateRef $certAlias | Out-Null
        Get-ACMECertificate -CertificateRef $certAlias -ExportPkcs12 $certificatePfxFile -CertificatePassword $certificatePfxPassword | Out-Null
        
        $certificatePemFile = Join-Path $myPath "certificate.pem"
        Remove-Item -Path $certificatePemFile -Force -ErrorAction Ignore | Out-Null
        Get-ACMECertificate -CertificateRef $certAlias -ExportKeyPEM $certificatePemFile | Out-Null
        
        $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($certificatePfxFile, $certificatePfxPassword)
        $certificateThumbprint = $cert.Thumbprint
        
        Write-Host "Importing Certificate to LocalMachine\my"
        Import-PfxCertificate -FilePath $certificatePfxFile -CertStoreLocation cert:\localMachine\my -Password (ConvertTo-SecureString -String $certificatePfxPassword -AsPlainText -Force) | Out-Null
        
        $dnsidentity = $cert.GetNameInfo("SimpleName",$false)
        if ($dnsidentity.StartsWith("*")) {
            $dnsidentity = $dnsidentity.Substring($dnsidentity.IndexOf(".")+1)
        }
        Write-Host "DNS identity $dnsidentity"
    }
    catch {
        # If Any error occurs (f.ex. rate-limits), setup self signed certificate
        Write-Host "Error creating letsEncrypt certificate, reverting to self-signed"
        Write-Host "Error was:"
        Write-Host $_.Exception.Message
        . (Join-Path $runPath $MyInvocation.MyCommand.Name)
    }
} else {
    . (Join-Path $runPath $MyInvocation.MyCommand.Name)
}
