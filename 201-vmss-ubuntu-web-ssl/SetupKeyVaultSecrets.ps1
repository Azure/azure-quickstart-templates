#
# SetupKeyVaultSecrets.ps1
#
Param([Parameter(Mandatory=$true)][string] $vaultName = "dncKeyVault")

function Set-Secret
{
	Param( 
		[string] $sn,
		[string] $sv
	)

	Write-Host "Setting secret: " $sn

	$s = ConvertTo-SecureString -String $sv -AsPlainText -Force
			
	$secret = Set-AzureKeyVaultSecret -VaultName $vaultName -Name $sn -SecretValue $s -Verbose 
	If( $secret -eq $null )
	{
		Write-Host "Error Setting: " $sn " in vault " $vaultName
		exit 1
	}
	else
	{
		$secret
	}
}

function Set-SecretFromCert
{
	Param( [string] $sn,
	[string] $certFileName )

	$fileContentByte = get-content $certFileName -Encoding Byte
	$fileContentEncoded = [System.Convert]::ToBase64String($fileContentByte)


	$jsonObject = @"
{
"data": "$filecontentencoded",
"dataType" :"pfx",
"password": "blabla"
}
"@


	$jsonObjectBytes = [System.Text.Encoding]::UTF8.GetBytes($jsonObject)
	$jsonEncoded = [System.Convert]::ToBase64String($jsonObjectBytes)

	Set-Secret $sn $jsonEncoded	
}

function Read-FileContentAsString
{
	Param( [string] $fileName)

	$fileContentString = ""
	if( Test-Path $fileName )
	{
		$fileContentString = get-content $fileName -Encoding String -Raw
		
	}
	Else
	{
		Write-Host "Unable to load cert file: " $fileName
		Exit 1
	}

	return $fileContentString
}

function Read-FileContentAsBase64
{
	Param( [string] $fileName)

	$fileContentString = Read-FileContentAsString $fileName
	$fileContentEncoded = [System.Convert]::ToBase64String($fileContentString)
	return $fileContentString
}

function Set-SecretFromFile
{
	Param([string] $secretName,
	[string] $fileName )

	$content = Read-FileContentAsString $fileName

	Set-Secret $secretName $content
}

function Test-KeyVault{
	Param([string] $vn)

	Write-Host "Checking for: " $vn
	$v = Get-AzureRmKeyVault -VaultName $vn
	if( $v -ne $null )
	{
		$v
	}
	else
	{
		Write-Host "KeyVault not available or access policy not set"
		Exit 1
	}
	return $true
}

Test-KeyVault $vaultName

#$ssl = Set-SecretFromCert certwithca "C:\Users\Chris\Source\Repos\DNCC\WPSetup\pfxwithca\certwithca.pfx"
#$ssl = Set-SecretFromCert cacert "C:\Users\Chris\Source\Repos\DNCC\WPSetup\pfxwithca\ca.pfx"
$ssl = Set-SecretFromCert cacert "C:\Users\Chris\Source\Repos\DNCC\WPSetup\selfsignedcert\myawesomeness_com.pfx"

Write-Host "******* SecretUrls ********"
Write-Host $ssl.Id
