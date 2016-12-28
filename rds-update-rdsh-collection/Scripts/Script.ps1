[cmdletbinding()]
param(
    [parameter(mandatory = $true)]
    [string]$domain,
    [parameter(mandatory = $true)]       
    [string]$username,
    [parameter(mandatory = $true)] 
    [string]$password,

    [parameter(mandatory = $true)]
    [string]$collection,
    [parameter(mandatory = $true)]       
    [string]$iteration,
    [parameter(mandatory = $true)] 
    [int]$nServers,

    [parameter(mandatory = $true)] 
    [int]$nTimeoutMinutes,

    [Parameter(ValueFromRemainingArguments = $true)]
    $extraParameters
    )

    $title = "System Maintenance"
    $message = "Please save your work. You will be logged off in $nTimeoutInMinutes minute(s)."

    function log
    {
        param([string]$message)

        "`n`n$(get-date -f o)  $message" 
    }


    function add-server	
    { 
        param(
            [parameter(mandatory=$true)]
            [string]$server
            )

            $cs = gwmi win32_computersystem;  $broker = "$($cs.dnshostname).$($cs.domain)"

            log "adding server $server to the deployment..."
            add-rdserver $server -role rds-rd-server -ev e

            if ($e -like '*deployment*not present*')
            {
                log "trying to create rds deployment..."
                new-rdsessiondeployment -connectionbroker $broker -sessionhost $_ -ev e

                if ($e -like "*$server*has reboots pending*")
                {
                    log "attempting to reboot $server..."
                    restart-computer $server -force -wait

                    log "attempting to create deployment with $server one more time..."
                    new-rdsessiondeployment -connectionbroker $broker -sessionhost $_ -ea stop
                }

                elseif ($e)
                {
                    throw
                }
                
                log "create deployment - success."
            }
            
            elseif ($e -like "*$server*has reboots pending*")
            {
                log "attempting to reboot $server..."
                restart-computer $server -force -wait

                log "attempting to add $server to deployment again after reboot..."
                add-rdserver $server -role rds-rd-server -ea stop
            }

            elseif ($e)
            {
                throw
            }

            log "successfully added '$server' to the deployment."
    }


    log "script running..."

	whoami

  # $PSBoundParameters

    if ($extraParameters) 
    {
        log "any extra parameters:"
        $extraParameters
    }


	log "attempting impersonate as $domain\$username..."
	.\New-ImpersonateUser.ps1 -Username $username -Domain $domain -Password $password

	try 
	{

		ipmo remotedesktop -DisableNameChecking    # 4>$null

	  # $domain = (gwmi win32_computersystem).Domain

		$newServers = 0..$($nServers - 1) | % { "rdsh-$_$iteration.$domain" }
		log "list of new servers:"
		$newServers | % { "    $($_.tolower())" }


		#  1. add new servers to the deployment
		#
		log "current list of servers in the rds deployment:"
		$existingServers = (get-rdserver).Server
		$existingServers |  % { "    $($_.tolower())" }

		$newServers | ? { -not ($_ -in $existingServers) } | % { add-server $_ }


		#  2. add new  servers to the rdsh collection
		#
		log "current list of rdsh servers in collection '$($collection)':"
		$existingServers = (get-rdsessionhost -CollectionName $collection).SessionHost
		if ($existingServers) 
		{
			$existingServers | % { "    $($_.tolower())" }
		}
		else
		{
			"    --- no servers in the collection yet ----"
		}

		$serversToAdd = $newServers | ? { -not ($_ -in $existingServers) } 

		if ($serversToAdd)
		{
			log "adding new servers $($serversToAdd -join '; ') to session host collection '$collection'..."
			add-rdsessionhost -collectionname $collection -sessionhost $serversToAdd -ea stop
		} 

    
		#  3. put old servers in drain mode
		#
		$serversToRemove = $existingServers | ? { -not ($_ -in $newServers) }

		if ($serversToRemove) 
		{ 
			$serversToRemove  | % `
			{
				log "putting server $_ in drain mode..."
				set-rdsessionhost -sessionhost $_ -newconnectionallowed No
			}
		}

		#  4. notify users they are going to be logged off in next <n> minutes
		#
		log "querying for user sessions in collection '$collection'..."
		$sessions =	get-rdusersession -CollectionName $collection 
		log "found total $($sessions.count) user sessions,"

		$sessionsToLogoff = $sessions | ? { -not( $_.HostServer -in $newServers ) }
		log "out of those $($sessionsToLogoff.count) sessions on the servers that are to be removed..."
    
		if ($sessionsToLogoff)
		{ 
			$sessionsToLogoff| % `
			{
				log "sending message to user $($_.UserName) at host $($_.HostServer)..."
				send-rdusermessage -hostserver $_.HostServer -unifiedsessionid $_.UnifiedSessionId -messagetitle $title -messagebody $message
			}
		}    
    

		#  5. log users off 
		#
		if ($sessionsToLogoff)
		{
			log "waiting $nTimeoutMinutes munites before logging users off..."
			start-sleep -s ($nTimeoutMinutes * 60)


			log "querying for user sessions again..."
			$sessions =	get-rdusersession -CollectionName $collection 
			log "found total $($sessions.count) user sessions at this time,"

			$sessionsToLogoff = $sessions | ? { -not( $_.HostServer -in $newServers ) }
			log "out of those, $($sessionsToLogoff.count) sessions to be logged off..."
			if ($sessionsToLogoff)
			{
				$sessionsToLogoff | % `
				{
					log "logging off user $($_.UserName) from host $($_.HostServer)..."
					invoke-rduserlogoff -hostserver $_.HostServer -unifiedsessionid $_.SessionId -force
				}
			}
		}


		#  6. remove old servers from deployment
		#
		if ($serversToRemove)
		{
			log "removing servers $($serversToRemove -join '; ') from session host collection '$collection'..."
			remove-rdsessionhost -sessionhost $serversToRemove -force

			$serversToRemove  | % `
			{
				log "removing server $_ from the deployment..."
				remove-rdserver $_ -role rds-rd-server -force
			}

			log "shutting down servers $($serversToRemove -join '; ')..."
			$creds = new-object System.Management.Automation.PSCredential ("$domain\$username", (convertto-securestring $password -asplaintext -force))
			stop-computer -computer $serversToRemove -credential $creds -force
		}
		else
		{
			log "nothing to do."
		}

	}
    catch
    {
        log "ERROR: caught exception"
        throw
    }
	finally 
	{
		log "remove impersonation..."
		Remove-ImpersonateUser
	}

    log "done. success."