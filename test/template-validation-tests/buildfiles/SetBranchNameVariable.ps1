[CmdletBinding()]
param (
    [Parameter(Mandatory=$false)][string]$projectUri = "$env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI",
    [Parameter(Mandatory=$false)][string]$branch = "$env:BUILD_SOURCEBRANCH",
    [Parameter(Mandatory=$false)][string]$repositoryName = "$env:BUILD_REPOSITORY_NAME",
    [Parameter(Mandatory=$false)][string]$projectName = "$env:SYSTEM_TEAMPROJECT",
    [Parameter(Mandatory=$false)][string]$oAuthToken = "$env:SYSTEM_ACCESSTOKEN",
    [Parameter(Mandatory=$false)][string]$username,
    [Parameter(Mandatory=$false)][string]$password
)

#check all parameters
if(!$oAuthToken) {
    if(!$username -or !$password) {
        throw "You must either supply an OAuth Token or a username and a password. You can supply the token via the environment variable SYSTEM_ACCESSTOKEN"
    }

    $basicAuth= ("{0}:{1}"-f $username,$password)
    $basicAuth=[System.Text.Encoding]::UTF8.GetBytes($basicAuth)
    $basicAuth=[System.Convert]::ToBase64String($basicAuth)
    $headers= @{Authorization=("Basic {0}"-f $basicAuth)}
}
else {
    $headers= @{Authorization="Bearer $oAuthToken"}
}

if(!$projectUri) {
    throw "You must supply a project uri or set the Environment variable SYSTEM_TEAMFOUNDATIONCOLLECTIONURI"
}

if(!$branch) {
    throw "You must supply a branch or set the Environment variable BUILD_branch"
}

if(!$repositoryName) {
    throw "You must supply a repository name or set the Environment variable BUILD_REPOSITORY_NAME"
}

if(!$projectName) {
    throw "You must supply a project name or set the Environment variable SYSTEM_TEAMPROJECT"
}

#get pull request ID via regex
$pullrequest = "refs/pull/+(?<pullnumber>\w+?)/merge+"
if($branch -match $pullrequest) {        
    $pullrequestid = $Matches.pullnumber;
    Write-Output "Pull request ID is $pullrequestid"
    #get pull request information via API
    $url= $projectUri + "DefaultCollection/$projectName/_apis/git/repositories/$repositoryName/pullRequests/$pullrequestid\?api-version=1.0-preview.1"

    Write-Output "Getting info from $url"
    $getpullrequest = Invoke-RestMethod -Uri $url -headers $headers -Method Get

    #get sourcebranch and targetbranch ref
    $sourceref = $getpullrequest.sourceRefName
    $targetref = $getpullrequest.targetRefName

    #get the branch name via regex
    $branchref = "refs/heads/(?<realBranchname>.*)"
    if($sourceref -match $branchref) {        
        $sourcebranch = $Matches.realBranchname;
        Write-Output "Real source branch is $sourcebranch"
    }
    else { 
        Write-Output "Cannot find real source branch" 
    }
    if($targetref -match $branchref) {        
        $targetbranch = $Matches.realBranchname;
        Write-Output "Real target branch is $targetbranch"
    }
    else { 
        Write-Output "Cannot find real target branch" 
    }
}
else { 
  
   $branchref = "refs/heads/(?<realBranchname>.*)"
    if($branch -match $branchref) {        
        $sourcebranch = $Matches.realBranchname;
        Write-Output "Real source branch is $sourcebranch"
    }
     else { 
        Write-Output "Cannot find real source branch" 
    }
}

#set a variable "sourcebranch" to use it in another build task
Write-Output "##vso[task.setvariable variable=sourcebranch;]$sourcebranch"