# used to purge old BEK secrets that get added on tests of certain samples

param(
    [string] $vaultName = "azbotvault", # name of the vault azbotvaultus for FF
    [switch] $purge
)

$secrets = Get-AzKeyVaultSecret -VaultName $vaultName | Where-Object{$_.ContentType -eq "Wrapped BEK"}

if($purge){
    $secrets | Remove-AzKeyVaultSecret -Force
}else {
    $secrets | Out-String
}

 