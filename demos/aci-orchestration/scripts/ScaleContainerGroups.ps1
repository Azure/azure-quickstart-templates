<#
.SYNOPSIS
    Manages the number of running Azure Container Groups.

.PARAMETER CONFIG_PATH
    Specifies the path to the configuration file.

.PARAMETER COMMAND
    Specifies the command to run. Valid values are "run", "view", "restart", "stop", and "delete".

.PARAMETER DESIRED_REPLICA_COUNT
    Specifies the replica count.

.PARAMETER SKIP_CONFIRMATION
    Skips user confirmation when replica count changes.

.EXAMPLE
    SCALING APPLICATION COMMAND EXAMPLES
    ------------------------------------
    .\ScaleContainerGroups.ps1 -CONFIG_PATH .\config.json -COMMAND run -DESIRED_REPLICA_COUNT 2
    Scales up or down the number of Azure Container Groups to a desired state of 2.

    .\ScaleContainerGroups.ps1 -CONFIG_PATH .\config.json -COMMAND view
    Requests a view of all currently provisioned Azure Container Groups.

    .\ScaleContainerGroups.ps1 -CONFIG_PATH .\config.json -COMMAND restart
    Restarts all currently provisioned Azure Container Groups.

    .\ScaleContainerGroups.ps1 -CONFIG_PATH .\config.json -COMMAND stop
    Stops all currently provisioned Azure Container Groups.

    .\ScaleContainerGroups.ps1 -CONFIG_PATH .\config.json -COMMAND delete
    Deletes all currently provisioned Azure Container Groups.

.NOTES
    This script requires the Azure CLI to be installed and configured with the appropriate subscription.
#>

param(
    [Parameter(Mandatory = $true)][string]$CONFIG_PATH,
    [Parameter(Mandatory = $true)][string]$COMMAND,
    [Parameter(Mandatory = $false)][int]$DESIRED_REPLICA_COUNT,
    [Switch]$SKIP_CONFIRMATION
)

#  Summarize to user which args were passed.
Write-Host " "
Write-Host "--------------------------------------------------"
Write-Host "Running command '$COMMAND' with parameters:"
Write-Host "    CONFIG_PATH:           '$CONFIG_PATH'"
Write-Host "    DESIRED_REPLICA_COUNT:         '$(if ($DESIRED_REPLICA_COUNT -eq 0) { '' } else { $DESIRED_REPLICA_COUNT })'"
Write-Host "================================================="
Write-Host " "

# load the config file
$topLevelConfig = (Get-Content -Path $CONFIG_PATH -Raw | ConvertFrom-Json)
$config = $topLevelConfig.config
$containerConfig = $topLevelConfig.containerConfig

## ACI VARS ##

function Show-Usage {

    $allowedArguments = @(
        "-CONFIG_PATH",
        "-COMMAND [run -DESIRED_REPLICA_COUNT | view | restart | stop | delete ]"
    )

    Write-Host "Usage arguments and example:"
    foreach ($argument in $allowedArguments) {
        Write-Host "    $argument"
    }
    Write-Host "Example: .\ScaleContainerGroups.ps1 -CONFIG_PATH .\config.json -COMMAND run -DESIRED_REPLICA_COUNT 2"
}

