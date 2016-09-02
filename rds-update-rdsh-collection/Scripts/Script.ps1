    param(
        [string]$collection,
        
        [string]$iteration,
        [int]$nServers,

        [int]$nTimeoutMinutes
        )

    get-date

    ipmo remotedesktop

    $title = "System Maintenance"
    $message = "Please save your work. You will be logged off in $($nTimeoutInMinutes) minute(s)."

    $domain = (gwmi win32_computersystem).Domain

    $newServers = 0..$($nServers - 1) | % { "rdsh-$_$iteration.$domain" }
    write-verbose "list of new servers:"
    $newServers | % { write-verbose "  $($_.tolower())" }


    #  1. add new servers to the deployment
    #
    write-verbose "current list of servers in the rds deployment:"
    $existingServers = (get-rdserver).Server
    $existingServers |  % { write-verbose "  $($_.tolower())" }

    $newServers | ? { -not ($_ -in $existingServers) } | % `
    {
        write-verbose "adding server $_ to the deployment..."
        add-rdserver $_ -role Rds-Rd-Server 
    }


    #  2. add new  servers to the rdsh collection
    #
    write-verbose "current list of rdsh servers in collection $($collection):"
    $existingServers = (get-rdsessionhost -CollectionName $collection).SessionHost
    $existingServers | % { write-verbose "  $($_.tolower())" }

    $serversToAdd = $newServers | ? { -not ($_ -in $existingServers) } 

    if ($serversToAdd.Count > 0)
    {
        write-verbose "adding new servers $($serversToAdd -join '; ') to session host collection $collection..."
        add-rdsessionhost -collectionname $collection -sessionhost $serversToAdd
    } 

    
    #  3. put old servers in drain mode
    #
    $existingServers | ? { -not ($_ -in $newServers) }  | % `
    {
        write-verbose "putting server $_ in drain mode..."
        set-rdsessionhost -sessionhost $_ -newconnectionallowed No
    }


    #  4. notify users they are going to be logged off in next <n> minutes
    #
    get-rdusersession -CollectionName $collection | % `
    {
        if ( -not($_.HostServer -in $newServers) )
        {   
            write-verbose "sending message to user $($_.UserName) at host $($_.HostServer)..."
            send-rdusermessage -hostserver $_.HostServer -unifiedsessionid $_.UnifiedSessionId -messagetitle $title -messagebody $message
        }
    }
    

    #  5. log users off 
	#
    write-verbose "waiting $nTimeoutMinutes before logging users off..."
    start-sleep -s ($nTimeoutMinutes * 60)

    get-rdusersession -CollectionName $collection | % `
    {
        if ( -not($_.HostServer -in $newServers) )
        {
            write-verbose "logging off user $($_.UserName) from host $($_.HostServer)..."
            invoke-rduserlogoff -hostserver $_.HostServer -unifiedsessionid $_.SessionId -force
        }
    }


    #  6. remove old servers from deployment
    #
    $serversToRemove = $existingServers | ? { -not ($_ -in $newServers) }
    write-verbose "removing servers $($serversToRemove -join '; ') from session host collection..."
    remove-rdsessionhost -sessionhost $serversToRemove -force

    $serversToRemove  | % `
    {
        write-verbose "removing server $_ from the deployment..."
        remove-rdserver $_ -role Rds-Rd-Server -force
    }

    write-verbose "shutting down servers $($serversToRemove -join '; ')..."
    stop-computer -computer $serversToRemove -force


    write-verbose "done."