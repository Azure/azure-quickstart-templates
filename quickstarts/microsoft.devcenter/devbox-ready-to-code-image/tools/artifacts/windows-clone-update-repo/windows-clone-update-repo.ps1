<#
.DESCRIPTION
    Allows cloning a new or updating an existing repo (important for updating a chained image).
#>
param(
    # Url of the repository to clone/sync.
    [Parameter(Mandatory = $true)]
    [string] $repoUrl,

    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory = $true)]
    [String] $repository_TargetDirectory,

    # The repository Source Control options are git (default) or gvfs
    [Parameter(Mandatory = $false)]
    [String] $repository_SourceControl,

    [Parameter(Mandatory = $false)]
    [bool] $repository_cloneIfNotExists = $false,

    [Parameter(Mandatory = $false)]
    [string] $repoName,

    # The commit id to fetch/check out for the repo. $commitId is ignored if $branchName is provided.
    [Parameter(Mandatory = $false)]
    [string] $commitId = 'latest',

    # When provided, this is the branch to clone/fetch. Otherwise the default branch is cloned/pulled.
    [Parameter(Mandatory = $false)]
    [string] $branchName,

    [Parameter(Mandatory = $false)]
    [string] $repository_optionalCloningParameters,

    [Parameter(Mandatory = $false)]
    [string] $repository_optionalFetchParameters,

    [Parameter(Mandatory = $false)]
    [bool] $enableGitCommitGraph = $false,

    # Optional comma separated list of folders for sparse checkout. When provided, only these folders will be set and sparse-checkout is used for the repo
    [Parameter(Mandatory = $false)]
    [string] $sparseCheckoutFolders,

    # Optional MSI client ID which is required if the VM has multiple user-assigned managed identities. This will be used to access Azure DevOps.
    [Parameter(Mandatory = $false)]
    [string] $repository_MSIClientId = $null
)

enum SourceControl {
    git = 0  # default
    gvfs
}

$logfilepath = $null
$global:varLogArray = New-Object -TypeName "PSCustomObject"
Function ProcessRunner(
    [string]$command,
    [string]$arguments,
    [string]$argumentsToLog = '',
    [bool] $checkForSuccess = $true,
    [bool] $waitForDependents = $true
) {
    <#
  .DESCRIPTION
  Run a process and validate that the process started and completed without any errors  
  .PARAMETER command
  The command that will be run
  .PARAMETER arguments
  The arguments required to run the supplied command. Do not use in logging as the string may contains a secret.
  .PARAMETER argumentsToLog
  The arguments representation that is safe to log
  .PARAMETER checkForSuccess
  If $false then do not check whether the command succeeded
  #>

    if (!$argumentsToLog) {
        $argumentsToLog = $arguments
    }

    $errLog = [System.IO.Path]::GetTempFileName()

    if ($waitForDependents) {
        $process = Start-Process -FilePath $command -ArgumentList $arguments -RedirectStandardError $errLog -Wait -PassThru -NoNewWindow
    }
    else {
        $process = Start-Process -FilePath $command -ArgumentList $arguments -RedirectStandardError $errLog -PassThru -NoNewWindow
    }

    # If $process variable is null, something is wrong
    if (!$process) {           
        Write-Error "ERROR command failed to start: $command $argumentsToLog"
        return;
    }
 
    if ($waitForDependents) {
        $ExitCode = $process.ExitCode
    }
    else {
        # This will wait for the process to exit as Start-Process above will not block for the process to exit
        $process.WaitForExit()

        # There is a defect where the $process.ExitCode is empty.
        # The full details is at https://stackoverflow.com/questions/10262231/obtaining-exitcode-using-start-process-and-waitforexit-instead-of-wait
        # The below is the workaround for the defect
        $process.HasExited  # This will calculate the exitCode
        $ExitCode = $process.GetType().GetField("exitCode", "NonPublic,Instance").GetValue($process) # Get the ExitCode from the hidden field but it is not publicly available
    }
    
    if ($ExitCode -ne 0) {
        Write-Output "Error running: $command $argumentsToLog"
        Write-Output "Exit code: $ExitCode"
        Write-Output "**ERROR**"
        Get-Content -Path $errLog

        # if logfilepath is set, write that out too if the process exited
        if ([System.String]::IsNullOrWhiteSpace($logfilepath) -ne $true -and [System.IO.File]::Exists($logfilepath) -eq $true) {
            Write-Host "Logfile output from '$logfilepath':"
            Get-Content $logfilepath
        }

        if ($checkForSuccess) {
            throw "Exit code from process was nonzero"
        }
        else {
            Write-Output "==Ignored the error"
        }
    }
}