function Add-ContainerGroups {
    param(
        [Parameter(Mandatory = $true)][int]$StartingNameIndex,
        [Parameter(Mandatory = $true)][int]$Count
    )

    Write-Host " "
    Write-Host "--------------------------------------------------"
    Write-Host "Adding $($Count - $StartingNameIndex) container group(s) using name prefix: $($config.CONTAINER_GROUP_NAME_PREFIX)..." -BackgroundColor Yellow
    Write-Host "--------------------------------------------------"
    Write-Host " "

    # convert env vars to this format:
    # "ENV_VAR_1=value1;"
    $containerEnvironmentVars = @()
    $containerConfig.environmentVars.PSObject.Properties | ForEach-Object {
        $containerEnvironmentVars += "$($_.Name)=$($_.Value)"
    }

    # convert secure env vars 
    $containerSecureEnvironmentVars = @()
    $containerConfig.secureEnvironmentVars.PSObject.Properties | ForEach-Object {
        $containerSecureEnvironmentVars += "$($_.Name)=$($_.Value)"
    }

    # concurrently create the specified number of container groups each with a single container replica
    $jobs = @()
    for ($i = $StartingNameIndex; $i -lt $Count; $i++) {
        $groupName = "$($config.CONTAINER_GROUP_NAME_PREFIX)-" + $i
        $jobs += Start-Job -ScriptBlock {
            param($groupName)
            $response = az container create `
                -g $using:config.RESOURCE_GROUP `
                --name $groupName `
                --image $using:config.IMAGE `
                --location $using:config.LOCATION `
                --ip-address Public `
                --ports $using:containerConfig.PORT `
                --cpu $using:containerConfig.CPU_CORES `
                --memory $using:containerConfig.MEMORY_IN_GB `
                --restart-policy $using:containerConfig.RESTART_POLICY `
                --secure-environment-variables $using:containerSecureEnvironmentVars `
                --environment-variables $using:containerEnvironmentVars `

            if ($LastExitCode -ne 0) {
                throw "Error: $response"
            }

        } -ArgumentList $groupName

        Write-Host "     Running Job - ContainerGroupName: $($groupName)..."
    }

    # wait for all jobs to complete
    $failedJobs = $jobs | Wait-Job | Where-Object { $_.State -eq "Failed" }
    ShowFailedJobs -failedJobs $failedJobs -action "create"

    Write-Host "Container creation for group name prefix: '$($config.CONTAINER_GROUP_NAME_PREFIX)'... Done" -BackgroundColor Green
}

function Remove-ContainerGroups {
    param(
        [Parameter(Mandatory = $true)][int]$StartingNameIndex,
        [Parameter(Mandatory = $true)][string]$Count
    )

    Write-Host " "
    Write-Host "--------------------------------------------------"
    Write-Host "Deleting $($Count - $StartingNameIndex) container group(s) using name prefix: $($config.CONTAINER_GROUP_NAME_PREFIX)..." -BackgroundColor Yellow
    Write-Host "--------------------------------------------------"
    Write-Host " "

    # concurrently delete the specified number of container groups
    $jobs = @()
    for ($i = $StartingNameIndex; $i -lt $Count; $i++) {
        $groupName = "$($config.CONTAINER_GROUP_NAME_PREFIX)-" + $i
        $jobs += Start-Job -ScriptBlock {
            param($groupName)
            $response = az container delete --name $groupName --resource-group $using:config.RESOURCE_GROUP --yes
            if ($LastExitCode -ne 0) {
                throw "Error: $response"
            }
        } -ArgumentList $groupName

        Write-Host "     Running Job - ContainerGroupName: $($groupName)..."
    }

    # wait for all jobs to complete
    $failedJobs = $jobs | Wait-Job | Where-Object { $_.State -eq "Failed" }
    ShowFailedJobs -failedJobs $failedJobs -action "delete"

    Write-Host "Container deletion for group name prefix: '$($config.CONTAINER_GROUP_NAME_PREFIX)'... Done" -BackgroundColor Green
}

