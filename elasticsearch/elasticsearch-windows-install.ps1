<#
	.SYNOPSIS
		Installs elastic search on the given nodes.
	.DESCRIPTION
		This script runs as a VM extension and installs elastic search on the cluster nodes.
	.PARAMETER SomeParam
		Description of the parameter.
	.EXAMPLE
		SetupElasticVm.ps1 -elasticVersion '1.7.2' -elasticClusterName 'poltergeist'
	.LINK
		<<demo url>>
#>
Param(
    [Parameter(Mandatory=$true)][string]$elasticSearchVersion,
    [string]$jdkDownloadLocation,
	[string]$elasticSearchBaseFolder,
	[string]$elasticClusterName,
	[switch]$masterOnlyNode,
	[switch]$clientOnlyNode,
	[switch]$dataOnlyNode
)

# To set the env vars permanently, need to use registry location
Set-Variable regEnvPath -Option Constant -Value 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment'

function Log-Output(){
	$args | Write-Host -ForegroundColor Green
}

function Log-Error(){
	$args | Write-Host -ForegroundColor Red
}

Set-Alias -Name lmsg -Value Log-Output -Description "Displays an informational message in green color" 
Set-Alias -Name lerr -Value Log-Error -Description "Displays an error message in red color" 

function Initialize-Disks{
	
    # Get raw disks
    $disks = Get-Disk | Where partitionstyle -eq 'raw' | sort number
    
    # Get letters starting from F
    $label = 'datadisk-'
    $letters = 70..89 | ForEach-Object { ([char]$_) }
    $letterIndex = 0
	if($disks -ne $null)
	{
        lmsg 'Found attached VHDs with raw partition...' $disks
        try{
            foreach($disk in $disks){
                $driveLetter = $letters[$letterIndex].ToString()
                lmsg 'Formatting disk...' $driveLetter
		        $disk | Initialize-Disk -PartitionStyle MBR -PassThru |	New-Partition -UseMaximumSize -DriveLetter $driveLetter | Format-Volume -FileSystem NTFS -NewFileSystemLabel "$label$letterIndex" -Confirm:$false -Force
                $letterIndex++
            }
        }catch [System.Exception]{
			lerr $_.Exception.Message
            lerr $_.Exception.StackTrace
			Break
		}
	}
    
    #return $letters[0].ToString()
}

function Download-Jdk($targetDrive, $downloadLocation){
	# download JDK from a given source URL to destination folder
	try{
			$destination = if ($targetDrive -eq $null) {"$env:HOMEDRIVE\Downloads\Java\jdk-8u65-windows-x64.exe"} else {"$targetDrive`:\Downloads\Java\jdk-8u65-windows-x64.exe"}
			$source = if ($downloadLocation -eq $null) {"http://download.oracle.com/otn-pub/java/jdk/8u65-b17/jdk-8u65-windows-x64.exe"} else {$downloadLocation}
            
            # create folder if doesn't exists and suppress the output
            $folder = split-path $destination
            if (!(Test-Path $folder)) {
                New-Item -Path $folder -ItemType Directory | Out-Null
            }

			$client = new-object System.Net.WebClient 
			$cookie = "oraclelicense=accept-securebackup-cookie"

            lmsg 'Downloading JDK from ' $source ' to ' $destination

			$client.Headers.Add([System.Net.HttpRequestHeader]::Cookie, $cookie) 
			$client.downloadFile($source, $destination)
		}catch [System.Net.WebException],[System.Exception]{
			lerr $_.Exception.Message
            lerr $_.Exception.StackTrace
			Break
		}

	return $destination
}

