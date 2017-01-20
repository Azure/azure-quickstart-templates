#
# Enable-CsUsers.ps1
#
<# Custom Script for Windows #>
Param (		
        [Parameter(Mandatory)]
        [String]$SipDomain

       )
$Domain = Get-ADDomain
#$SipDomain = $Domain.Name+".com"
$Computer = $env:computername + '.'+$Domain.DNSRoot


Import-Csv .\New-ADUsers.csv | ForEach-Object {
    Enable-CsUser -Identity $_.Name -SipAddressType SamAccountName  -SipDomain $SipDomain -RegistrarPool $Computer
    Set-CsUser -Identity $_.Name -EnterpriseVoiceEnabled $True
}