function Get-ContainerGroups {
    $response = az container list --resource-group $config.RESOURCE_GROUP
    if ($LastExitCode -ne 0) {
        throw "Error: $response"
    }

    $containerGroups = $response | ConvertFrom-Json
    if ($containerGroups.Count -eq 0) {
        Write-Host "Azure Container Group instances were not found." -BackgroundColor Yellow
        return @()
    }

    # per container group, check if there is a container with the specified prefix
    $matchingContainerGroups = $containerGroups.Where({ $_.containers[0].name -ilike "$($config.CONTAINER_GROUP_NAME_PREFIX)-*" })

    Write-Host "Found $($matchingContainerGroups.Count) matching container(s)..."

    # concurrently get the instance details for each container group's single container
    $jobs = @()
    for ($i = 0; $i -lt $matchingContainerGroups.Count; $i++) {
        $groupName = $matchingContainerGroups[$i].name
        $container = $matchingContainerGroups[$i].containers[0]
        $jobs += Start-Job -ScriptBlock {
            param($container, $groupName)
            $containerGroup = az container show --name $groupName --resource-group $using:config.RESOURCE_GROUP | ConvertFrom-Json
            $container.instanceView = $containerGroup.containers[0].instanceView
            return $container
        } -ArgumentList $container, $groupName

        Write-Host "    Running Job - ContainerGroupName: $($groupName)..."
    }

    $successfulJobs = @()
    $failedJobs = @()
    $jobs | Wait-Job | ForEach-Object {
        if ($_.State -eq "Failed") {
            $failedJobs += $_
        }
        else {
            $successfulJobs += $_ | Receive-Job
        }
    }

    if ($failedJobs.Count -gt 0) {
        Write-Host "Failed jobs:"
        $failedJobs | Format-Table
        throw "Failed to get instance view for containers."
    }

    # initialize the instance details for each container group's single container
    for ($i = 0; $i -lt $successfulJobs.Count; $i++) {
        $matchingContainerGroups[$i].containers[0].instanceView = $successfulJobs[$i].instanceView
    }
    return $matchingContainerGroups
}

function Update-ContainerGroups {
    param(
        [Parameter(Mandatory = $true)][string]$action,
        [Parameter(Mandatory = $false)][array]$containerGroups = @()
    )

    if ($containerGroups.Count -le 0) {
        Write-Host "    No container groups were $($action)ed."
        exit
    }

    Write-Host " "
    Write-Host "--------------------------------------------------"
    Write-Host "$($action)ing $($containerGroups.Count) container(s) for $($config.CONTAINER_GROUP_NAME_PREFIX)..." -BackgroundColor Yellow
    Write-Host "--------------------------------------------------"
    Write-Host " "

    # concurrently perform the specified action on each container group
    $jobs = @()
    for ($i = 0; $i -lt $containerGroups.Count; $i++) {
        $groupName = $containerGroups[$i].name
        $jobs += Start-Job -ScriptBlock {
            param($groupName)
            $response = ""
            switch ($using:action) {
                "delete" {
                    $response = az container delete --name $groupName --resource-group $using:config.RESOURCE_GROUP --yes
                }
                "stop" {
                    $response = az container stop --name $groupName --resource-group $using:config.RESOURCE_GROUP
                }
                "restart" {
                    $response = az container restart --name $groupName --resource-group $using:config.RESOURCE_GROUP
                }
            }
            if ($LastExitCode -ne 0) {
                throw "Error: $response"
            }
        } -ArgumentList $groupName
        Write-Host "     Running Job - ContainerGroupName: $($groupName)..."
    }

    # wait for all jobs to complete
    $failedJobs = $jobs | Wait-Job | Where-Object { $_.State -eq "Failed" }
    ShowFailedJobs -failedJobs $failedJobs -action $action

    Write-Host " "
    Write-Host "All containers $($action)ed." -BackgroundColor Green
}

function Get-DiffTable {
    param (
        [Parameter(Mandatory = $false)]
        [System.Collections.ArrayList]$containerGroups = @()
    )

    # ensure requestCount is a positive integer
    if ($DESIRED_REPLICA_COUNT -lt 0 -or $DESIRED_REPLICA_COUNT -isnot [int]) {
        Write-Host "The desired replica count must be a positive integer."
        exit
    }

    $currentCount = $containerGroups.Count

    # create a table that summarizes the changes that will be made
    $diffTable = @()
    $diff = $DESIRED_REPLICA_COUNT - $currentCount
    $diffTable += [pscustomobject]@{
        GroupNamePrefix = $config.CONTAINER_GROUP_NAME_PREFIX
        CurrentCount    = $currentCount
        RequestCount    = $DESIRED_REPLICA_COUNT
        Diff            = $diff
        # create a column that explains the diff
        Change          = if ($diff -gt 0) { "Add $diff container(s)" } elseif ($diff -lt 0) { "Delete $([math]::Abs($diff)) container(s)" } else { "No change" }
    }

    return $diffTable
}