<#
.DESCRIPTION
    Gvfs clones the repository and checks out to the specified gitBranchName
#> 
function GvfsCloneGitRepo {
    Param(
        [ValidateNotNullOrEmpty()] $gitExeLocation,
        [ValidateNotNullOrEmpty()] $gvfsExeLocation,
        [ValidateNotNullOrEmpty()] $gvfsRepoLocation,
        [ValidateNotNullOrEmpty()] $gvfsLocalRepoLocation,
        [string] $gitBranchName,
        [string] $msiClientId
    )
    # pre-condition checks
    if ($false -eq $gvfsRepoLocation.ToLowerInvariant().StartsWith("https://")) {
        $errMsg = $("Error! The specified Gvfs repo url is not a valid HTTPS clone url : " + $gvfsRepoLocation)
        Write-Host $errMsg
        Throw $errMsg
    }
    
    if ($false -eq ($gvfsRepoLocation.Length -gt 8)) {
        $errMsg = $("Error! The specified Git repo url is not valid : " + $gvfsRepoLocation)
        Write-Host $errMsg
        Throw $errMsg
    }

    $cmdArgs = $(" " + $gvfsRepoLocation + " `"" + $gvfsLocalRepoLocation + "`"")

    # Known Issue: gvfs clone does not work with -b <branch> option.
    # So, first gvfs clone without -b <branch> option
    # then, next git checkout <branch>
    Write-Host $("Gvfs cloning the git repo...")

    # Limitation: gvfs clone doesn't take a -c parameter like git clone.
    # So, the workaround is to configure and Unconfigure a custom credential.helper using "git config"
    $prevCredentialHelper = &$gitExeLocation config --system credential.helper

    # Configure credential.helper using "git config"
    $GitAccessToken = Get-GitAccessToken -MsiClientID $msiClientId
    $CredentialHelper = "`"!f() { test `"`$1`" = get && echo username=AzureManagedIdentity; echo password=$GitAccessToken; }; f`""
    ExecuteGitCmd -gitExeLocation $gitExeLocation -gitCmd "config" -gitCmdArgs "--system credential.helper $CredentialHelper" -argumentsToLog "--system credential.helper CUSTOM_AUTH_SCRIPT"

    $runBlock = {
        # gvfs clone
        ExecuteGvfsCmd -gvfsExeLocation $gvfsExeLocation -gvfsCmd "clone" -gvfsCmdArgs $cmdArgs
    }
    RunWithRetries -runBlock $runBlock -retryAttempts 5 -waitBeforeRetrySeconds 30 -onFailureBlock {}

    # Unconfigure credential.helper using "git config"
    ExecuteGitCmd -gitExeLocation $gitExeLocation -gitCmd "config" -gitCmdArgs "--system credential.helper $prevCredentialHelper"
}

function Get-CanUseManagedIdentityForRepo {
    param(
        [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][String] $RepoUrl
    )

    return ($RepoUrl -Match '^https://[a-zA-Z][\w\-_]*\.visualstudio\.com/.*' -or $RepoUrl -Match '^https://dev\.azure\.com/.*')
}

<#
.DESCRIPTION
    Clones the repository and checks out to the specified CommitId
#> 
function CloneGitRepo {
    Param(
        [ValidateNotNullOrEmpty()] $gitExeLocation,
        [ValidateNotNullOrEmpty()] $gitRepoLocation,
        [ValidateNotNullOrEmpty()] $gitLocalRepoLocation,
        [string] $gitBranchName,
        [Parameter(Mandatory = $false)] $optionalGitCloneArgs,
        [Parameter(Mandatory = $false)] $formattedSparseCheckoutFolders,
        [Parameter(Mandatory = $false)][string] $msiClientId
    )
    # pre-condition checks
    if ($false -eq $gitRepoLocation.ToLowerInvariant().StartsWith("https://")) {
        $errMsg = $("Error! The specified Git repo url is not a valid HTTPS clone url : " + $gitRepoLocation)
        Write-Host $errMsg
        Throw $errMsg
    }
    
    if ($false -eq ($gitRepoLocation.Length -gt 8)) {
        $errMsg = $("Error! The specified Git repo url is not valid : " + $gitRepoLocation)
        Write-Host $errMsg
        Throw $errMsg
    }

    # Using specified credentials, create the actual repo url to clone from.
    $authorizationHeader = ''
    if (Get-CanUseManagedIdentityForRepo -RepoUrl $gitRepoLocation) {
        $authorizationHeader = Get-GitAuthorizationHeader -MsiClientID $msiClientId
    }

    # Prep to start git.exe
    # Add optional git clone parameters
    $optionalArgs = ""
    if (!([System.String]::IsNullOrWhiteSpace($optionalGitCloneArgs))) {
        $optionalArgs = $optionalGitCloneArgs
    }

    if (![string]::IsNullOrEmpty($gitBranchName)) {
        $optionalArgs = "-b $gitBranchName " + $optionalArgs
    }

    if (-not [string]::IsNullOrEmpty($formattedSparseCheckoutFolders)) {
        # Clone the repo without checking out any files. Sparse checkout folders will be set after clone, and then checked out.
        $optionalArgs = $optionalArgs + " --no-checkout"
    }

    $cmdArgs = $($optionalArgs + " " + $gitRepoLocation + " `"" + $gitLocalRepoLocation + "`"")

    Write-Host $("Cloning the git repo...")
    $runBlock = {
        # Remove existing repo folder in case it was created by the previous clone attempt
        if (Test-Path $gitLocalRepoLocation) {
            Remove-Item $gitLocalRepoLocation -Recurse -Force
        }

        ExecuteGitCmd -gitExeLocation $gitExeLocation -gitCmd "clone" -authHeader $authorizationHeader -gitCmdArgs $cmdArgs
    }
    RunWithRetries -runBlock $runBlock -retryAttempts 5 -waitBeforeRetrySeconds 30 -onFailureBlock {}

    Write-Host Changing to repo location: $("'$gitLocalRepoLocation'")
    Set-Location $gitLocalRepoLocation

    # If sparse checkout, repo was cloned with --no-checkout option. Set folders desired for checkout, then check them out.
    if (-not [string]::IsNullOrEmpty($formattedSparseCheckoutFolders)) {
        $sparseGitCmd = "set $formattedSparseCheckoutFolders"

        # Set sparse-checkout folders for checkout, then check them out
        ExecuteGitCmd -gitExeLocation $gitExeLocation -gitCmd "sparse-checkout" -authHeader $authorizationHeader -gitCmdArgs $sparseGitCmd -argumentsToLog $sparseGitCmd
        ExecuteGitCmd -gitExeLocation $gitExeLocation -gitCmd "checkout" -authHeader $authorizationHeader
    }
}

<#
.DESCRIPTION
    Updates the local repository to the commit ID specified
#> 
function UpdateGitRepo {
    param(
        [ValidateNotNullOrEmpty()] $gitExeLocation,
        [ValidateNotNullOrEmpty()] $gitRepoLocation,
        [ValidateNotNullOrEmpty()] $gitLocalRepoLocation,
        [string] $gitBranchName,
        [string] $commitId,
        [string] $optionalFetchArgs,
        [string] $formattedSparseCheckoutFolders,
        [Parameter(Mandatory = $false)][string] $msiClientId
    )

    # pre-condition checks
    if ($false -eq $gitRepoLocation.ToLowerInvariant().StartsWith("https://")) {
        $errMsg = $("Error! The specified Git repo url is not a valid HTTPS url : " + $gitRepoLocation)
        Write-Error $errMsg
        Throw $errMsg
    }
    
    if ($false -eq $gitRepoLocation.Length -gt 8) {
        $errMsg = $("Error! The specified Git repo url is not valid : " + $gitRepoLocation)
        Write-Error $errMsg
        Throw $errMsg
    }
    # Using specified credentials, create the actual repo url to update
    $authorizationHeader = ''
    if (Get-CanUseManagedIdentityForRepo -RepoUrl $gitRepoLocation) {
        $authorizationHeader = Get-GitAuthorizationHeader -MsiClientID $msiClientId
    }

    $baseRepoSparseCheckout = Invoke-Expression -Command '&$gitExeLocation config --get core.sparseCheckout'
    if ([string]::IsNullOrEmpty($baseRepoSparseCheckout)) {
        $baseRepoSparseCheckout = $false
    }

    $repoSparseCheckout = $false
    if (-not [string]::IsNullOrEmpty($formattedSparseCheckoutFolders)) {
        $repoSparseCheckout = $true
    }

    if ($repoSparseCheckout -ne $baseRepoSparseCheckout) {
        Write-Host "Base image sparse checkout configuration: $baseRepoSparseCheckout"
        Write-Host "Image sparse checkout configuration: $repoSparseCheckout"
        throw "Sparse checkout configuration misaligned with base image"
    }

    $optionalArgs = ""
    if (!([System.String]::IsNullOrWhiteSpace($optionalFetchArgs))) {
        $optionalArgs = $optionalFetchArgs
    }

    # Explicitly specified branch takes precedence over commitId
    if (![string]::IsNullOrEmpty($gitBranchName)) {
        # Check out a temporary branch to be able to delete the requested one in case it is currently checked out
        $tempBranch = (New-Guid).Guid
        ExecuteGitCmd -gitExeLocation $gitExeLocation -gitCmd "checkout" -authHeader $authorizationHeader -gitCmdArgs "-b $tempBranch"

        # Delete local branch in case it already exists
        ExecuteGitCmd -gitExeLocation $gitExeLocation -gitCmd "branch" -gitCmdArgs "-D $gitBranchName" -checkForSuccess $false

        ExecuteGitCmd -gitExeLocation $gitExeLocation -gitCmd "fetch" -authHeader $authorizationHeader -gitCmdArgs "origin $($gitBranchName):$($gitBranchName) $optionalArgs"

        # (Re)create the local branch
        ExecuteGitCmd -gitExeLocation $gitExeLocation -gitCmd "checkout" -authHeader $authorizationHeader -gitCmdArgs "$gitBranchName"

        ExecuteGitCmd -gitExeLocation $gitExeLocation -gitCmd "branch" -gitCmdArgs "-D $tempBranch"
    }
    elseif ($commitId -ne 'latest') {
        Write-Host "Fetching commit $commitId"
        ExecuteGitCmd -gitExeLocation $gitExeLocation -gitCmd "fetch" -authHeader $authorizationHeader -gitCmdArgs "origin $commitId $optionalArgs"

        # Reset command may need to reach out to ADO when GIT LFS is used
        Write-Host "Resetting branch to $commitId"
        ExecuteGitCmd -gitExeLocation $gitExeLocation -gitCmd "reset" -authHeader $authorizationHeader -gitCmdArgs "$commitId --hard"
    }
    else {
        Write-Host "Pulling the latest commit"
        ExecuteGitCmd -gitExeLocation $gitExeLocation -gitCmd "pull" -authHeader $authorizationHeader -gitCmdArgs $optionalArgs
    }

    $logExpression = '&$gitExeLocation log -1 --quiet --format=%H'
    $updateCommitID = Invoke-Expression -Command $logExpression
    Add-VarForLogging -varName 'CommitID' -varValue $updateCommitID
}

<#
.DESCRIPTION
    Executes a git command with arguments
#> 
function ExecuteGitCmd {
    param(
        [ValidateNotNullOrEmpty()][string] $gitExeLocation,
        [ValidateNotNullOrEmpty()][string] $gitCmd,
        [string] $gitCmdArgs,
        [string] $authHeader = '',
        [bool] $checkForSuccess = $true,
        # If $gitCmdArgs contain secrets the caller is responsible for providing the alternative string to log
        [string]$argumentsToLog = ''
    )

    if (!$argumentsToLog) {
        $argumentsToLog = $gitCmdArgs
    }

    Write-Host $("Running: ""$gitExeLocation"" $gitCmd $argumentsToLog")
    $arguments = "$($authHeader)$gitCmd $gitCmdArgs"
    ProcessRunner -command $gitExeLocation -arguments $arguments -argumentsToLog "$gitCmd $argumentsToLog" -checkForSuccess $checkForSuccess
}

<#
.DESCRIPTION
    Executes a gvfs command with arguments
#> 
function ExecuteGvfsCmd {
    param(
        [ValidateNotNullOrEmpty()][string] $gvfsExeLocation,
        [ValidateNotNullOrEmpty()][string] $gvfsCmd,
        [string] $gvfsCmdArgs,
        [bool] $checkForSuccess = $true,
        # If $gitCmdArgs contain secrets the caller is responsible for providing the alternative string to log
        [string]$argumentsToLog = ''
    )

    if (!$argumentsToLog) {
        $argumentsToLog = $gvfsCmdArgs
    }

    Write-Host $("Running: ""$gvfsExeLocation"" $gvfsCmd $argumentsToLog")
    $arguments = "$gvfsCmd $gvfsCmdArgs"
    # gvfs clone creates a child process (gvfs.mount.exe) which never exits. gvfs.mount.exe exits only after a gvfs unmount which is done later (if needed).
    # So, dont -Wait during Start-Process for gvfs clone
    ProcessRunner -command $gvfsExeLocation -arguments $arguments -argumentsToLog "$gvfsCmd $argumentsToLog" -checkForSuccess $checkForSuccess -waitForDependents $false
}

# Applies configuration that doesn't require the repo to be cloned but may be needed for the clone to succeed, e.g. core.longpaths
function ConfigureGitRepoBeforeClone {
    Param(
        [ValidateNotNullOrEmpty()] $gitExeLocation
    )

    ExecuteGitCmd -gitExeLocation $gitExeLocation -gitCmd "config" -gitCmdArgs "--system core.safecrlf true"
    ExecuteGitCmd -gitExeLocation $gitExeLocation -gitCmd "config" -gitCmdArgs "--system push.default simple"
    ExecuteGitCmd -gitExeLocation $gitExeLocation -gitCmd "config" -gitCmdArgs "--system core.preloadindex true"
    ExecuteGitCmd -gitExeLocation $gitExeLocation -gitCmd "config" -gitCmdArgs "--system core.fscache true"
    ExecuteGitCmd -gitExeLocation $gitExeLocation -gitCmd "config" -gitCmdArgs "--system core.longpaths true"
}

# Applies configuration that requires the repo to be cloned
function ConfigureGitRepoAfterClone {
    Param(
        [ValidateNotNullOrEmpty()] $gitExeLocation,
        [ValidateNotNullOrEmpty()][string] $gitLocalRepoLocation,
        [ValidateNotNullOrEmpty()] [bool] $enableGitCommitGraph
    )

    ExecuteGitCmd -gitExeLocation $gitExeLocation -gitCmd "config" -gitCmdArgs "--system --add safe.directory $($gitLocalRepoLocation -replace '\\','/')"
    if ($enableGitCommitGraph -eq $true) {
        ExecuteGitCmd -gitExeLocation $gitExeLocation -gitCmd "config" -gitCmdArgs "--local core.commitGraph true"
        ExecuteGitCmd -gitExeLocation $gitExeLocation -gitCmd "config" -gitCmdArgs "--local gc.writeCommitGraph true"
        ExecuteGitCmd -gitExeLocation $gitExeLocation -gitCmd "commit-graph" -gitCmdArgs "write --reachable"
    }
}

<#
.DESCRIPTION
    Calls update of the targetDirectory is a valid repository. Else it will attempt to clone the repository.
#> 
function UpdateOrCloneRepo {
    param(
        [ValidateNotNullOrEmpty()][string] $repoUrl,
        [ValidateNotNullOrEmpty()][string] $targetDirectory,
        [SourceControl]$sourceControl,
        [ValidateNotNullOrEmpty()][string] $commitId,
        [string] $gitBranchName,
        [string] $optionalCloneArgs,
        [bool] $cloneIfNotExists,
        [string] $optionalFetchArgs,
        [bool] $enableGitCommitGraph,
        [string] $formattedSparseCheckoutFolders,
        [string] $msiClientId
    )

    switch ($sourceControl) {
        { ($_ -eq [SourceControl]::git) -or ($_ -eq [SourceControl]::gvfs) } {
            # Get git install location
            $gitexe = Get-Command git
            $GitExeLocation = $gitexe.Source
        }
        { $_ -eq [SourceControl]::gvfs } {
            # Get gvfs install location
            $gvfsexe = Get-Command gvfs
            $GvfsExeLocation = $gvfsexe.Source
        }
    }

    ## Update or Clone Repo
    $shouldCloneRepo = $false

    # We don't need to fully url-encode the repo url. However we should replace whitespaces with '%20'. 
    if ($repoUrl.Contains(" ")) {
        $repoUrl = $repoUrl.Replace(" ", "%20")
    }

    # If the Folder exists
    if (!(Test-Path -Path $targetDirectory -PathType Container)) {
        if ($cloneIfNotExists -eq $true) {
            $shouldCloneRepo = $true
        }
        else {
            Write-Host "folder not found at '$targetDirectory'."
            throw "folder not found."
        }
    }
    else {
        Set-Location $targetDirectory

        switch ($sourceControl) {
            git {
                Write-Host "Testing if '$targetDirectory' hosts a git repository..."

                # git remote will return an error if this is not a git repository
                $repo_originUrl = &$GitExeLocation remote get-url origin 
            }
            gvfs {
                Write-Host "Testing if '$targetDirectory' hosts a gvfs repository..."

                # gvfs status will return an error if this is not a gvfs repository
                &$GvfsExeLocation status

                if ($? -eq $true) {
                    # gvfs repository is always at "src" folder
                    Set-Location (Join-Path $targetDirectory "src")

                    # git remote will return an error if this is not a git repository
                    $repo_originUrl = &$GitExeLocation remote get-url origin 
                }
            }
        }

        if ($? -eq $false) {
            if ($cloneIfNotExists -eq $true) {
                $shouldCloneRepo = $true
            }
            else {
                Write-Host "repository not found at '$targetDirectory'."
                throw "Repository not found."
            }
        }
    }

    # If for some reason one of the checks above fails, we need to clone the repo.
    if ($shouldCloneRepo -eq $true) {
        # folder doesn't exist, clone into the folder

        ConfigureGitRepoBeforeClone -gitExeLocation $GitExeLocation
        switch ($sourceControl) {
            git {
                CloneGitRepo -gitExeLocation $GitExeLocation -gitRepoLocation $repoUrl -gitLocalRepoLocation $targetDirectory -gitBranchName $gitBranchName -optionalGitCloneArgs $optionalCloneArgs -formattedSparseCheckoutFolders $formattedSparseCheckoutFolders -msiClientId $msiClientId
            }
            gvfs {
                GvfsCloneGitRepo -gitExeLocation $GitExeLocation -gvfsExeLocation $GvfsExeLocation -gvfsRepoLocation $repoUrl -gvfsLocalRepoLocation $targetDirectory -gitBranchName $gitBranchName -msiClientId $msiClientId

                # git repository is always at "src" folder
                $targetDirectory = Join-Path $targetDirectory "src"
            }
        }

        Write-Host Changing to repo location: $("'$targetDirectory'")
        Set-Location $targetDirectory
    
        # update repo_originUrl to the new location
        $repo_originUrl = &$GitExeLocation remote get-url origin 

        ConfigureGitRepoAfterClone -gitExeLocation $GitExeLocation -gitLocalRepoLocation $targetDirectory -enableGitCommitGraph $enableGitCommitGraph
    }

    if ($shouldCloneRepo -and $commitId -eq 'latest') {
        Write-Host "Skip pulling latest updates for just cloned repo: $repo_originUrl"
    } 
    else {
        Write-Host Updating repo with Url: $repo_originUrl
        UpdateGitRepo -gitExeLocation $GitExeLocation -gitRepoLocation $repo_originUrl -gitLocalRepoLocation $targetDirectory -gitBranchName $gitBranchName -commitId $commitId -optionalFetchArgs $optionalFetchArgs -msiClientId $msiClientId
    }
}

function Add-VarForLogging ($varName, $varValue) {
    <#
  .DESCRIPTION
  Add a row to the logging array but only if the value is not null or whitespace
  .PARAMETER varName
  Name of the variable  
  .PARAMETER varValue
  Value of the variable
  #>

    if (!([string]::IsNullOrWhiteSpace($varValue))) {
        $global:varLogArray | Add-Member -MemberType NoteProperty -Name $varName -Value $varValue
    }
}

function RunScriptSyncRepo(
    $repoUrl,
    $repository_TargetDirectory,
    [SourceControl]$repository_SourceControl,
    $repository_cloneIfNotExists = $false,
    $repoName,
    $commitId,
    $branchName,
    $repository_optionalCloningParameters,
    $repository_optionalFetchParameters,
    $enableGitCommitGraph,
    $sparseCheckoutFolders,
    $repository_MSIClientId
) {

    $logfilepath = $null
    $global:varLogArray = New-Object -TypeName "PSCustomObject"
    Set-StrictMode -Version Latest
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls

    # Track starting directory so we can reset it back at the end of the script
    $startingDirectory = Get-Location

    # Set Repo Log file path
    $repoLogFilePath = 'c:\.tools\RepoLogs'

    try {
        # Create log file location
        mkdir "$repoLogFilePath" -Force

        switch ($repository_SourceControl) {
            { ($_ -eq [SourceControl]::git) -or ($_ -eq [SourceControl]::gvfs) } {
                # Get git install location
                $gitexe = Get-Command git
                $GitExeLocation = $gitexe.Source

                # confirm git is there
                ProcessRunner -command $GitExeLocation -arguments "version"
                if ($? -ne $true) {
                    Write-Error Unable to find git.exe.
                    exit 1
                }
            }
            { $_ -eq [SourceControl]::gvfs } {
                # Get gvfs install location
                $gvfsexe = Get-Command gvfs
                $GvfsExeLocation = $gvfsexe.Source

                # confirm gvfs is there
                ProcessRunner -command $GvfsExeLocation -arguments "version"

                if ($? -ne $true) {
                    Write-Error Unable to find gvfs.exe.
                    exit 1
                }
            }
        }

        Write-Host --------------------------------------
        Write-Host "Repository name: '$repoName'"
        Write-Host "Commit id: '$commitId'"
        Write-Host "BranchName name: '$branchName'"
        Write-Host --------------------------------------

        # Add input data variables to log array
        Add-VarForLogging -varName 'RepoURL' -varValue $repoUrl
        Add-VarForLogging -varName 'repository_TargetDirectory' -varValue $repository_TargetDirectory
        
        if (!([string]::IsNullOrWhiteSpace($branchName))) {
            Write-Host "Use explicitly provided branch '$branchName' rather than commitId"
            $commitId = 'latest'
        }

        if ([string]::IsNullOrWhiteSpace($repoUrl)) {
            throw "RepoUrl must be known at this point"
        }

        $formattedSparseCheckoutFolders = ""
        if (-not [string]::IsNullOrWhiteSpace($sparseCheckoutFolders)) {
            $quotedFolders = $sparseCheckoutFolders -Split ',' | ForEach-Object { '"' + $_ + '"' }
            $formattedSparseCheckoutFolders = $quotedFolders -Join " "
        }


        ## Update or Clone repo
        UpdateOrCloneRepo -repoUrl $repoUrl -commitId $commitId -gitBranchName $branchName -enableGitCommitGraph $enableGitCommitGraph -targetDirectory $repository_TargetDirectory -sourceControl $repository_SourceControl -optionalCloneArgs $repository_optionalCloningParameters -cloneIfNotExists $repository_cloneIfNotExists -optionalFetchArgs $repository_optionalFetchParameters -formattedSparseCheckoutFolders $formattedSparseCheckoutFolders -msiClientId $repository_MSIClientId

        Write-Host "Var Log Array"
        Write-Host $global:varLogArray | ConvertTo-Json

        # Set the file name for logging repo sync variables
        Write-Host "Derive Repo Log Name"
        $repoLogFileName = [IO.Path]::GetFileName("$repository_TargetDirectory") + ".json"

        # Write out file to output location
        $outFile = "$repoLogFilePath\$repoLogFileName"
        Write-Host "Write output file to " $outFile
        $global:varLogArray | ConvertTo-Json | Out-File -FilePath $outFile

        Write-Host Completed!
    }
    catch {
        Write-Host -Object $_
        Write-Host -Object $_.ScriptStackTrace

        if (($null -ne $Error[0]) -and ($null -ne $Error[0].Exception) -and ($null -ne $Error[0].Exception.Message)) {
            $errMsg = $Error[0].Exception.Message
            Write-Host $errMsg
            Write-Error $errMsg
        }

        if ([System.String]::IsNullOrWhiteSpace($logfilepath) -ne $true -and [System.IO.File]::Exists($logfilepath) -eq $true) {
            Write-Host "Logfile output from '$logfilepath':"
            Get-Content $logfilepath
        }

        Write-Host 'Script failed.'
        Set-Location $startingDirectory
        exit 1
    }
    Set-Location $startingDirectory
}

if ((-not (Test-Path variable:global:IsUnderTest)) -or (-not $global:IsUnderTest)) {

    # If the optional parameter $repository_SourceControl is NOT passed in, default to git
    [SourceControl]$sourceControl = [SourceControl]::git

    # If the optional parameter $repository_SourceControl is passed in, ensure it has a valid value
    if (-not [String]::IsNullOrEmpty($repository_SourceControl)) {
        $sourceControl = [Enum]::Parse([SourceControl], $repository_SourceControl)
    }

    Import-Module -Force (Join-Path $(Split-Path -Parent $PSScriptRoot) '_common/windows-azure-managed-identity-utils.psm1')
    Import-Module -Force (Join-Path $(Split-Path -Parent $PSScriptRoot) '_common/windows-retry-utils.psm1')

    RunScriptSyncRepo `
        -repoUrl $repoUrl `
        -repository_TargetDirectory $repository_TargetDirectory `
        -repository_SourceControl  $sourceControl `
        -repository_cloneIfNotExists $repository_cloneIfNotExists `
        -repoName $repoName `
        -commitId $commitId `
        -branchName $branchName `
        -repository_optionalCloningParameters $repository_optionalCloningParameters `
        -repository_optionalFetchParameters $repository_optionalFetchParameters `
        -enableGitCommitGraph $enableGitCommitGraph `
        -sparseCheckoutFolders $sparseCheckoutFolders `
        -repository_MSIClientId $repository_MSIClientId `

}