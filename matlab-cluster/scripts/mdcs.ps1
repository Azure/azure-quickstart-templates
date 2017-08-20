# Utility to setup/delete/list/pause/resume mdcs cluster

# Global configuration
$script:GITHUB_BASE_URL = "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/matlab-cluster/"

function PrepAzureContext() {
  echo "Validating Azure logon..."
  while($true) {
    $script:current_subscriptions = (Get-AzureRmSubscription) # cached for create use, if necessary
    if(-not $?) {
      echo "No active login account, log in now..."
      Login-AzureRmAccount
    } else {
      break
    }
  }
}


function mdcs_create($p) {
  function readstring($info, $default) {
    $response = Read-Host -Prompt "$info [$default]"
    if(-not $response) {
      $response = $default
    }
    return $response
  }

  function parse_init($p) {
    $script:inifile_entries = @("ClusterName", "NumWorkerVms", "NumWorkersOnMjsVm", "NumWorkersOnWorkerVms", "ClientVmSize", "MJSVmSize", "WorkerVmSize", "VmUsername", "SubscriptionId", "Region", "BaseVmVhd", "ClusterVmVhdContainer", "SubscriptionId")

    # load static default config
    $script:config = @{}
    foreach ($entry in $inifile_entries) {
      $script:config[$entry] = ""
    }

    # parse args
    if($p.Count -gt 0) {
      echo "using conf file at $($p[0])"
      $script:config["inifile"] = $p[0]
    } else {
      echo "using default location for mdcsconf.ini"
      $script:config["inifile"] = "mdcsconf.ini"
    }

    # load config from ini file
    if(Test-Path $script:config["inifile"]) {
      echo "parsing init file"
      $iniContent = Get-IniContent $script:config["inifile"]
      if($iniContent.ContainsKey("config")) {
        foreach ($entry in $inifile_entries) {
          if($iniContent["config"].ContainsKey($entry)) {
            $script:config[$entry] = $iniContent["config"][$entry]
          }
        }
      }
    }
  }

  function Get-IniContent ($filePath)
  {
      $ini = @{}
      switch -regex -file $FilePath
      {
          "^\[(.+)\]" # Section
          {
              $section = $matches[1]
              $ini[$section] = @{}
              $CommentCount = 0
          }
          "^(;.*)$" # Comment
          {
              $value = $matches[1]
              $CommentCount = $CommentCount + 1
              $name = "Comment" + $CommentCount
              $ini[$section][$name] = $value
          }
          "(.+?)\s*=(.*)" # Key
          {
              $name,$value = $matches[1..2]
              $ini[$section][$name] = $value
          }
      }
      return $ini
  }

  parse_init($p)

  $subs = ($script:current_subscriptions | % {$_.SubscriptionId})
  if($subs -contains $script:config["SubscriptionId"]) {
    Set-AzureRmContext -SubscriptionId $script:config["SubscriptionId"]
  } else {
    echo "Configured subscription is not found in the subscription list of current account, exiting"
    #exit
  }

  echo "Downloading setup templates..."
  $datetimestr = (Get-Date).ToString('yyyy-MM-dd-HH-mm-ss')
  $template_uri = $script:GITHUB_BASE_URL + "azuredeploy.json"
  $template_param_uri = $script:GITHUB_BASE_URL + "scripts\azuredeploy.parameters.script.driven.template.json"
  $template = "$env:TEMP\mdcs-$datetimestr.json"
  $template_param = "$env:TEMP\mdcs-param-$datetimestr.json"
  $updated_template_param = "$env:TEMP\mdcs-param-updated-$datetimestr.json"

  Invoke-WebRequest $template_uri -OutFile $template
  Invoke-WebRequest $template_param_uri -OutFile $template_param

  echo "a few questions..."
  $rgname = readstring "ResourceGroup" $script:config["ClusterName"]
  $script:config["ClusterName"] = $rgname

  $location = readstring "Location" $script:config["Region"]
  $script:config["Region"] = $location

  $ClientVmSize = readstring "Client VM Size" $script:config["ClientVmSize"]
  $MJSVmSize = readstring "MJS VM Size" $script:config["MJSVmSize"]
  $WorkerVmSize = readstring "Worker VM Size" $script:config["WorkerVmSize"]
  $NumberWorkers = readstring "Number of Worker Nodes" $script:config["NumWorkerVms"]
  $NumberWorkersMJS = readstring "Number of Workers on MJS Nodes" $script:config["NumWorkersOnMjsVm"]
  $NumberWorkersWorker = readstring "Number of Workers on Worker Nodes" $script:config["NumWorkersOnWorkerVms"]

  $promptstring = @"
Admin user credential for all VMs. The supplied password must be between 8-123 characters long and must satisfy at least 3 of password complexity requirements from the following:
1) Contains an uppercase character
2) Contains a lowercase character
3) Contains a numeric digit
4) Contains a special character.
"@

  $cred = Get-Credential -Message $promptstring -UserName $script:config["VmUsername"]
  $VmUsername = $cred.UserName
  $VmPassword = $cred.GetNetworkCredential().Password

  #$VmUsername = readstring "Admin Username on all VMs" $script:config["VmUsername"]

  $dnsname = readstring "Unique DNS name" $rgname

  $imageuri = readstring "The URL to the disk image in blob that will be used to create all VMs" $script:config["BaseVmVhd"]
  if(-not ($imageuri -eq $script:config["BaseVmVhd"])) {
    $script:config["BaseVmVhd"] = $imageuri
    $casteduri = [System.Uri]$imageuri
    $defaultcontainer = ("{0}://{1}/{2}/" -f $casteduri.Scheme, $casteduri.Host, $dnsname)
  } else {
    $defaultcontainer = $script:config["ClusterVmVhdContainer"]
  }
  $vhdcontainer = readstring "The URL of the container that will hold all VHDs for the VMs" $defaultcontainer

  echo "updating parameters for template deployment"
  (Get-Content $template_param) `
    -replace '\[\[dnsName\]\]', $dnsname `
    -replace '\[\[imageUri\]\]', $imageuri `
    -replace '\[\[vhdContainer\]\]', $vhdcontainer `
    -replace '\[\[scaleNumber\]\]', $NumberWorkers `
    -replace '\[\[nbOfWorkerOnMJS\]\]', $NumberWorkersMJS `
    -replace '\[\[nbOfWorker\]\]', $NumberWorkersWorker `
    -replace '\[\[vmSizeClient\]\]', $ClientVmSize `
    -replace '\[\[vmSizeMJS\]\]', $MJSVmSize `
    -replace '\[\[vmSizeWorker\]\]', $WorkerVmSize `
    -replace '\[\[adminUsername\]\]', $VmUsername `
    -replace '\[\[adminPassword\]\]', $VmPassword |
  Out-File $updated_template_param

  echo "Creating resource group"
  New-AzureRmResourceGroup -WarningAction:SilentlyContinue -Name $rgname -Location $location

  echo "Deploying to resource group. When this step is done, you will have a running MDCS cluster"
  New-AzureRmResourceGroupDeployment -WarningAction:SilentlyContinue -ResourceGroupName $rgname -TemplateFile $template -TemplateParameterFile $updated_template_param
}

function mdcs_list($p) {
  function ListDeployment($name) {
    $results = @()
    Get-AzureRmResourceGroup -WarningAction:SilentlyContinue | % {
      if(($name -ne $null) -and (-not $_.ResourceGroupName.Contains($name))) {
        #echo 'ignore'
      } else {
        $deployment = (Get-AzureRmResourceGroupDeployment -WarningAction:SilentlyContinue -ResourceGroupName $_.ResourceGroupName)
        $keys = $deployment.Parameters.Keys
        if(($keys -ne $null) -and $keys.Contains('dnsLabelPrefix') -and $keys.Contains('vmSizeMJS') -and $keys.Contains('vmSizeClient') -and $keys.Contains('vmSizeWorker') -and $keys.Contains('numWorkerVms')) {
          # now retrieve vm state
          $totalworkers = 0
          $workerstates = @{}
          $clientstate = ''
          $masterstate = ''
          Get-AzureRmVM -WarningAction:SilentlyContinue -ResourceGroupName $_.ResourceGroupName | % {
            $vm = (Get-AzureRmVM -WarningAction:SilentlyContinue -ResourceGroupName $_.ResourceGroupName -Name $_.Name -Status)
            if($vm.Name -eq 'client') {
              $clientstate = (($vm.Statuses | % {$_.displaystatus}) -join ', ')
            } elseif ($vm.Name -eq 'master') {
              $masterstate = (($vm.Statuses | % {$_.displaystatus}) -join ', ')
            } else {
              $totalworkers += 1
              $vm.Statuses | % {
                $workerstates[$_.Code] += 1
              }
            }
          }
          $vmstatus = ''
          $workerstates.Keys | % { $vmstatus += ("${_}: " + $workerstates[$_] + ' ') }
          $deployment | Add-Member -NotePropertyName Client -NotePropertyValue $clientstate
          $deployment | Add-Member -NotePropertyName Master -NotePropertyValue $masterstate
          $deployment | Add-Member -NotePropertyName Workers -NotePropertyValue $totalworkers
          $deployment | Add-Member -NotePropertyName WorkerStates -NotePropertyValue $vmstatus
          $results += $deployment
        } else {
          #echo 'skip'
        }
      }
    }
    return $results
  }
  if($p -ne $null) {
    $results = (ListDeployment $p[0])
  } else {
    $results = (ListDeployment($null))
  }
  $results | format-table @{Expression={$_.ResourceGroupName}; Label="Name"}, @{Expression={$_.Client}; Label="Client"}, @{Expression={$_.Master}; Label="Master"}, @{Expression={$_.Workers}; Label="Workers"}, @{Expression={$_.WorkerStates}; Label="Worker Status"}
}

function mdcs_pause($p) {
  if(($p -eq $null) -or ($p.length -eq 0)) {
    usage
    exit
  }
  $rg = Get-AzureRmResourceGroup -WarningAction:SilentlyContinue -ResourceGroupName $p[0]

  $scriptblock = {
    Param($profile, $rgname, $name)

    function ExecuteCmd([string]$group, [string]$name, [string]$cli) {
      $scripturi =  $script:GITHUB_BASE_URL + "scripts/mdcsutil.ps1"
      echo "Retrieving VM info..."
      $vm = (Get-AzureRmVM -WarningAction:SilentlyContinue -ResourceGroupName $group -Name $name)
      if($vm -ne $null) {
        if($vm.Extensions.Count -eq 1) {
          echo "CustomScript Extension found, deleting the existing one before adding new..."
          Remove-AzureRmVMCustomScriptExtension -ResourceGroupName $vm.ResourceGroupName -Name $vm.Extensions[0].Name -VMName $vm.Name -Force
        }
        echo "Adding CustomScript Extension to execute - $cli"
        Set-AzureRmVMCustomScriptExtension -ResourceGroupName $vm.ResourceGroupName -Name "execution" -VMName $vm.Name -FileUri $scripturi -Command $cli -Location $vm.Location
        echo "Done"
      } else {
        echo "VM $name under resource group $group not found"
      }
    }

    echo ("launch stopping job for - " + $name)
    Select-AzureRMProfile -Path $profile
    ExecuteCmd $rgname $name "mdcsutil.ps1 stop"
    Stop-AzureRmVM -ResourceGroupName $rgname -Name $name -Force
  }

  if($rg -eq $null) {
    echo "nothing found, exiting"
  } else {
    # one thing we need to do before deleting resource group - find disk images so we can delete after the arg is deleted
    $deployment = (Get-AzureRmResourceGroupDeployment -WarningAction:SilentlyContinue -ResourceGroupName $rg.ResourceGroupName)
    $vhds = @()
    if($deployment -eq $null) {
      echo "there is no deployment under the group, exiting..."
    } else {
      echo "deployment found, pausing VMs"
      $datetimestr = (Get-Date).ToString('yyyy-MM-dd-HH-mm-ss')
      $profilepath = "$env:TEMP\profile-$datetimestr.json"
      Save-AzureRmProfile -Path $profilepath

      # stop all mdcs services and VMs except master
      $jobs = @()
      Get-AzureRmVM -WarningAction:SilentlyContinue -ResourceGroupName $rg.ResourceGroupName | % {
        if($_.Name -ne "master") {
          $jobs += Start-Job -ScriptBlock $scriptblock -ArgumentList $profilepath, $rg.ResourceGroupName, $_.Name
        }
      }
      Wait-Job -Job $jobs

      echo "stopping master VM"
      # finally we stop master VM
      $mastervm = Get-AzureRmVM -WarningAction:SilentlyContinue -ResourceGroupName $rg.ResourceGroupName -Name "master"
      $masterjob = Start-Job -ScriptBlock $scriptblock -ArgumentList $profilepath, $rg.ResourceGroupName, $mastervm.Name
      Wait-Job -Job $masterjob
    }
  }
}

function mdcs_resume($p) {
  if(($p -eq $null) -or ($p.length -eq 0)) {
    usage
    exit
  }
  $rg = Get-AzureRmResourceGroup -ResourceGroupName $p[0]

  $scriptblock = {
    Param($profile, $rgname, $name)

    function ExecuteCmd([string]$group, [string]$name, [string]$cli) {
      $scripturi =  $script:GITHUB_BASE_URL + "scripts/mdcsutil.ps1"
      echo "Retrieving VM info..."
      $vm = (Get-AzureRmVM -WarningAction:SilentlyContinue -ResourceGroupName $group -Name $name)
      if($vm -ne $null) {
        if($vm.Extensions.Count -eq 1) {
          echo "CustomScript Extension found, deleting the existing one before adding new..."
          Remove-AzureRmVMCustomScriptExtension -ResourceGroupName $vm.ResourceGroupName -Name $vm.Extensions[0].Name -VMName $vm.Name -Force
        }
        echo "Adding CustomScript Extension to execute - $cli"
        Set-AzureRmVMCustomScriptExtension -ResourceGroupName $vm.ResourceGroupName -Name "execution" -VMName $vm.Name -FileUri $scripturi -Command $cli -Location $vm.Location
        echo "Done"
      } else {
        echo "VM $name under resource group $group not found"
      }
    }

    echo ("launch starting job for - " + $name)
    Select-AzureRMProfile -Path $profile
    Start-AzureRmVM -ResourceGroupName $rgname -Name $name
    ExecuteCmd $rgname $name "mdcsutil.ps1 start"
  }

  if($rg -eq $null) {
    echo "nothing found, exiting"
  } else {
    # one thing we need to do before deleting resource group - find disk images so we can delete after the arg is deleted
    $deployment = (Get-AzureRmResourceGroupDeployment -WarningAction:SilentlyContinue -ResourceGroupName $rg.ResourceGroupName)
    $vhds = @()
    if($deployment -eq $null) {
      echo "there is no deployment under the group, exiting..."
    } else {
      echo "deployment found, starting VMs"
      $datetimestr = (Get-Date).ToString('yyyy-MM-dd-HH-mm-ss')
      $profilepath = "$env:TEMP\profile-$datetimestr.json"
      Save-AzureRmProfile -Path $profilepath

      echo "starting master VM"
      # finally we stop master VM
      $mastervm = Get-AzureRmVM -WarningAction:SilentlyContinue -ResourceGroupName $rg.ResourceGroupName -Name "master"
      $masterjob = Start-Job -ScriptBlock $scriptblock -ArgumentList $profilepath, $rg.ResourceGroupName, $mastervm.Name
      Wait-Job -Job $masterjob

      echo "starting workers and client"
      $jobs = @()
      Get-AzureRmVM -WarningAction:SilentlyContinue -ResourceGroupName $rg.ResourceGroupName | % {
        if($_.Name -ne "master") { # skipping master
          $jobs += Start-Job -ScriptBlock $scriptblock -ArgumentList  $profilepath, $rg.ResourceGroupName, $_.Name
        }
      }
      Wait-Job -Job $jobs
    }
  }
}

function mdcs_delete($p) {
  if(($p -eq $null) -or ($p.length -eq 0)) {
    usage
    exit
  }
  $rg = Get-AzureRmResourceGroup -WarningAction:SilentlyContinue -ResourceGroupName $p[0]

  if($rg -eq $null) {
    echo "nothing found, exiting"
  } else {
    # one thing we need to do before deleting resource group - find disk images so we can delete after the arg is deleted
    $deployment = (Get-AzureRmResourceGroupDeployment -WarningAction:SilentlyContinue -ResourceGroupName $rg.ResourceGroupName)
    $vhds = @()
    if($deployment -eq $null) {
      echo "there is no deployment under the group, deleting the group directly"
    } else {
      echo "deployment found, finding VHDs... this may take a while"
      Get-AzureRmVM -ResourceGroupName $rg.ResourceGroupName | % {
        $vhds += $_.StorageProfile.OsDisk.Vhd.Uri
      }
    }

    # now delete the arg
    echo "deleting resource group..."
    Remove-AzureRmResourceGroup -ResourceGroupName $rg.ResourceGroupName -Force

    # now wait until it's deleted
    while($null -ne (Get-AzureRmResourceGroup -WarningAction:SilentlyContinue -ResourceGroupName $rg.ResourceGroupName)) {
      echo "pause 5 seconds and check again if the resource group has disappeared..."
      Start-Sleep 5
      #break
    }

    # now it's time to delete the VHDs
    if($vhds.Count -gt 0) {
      echo "now deleting vhds..."
      # finding storage accounts from the url
      $storageaccountname = ([System.Uri]$vhds[0]).Authority.Split('.')[0]
      # getting storage context for deleting
      $storageaccount = (Get-AzureRmStorageAccount | ? {$_.StorageAccountName -eq $storageaccountname})
      $storagekey = Get-AzureRmStorageAccountKey -ResourceGroupName $storageaccount.ResourceGroupName -Name $storageaccount.StorageAccountName
      $storagecontext = New-AzureStorageContext -StorageAccountName $storageaccount.StorageAccountName -StorageAccountKey $storagekey[0].Value

      $vhds | % {
        $vhd = $_
        # $blobname = $vhd parsed results
        # $containername = $vhd parsed results
        $segs = ([System.Uri]$vhd).AbsolutePath.Split('/')
        $containername = $segs[1]
        $blobname = [string]::Join('/', $segs[2..($segs.length-1)])
        echo "$vhd"
        echo "deleting $blobname of $containername on account $storageaccountname"
        Remove-AzureStorageBlob -Blob $blobname -Container $containername -Context $storagecontext -Force
      }
    }
  }
}

function usage($p) {
  Write-Output @"

Error - Unknown syntax.

Supported commands are,

 $PSCommandPath create [ini config file path]
 $PSCommandPath list
 $PSCommandPath pause <cluster name>
 $PSCommandPath resume <cluster name>
 $PSCommandPath delete <cluster name>

Please refer to readme.md for detail help.

"@
}

function parse_param($p) {
  if($p.Count -eq 0) {
    usage
    exit
  }
  $command = $p[0]
  if($p.length -gt 1) {
    $command_args = $p[1..($p.length-1)]
  }
  switch ($p[0]) {
    "create" { mdcs_create($command_args); break }
    "list" { mdcs_list($command_args); break }
    "pause" { mdcs_pause($command_args); break }
    "resume" { mdcs_resume($command_args); break }
    "delete" { mdcs_delete($command_args); break }
    default { usage; exit}
  }
}

# parse_param will parse the parameter and drive the workflow
parse_param($args)
