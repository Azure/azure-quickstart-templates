param(
    [string]$domain  = "contoso.com",
    [string]$broker  = "broker.contoso.com",
    [string]$gateway = "gateway.contoso.com",
    [string]$externalfqdn = "rds-c2d48ce7-e247-4065-8f2d-bea5ff042f66.westus.cloudapp.azure.com",

    [string]$rdshnamingprefix = "rdsh-",
    [int]$numberOfRdshInstances = 2
)


$allservers = (0..($numberOfRdshInstances-1) | % { "$rdshnamingprefix$_.contoso.com" }) + $broker + $gateway



ipmo remotedesktop


#{ log status

    get-rdserver 
    $allservers | % { "`nlisting rds features on host $_ ...`n"; get-windowsfeature -computername $_ -name remote*,rds*,rsat-rds* }
#}


if ($numberOfRdshInstances -gt 1)
{
    # implies there is only one session collection at this time
    $collection = get-rdsessioncollection

    $sessionhosts = 1..($numberOfRdshInstances-1) | % { "$rdshnamingprefix$_.$domain"}
    
    $sessionhosts | % `
    { 
        write-verbose "adding server $_ to the deployment..."
        add-rdserver -server $_ -role RDS-RD-Server
    }

    write-verbose "adding session hosts to the collection:  $($sessionhosts -join (', '))"
    add-rdsessionhost -collectionname $collection.CollectionName -sessionhost $sessionhosts
}

add-rdserver -server $broker -role RDS-Licensing
set-rdlicenseconfiguration -licenseserver $broker -mode PerUser –force

add-rdserver -server $gateway -role RDS-Gateway -gatewayexternalfqdn $externalfqdn
set-rddeploymentgatewayconfiguration -gatewaymode Custom -gatewayexternalfqdn $externalfqdn -logonmethod AllowUserToSelectDuringConnection -usecachedcredentials $true -bypasslocal $false -force



#{ log status

    get-rdserver 
    $allservers | % { "`nlisting rds features on host $_ ...`n"; get-windowsfeature -computername $_ -name remote*,rds*,rsat-rds* }
#}
