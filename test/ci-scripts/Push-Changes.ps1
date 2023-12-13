param(
    [string] $SampleFolder = $ENV:SAMPLE_FOLDER, # this is the path to the sample
    [string] $SampleName = $ENV:SAMPLE_NAME # the name of the sample or folder path from the root of the repo e.g. "sample-type/sample-name"
)

$gitStatus = $(git status)
Write-Output "Found Git Status of: `n $gitStatus"

git diff

git config core.autocrlf
Write-Output "^^^^ autocrlf"
#git config --system core.autocrlf input
        
if($gitStatus -like "*Changes not staged for commit:*" -or 
   $gitStatus -like "*Untracked files:*"){
   
    Write-Output "found changes in $gitStatus"
            
    git config --worktree user.email "azure-quickstart-templates@noreply.github.com"
    git config --worktree user.name "Azure Quickstarts Pipeline"
    
    Write-Output "checkout branch..."
    git checkout "master"

    Write-Output "checking git status..."
    git status
        
    Write-Output "Committing changes..."

    # not sure we want to always add the PR# to the message but we're using it during testing so we can test multiple runs of the pipeline without another PR merge
    # also add the files that were committed to the msg
    $msg = " for ($SampleName)"
    if($gitStatus -like "*azuredeploy.json*"){
        $files = " azuredeploy.json"
    }
    if($gitStatus -like "*readme.md*"){
        $files += " README.md"
    }
    $msg = "update $files $msg ***NO_CI***" # add ***NO_CI*** so this commit doesn't trigger CI

    git add -A -v # for when we add azuredeploy.json for main.bicep samples
    git commit -v -a -m $msg 

    Write-Output "Status after commit..."
    git status
    Write-Output "Pushing..."
    # this triggers the copy badges PR, which will fail every time (we shouldn't trigger it if at all possible) - or run them together
    # TODO ? if multiple pipelines run at the same time, one push will fail since the branch is out of date
    # we need to -f force push or pull first to remedy that, but for now we're batching changes in the CI trigger to account for it
    git pull --no-edit origin "master" # pull in the case where other merging has happened since checkout
    git commit --amend -m $msg # add the msg we want so the PR# is not lost
    git push origin "master" 
    Write-Output "Status after push..."
    git status

}