function Install-Jdk($sourceLoc, $targetDrive)
{
	$installPath = if($targetDrive -eq $null) {"$env:HOMEDRIVE\Program Files\Java\Jdk"} else {"$targetDrive`:\Program Files\Java\Jdk"}
    $logPath = Join-Path $env:HOMEDRIVE -ChildPath "$env:HOMEPATH\java_install_log.txt"
    $psLog = Join-Path $env:HOMEDRIVE -ChildPath "$env:HOMEPATH\java_install_ps_log.txt"
    $psErr = Join-Path $env:HOMEDRIVE -ChildPath "$env:HOMEPATH\java_install_ps_err.txt"

	try{
        lmsg "Installing java on the box under $installPath..."
		$proc = Start-Process -FilePath $sourceLoc -ArgumentList "/s INSTALLDIR=`"$installPath`" /L `"$logPath`"" -Wait -PassThru -RedirectStandardOutput $psLog -RedirectStandardError $psErr -NoNewWindow
        $proc.WaitForExit()
        lmsg "JDK installed under $installPath" "Log file: $logPath"
        
        #if($proc.ExitCode -ne 0){
            #THROW "JDK installation error"
        #}
		
    }catch [System.Exception]{
		lerr $_.Exception.Message
        lerr $_.Exception.StackTrace
	    Break
	}
	
	return $installPath
}

function Download-ElasticSearch($elasticVersion, $targetDrive){
	# download ElasticSearch from a given source URL to destination folder
	try{
			$source = if ($elasticVersion -eq $null) {"https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-1.7.2.zip"} else {"https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-$elasticVersion.zip"}
			$destination = if ($targetDrive -eq $null) {"$env:HOMEDRIVE\Downloads\ElasticSearch\Elastic-Search.zip"} else {"$targetDrive`:\Downloads\ElasticSearch\Elastic-Search.zip"}
            
            # create folder if doesn't exists and suppress the output
            $folder = split-path $destination
            if (!(Test-Path $folder)) {
                New-Item -Path $folder -ItemType Directory | Out-Null
            }

			$client = new-object System.Net.WebClient 

            lmsg 'Downloading Elasticsearch from ' $source ' to ' $destination

			$client.downloadFile($source, $destination)
		}catch [System.Net.WebException],[System.Exception]{
			lerr $_.Exception.Message
            lerr $_.Exception.StackTrace
			Break
		}

	return $destination
}

function Unzip-Archive($archive, $destination){
	
	$shell = new-object -com shell.application

	$zip = $shell.NameSpace($archive)
	
	# Test destination folder
	if (!(Test-Path $destination))
	{
        lmsg "Creating $destination folder"
		New-Item -Path $destination -ItemType Directory | Out-Null
    }

	$destination = $shell.NameSpace($destination)

    #TODO a progress dialog pops up though not sure of its effect on the deployment
	$destination.CopyHere($zip.Items())
}

function SetEnv-JavaHome($jdkInstallLocation)
{
    $homePath = $jdkInstallLocation
    #Join-Path $jdkInstallLocation -ChildPath 'jre1.8.0_65'
    lmsg "Setting JAVA_HOME in the registry to $homePath..."
	Set-ItemProperty -Path $regEnvPath -Name JAVA_HOME -Value $homePath
    lmsg 'Setting JAVA_HOME for the current session...'
    Set-Item Env:JAVA_HOME "$homePath"
}

function Install-ElasticSearch ($driveLetter, $elasticSearchZip, $subFolder = $elasticSearchBaseFolder)
{
	
	# Designate unzip location 
	$elasticSearchPath =  Join-Path "$driveLetter`:" -ChildPath $subFolder
	
	# Unzip
	Unzip-Archive $elasticSearchZip $elasticSearchPath

	return $elasticSearchPath
}

function ElasticSearch-InstallService($scriptPath)
{
	# Install and start elastic search as a service
	$elasticService = (get-service | Where-Object {$_.Name -match "elasticsearch"}).Name
	if($elasticService -eq $null) 
    {	
        #$proc = start-process cmd -argumentlist "/c $scriptpath install" -passthru -nonewwindow -wait
        #if($proc -ne 0){
         #   lerr "exception encountered while installing elasticsearch service"
         #   break
        #}
        lmsg 'Installing elasticsearch as a service...'
        cmd.exe /C "$scriptPath install"
        if ($LASTEXITCODE) {
            throw "Command '$scriptPath': exit code: $LASTEXITCODE"
        }
    }
}


function ElasticSearch-StartService()
{
    # Check if the service is installed and start it
    $elasticService = (get-service | Where-Object {$_.Name -match "elasticsearch"}).Name
    if($elasticService -ne $null)
    {
        lmsg 'Starting elasticsearch service and setting the startup to automatic...'
        Start-Service $elasticService
		Set-Service $elasticService -StartupType Automatic
        
        # Give approximately 20 seconds for service to start before verification
        Start-Sleep -Seconds 20
    }
}