function ShowFailedJobs {
    param (
        [Parameter(Mandatory = $false)]
        [System.Collections.ArrayList]$failedJobs = @(),
        [Parameter(Mandatory = $false)]
        [string]$action 
    )

    if ($failedJobs.Count -gt 0) {
        Write-Host " "
        Write-Host "--------------------------------------------------"
        Write-Host "Faild Jobs:" -BackgroundColor Red
        Write-Host "--------------------------------------------------"
        Write-Host " "

        foreach ($failedJob in $failedJobs) {
            Write-Host "Error: $($failedJob.ChildJobs[0].Error)"
        }
        Write-Host " "
        throw "Failed to $action container(s) for group name prefix '$($config.CONTAINER_GROUP_NAME_PREFIX)'."
    }
}

switch ($COMMAND) {
    "delete" {
        $containerGroups = @(Get-ContainerGroups)
        Update-ContainerGroups -Action "delete" -containerGroups $containerGroups
    }
    "stop" {
        $containerGroups = @(Get-ContainerGroups)
        Update-ContainerGroups -Action "stop" -containerGroups $containerGroups
    }
    "restart" {
        $containerGroups = @(Get-ContainerGroups)
        Update-ContainerGroups -Action "restart" -containerGroups $containerGroups
    }
    "view" {
        $containerGroups = @(Get-ContainerGroups)

        if ($containerGroups.Count -eq 0) {
            Write-Host "    No containers with prefix '$($config.CONTAINER_GROUP_NAME_PREFIX)' were found. Please check the name and try again."
            exit
        }

        # create a table that shows the state of each container group
        $table = @()
        for ($i = 0; $i -lt $containerGroups.Count; $i++) {

            $table += [pscustomobject]@{
                ContainerGroupName = $containerGroups[$i].name
                Status             = $containerGroups[$i].provisioningState
                RestartPol         = $containerGroups[$i].restartPolicy
                Location           = $containerGroups[$i].location
                Image              = $containerGroups[$i].containers[0].image
                State              = $containerGroups[$i].containers[0].instanceView.currentState.state
                Restarts           = $containerGroups[$i].containers[0].instanceView.restartCount
            }
        }
        $table | Format-Table
    }
    "run" {
        $containerGroups = @(Get-ContainerGroups)

        # create a table that summarizes the changes that will be made
        $diffTable = Get-DiffTable -containerGroups $containerGroups

        # show diff table to user
        $diffTable | Format-Table

        if ($diffTable.Diff -eq 0) {
            Write-Host "    Request does not add or delete a container group replica."
            Write-Host "    No changes will be made."
            Write-Host "    Exiting program."
            exit
        }

        if (!$SKIP_CONFIRMATION) {
            # ask user to confirm changes
            $confirmationMessage = "Do you want to apply the changes shown above? (y/n)"
            $confirmation = Read-Host -Prompt $confirmationMessage
            if ($confirmation -ne "y") {
                Write-Host "No changes were made."
                exit
            }
        }

        # use diff column from diffTable to determine which container groups to add or delete
        $requestCount = $diffTable.RequestCount
        $currentCount = $diffTable.CurrentCount
        $diff = $diffTable.Diff

        if ($diff -gt 0) {
            # add containers
            Add-ContainerGroups -StartingNameIndex $currentCount -Count $requestCount
        }
        elseif ($diff -lt 0) {
            # delete containers
            Remove-ContainerGroups -StartingNameIndex $requestCount -Count $currentCount
        }
        else {
            Write-Host "No changes were made."
        }
    }
    default {
        Write-Host "Unknown command: $COMMAND"
        Show-Usage
    }
}