function ElasticSearch-VerifyInstall()
{
    $esRequest = [System.Net.WebRequest]::Create("http://localhost:9200")
    $esRequest.Method = "GET"
	$esResponse = $esRequest.GetResponse()
	$reader = new-object System.IO.StreamReader($esResponse.GetResponseStream())
	lmsg 'ElasticSearch service response status: ' $esResponse.StatusCode
	lmsg 'ElasticSearch service response full text: ' $reader.ReadToEnd()
}

function Install-WorkFlow
{
	# Initialize installation drive
	
    # Below script should discover raw data disks and format them
    Initialize-Disks

	# Set first drive
    $firstDrive = (get-location).Drive.Name
    
    # Download Jdk
	$jdkSource = Download-Jdk
	
	# Install Jdk
	$jdkInstallLocation = Install-Jdk $jdkSource $firstDrive

	# Download elastic search zip
	$elasticSearchZip = Download-ElasticSearch $elasticSearchVersion
	
	# Unzip (install) elastic search
	if($elasticSearchBaseFolder.Length -eq 0) { $elasticSearchBaseFolder = 'elasticSearch'}
	$elasticSearchInstallLocation = Install-ElasticSearch $firstDrive $elasticSearchZip

	# Set JAVA_HOME
    SetEnv-JavaHome $jdkInstallLocation
	
	# Configure cluster name and properties
		
		# Cluster name
		if($elasticClusterName.Length -eq 0) 	{ $elasticClusterName = 'elasticsearch_cluster'}
		
		# Extract install folders
		$elasticSearchBinParent = (gci -path $elasticSearchInstallLocation -filter "bin" -Recurse).Parent.FullName
		$elasticSearchBin = Join-Path $elasticSearchBinParent -ChildPath "bin"
		$elasticSearchConfFile = Join-Path $elasticSearchBinParent -ChildPath "config\elasticsearch.yml"
		
		# Set values
            # Cluster name
		    (gc $elasticSearchConfFile) | ForEach-Object { $_ -replace "#?\s?cluster.name: .+" , "cluster.name: $elasticClusterName" } | sc $elasticSearchConfFile
        
            # Master node, data node or client node
            if($masterOnlyNode) 
            {
                (gc $elasticSearchConfFile) | ForEach-Object { $_ -replace "#?\s?node.master: .+" , "node.master: true" } | sc $elasticSearchConfFile
                (gc $elasticSearchConfFile) | ForEach-Object { $_ -replace "#?\s?node.data: .+" , "node.data: false" } | sc $elasticSearchConfFile
            }
            elseif($dataOnlyNode)
            {
                (gc $elasticSearchConfFile) | ForEach-Object { $_ -replace "#?\s?node.master: .+" , "node.master: false" } | sc $elasticSearchConfFile
                (gc $elasticSearchConfFile) | ForEach-Object { $_ -replace "#?\s?node.data: .+" , "node.data: true" } | sc $elasticSearchConfFile
            }
            elseif($clientOnlyNode)
            {
                (gc $elasticSearchConfFile) | ForEach-Object { $_ -replace "#?\s?node.master: .+" , "node.master: false" } | sc $elasticSearchConfFile
                (gc $elasticSearchConfFile) | ForEach-Object { $_ -replace "#?\s?node.data: .+" , "node.data: false" } | sc $elasticSearchConfFile
            }
            else
            {
                (gc $elasticSearchConfFile) | ForEach-Object { $_ -replace "#?\s?node.master: .+" , "node.master: true" } | sc $elasticSearchConfFile
                (gc $elasticSearchConfFile) | ForEach-Object { $_ -replace "#?\s?node.data: .+" , "node.data: true" } | sc $elasticSearchConfFile
            }
	
	# Install service using the batch file in bin folder
    $scriptPath = Join-Path $elasticSearchBin -ChildPath "service.bat"
    ElasticSearch-InstallService $scriptPath

    # Start service
    ElasticSearch-StartService

    # Verify service
    ElasticSearch-VerifyInstall
}

Install-WorkFlow