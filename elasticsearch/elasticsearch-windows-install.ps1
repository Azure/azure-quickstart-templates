# The MIT License (MIT)
#
# Copyright (c) 2015 Microsoft Azure
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# Kirpa Singh (MSFT)
#

<#
	.SYNOPSIS
		Installs elastic search on the given nodes.
	.DESCRIPTION
		This script runs as a VM extension and installs elastic search on the cluster nodes. It can be used to setup either a single VM (when run as VM extension) or a cluster (when run from within an ARM template)
	.PARAMETER elasticSearchVersion
		Version of elasticsearch to install e.g. 1.7.3
    .PARAMETER jdkDownloadLocation
        Url of the JDK installer e.g. http://download.oracle.com/otn-pub/java/jdk/8u65-b17/jdk-8u65-windows-x64.exe
    .PARAMETER elasticSearchBaseFolder
        Disk location of the base folder of elasticsearch installation.
    .PARAMETER discoveryEndpoints
        Formatted string of the allowed subnet addresses for unicast internode communication e.g. 10.0.0.4-3 is expanded to [10.0.0.4,10.0.0.5,10.0.0.6]
    .PARAMETER elasticClusterName
        Name of the elasticsearch cluster
    .PARAMETER masterOnlyNode
        Setup a VM as master only node
    .PARAMETER clientOnlyNode
        Setup a VM as client only node
    .PARAMETER dataOnlyNode
        Setup a VM as data only node
	.EXAMPLE
		elasticSearchVersion 1.7.2 -elasticClusterName evilescluster -discoveryEndpoints 10.0.0.4-5 -masterOnlyNode
        Installs 1.7.2 version of elasticsearch with cluster name evilescluster and 5 allowed subnet addresses from 4 to 8. Sets up the VM as master node.
    .EXAMPLE
        elasticSearchVersion 1.7.3 -elasticSearchBaseFolder software -elasticClusterName evilescluster -discoveryEndpoints 10.0.0.3-4 -dataOnlyNode
        Installs 1.7.3 version of elasticsearch with cluster name evilescluster and 4 allowed subnet addresses from 3 to 6. Sets up the VM as data node.
#>
Param(
    [Parameter(Mandatory=$true)][string]$elasticSearchVersion,
    [string]$jdkDownloadLocation,
	[string]$elasticSearchBaseFolder,
    [string]$discoveryEndpoints,
	[string]$elasticClusterName,
	[switch]$masterOnlyNode,
	[switch]$clientOnlyNode,
	[switch]$dataOnlyNode,
	[switch]$installMarvel,
	[switch]$jmeterConfig
)

# To set the env vars permanently, need to use registry location
Set-Variable regEnvPath -Option Constant -Value 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment'

function Log-Output(){
	$args | Write-Host -ForegroundColor Cyan
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

function Download-Jdk
{
    param(
        [Parameter(Mandatory=$true)]
        [string]$targetDrive,
        [string]$downloadLocation
    )
	# download JDK from a given source URL to destination folder
	try{
			$destination = "$targetDrive`:\Downloads\Java\jdk-8u65-windows-x64.exe"
			$source = if ($downloadLocation -eq '') {'http://download.oracle.com/otn-pub/java/jdk/8u65-b17/jdk-8u65-windows-x64.exe'} else {$downloadLocation}
            
            # create folder if doesn't exists and suppress the output
            $folder = split-path $destination
            if (!(Test-Path $folder)) {
                New-Item -Path $folder -ItemType Directory | Out-Null
            }

			$client = new-object System.Net.WebClient 
			$cookie = "oraclelicense=accept-securebackup-cookie"

            lmsg "Downloading JDK from $source to $destination"

			$client.Headers.Add([System.Net.HttpRequestHeader]::Cookie, $cookie) 
			$client.downloadFile($source, $destination)
		}catch [System.Net.WebException],[System.Exception]{
			lerr $_.Exception.Message
            lerr $_.Exception.StackTrace
			Break
		}

	return $destination
}

function Install-Jdk
{
    param(
        [Parameter(Mandatory=$true)]
        [string]$sourceLoc,
        [Parameter(Mandatory=$true)]
        [string]$targetDrive
    )

	$installPath = "$targetDrive`:\Program Files\Java\Jdk"

    $homefolderPath = (Get-Location).Path
    $logPath = "$homefolderPath\java_install_log.txt"
    $psLog = "$homefolderPath\java_install_ps_log.txt"
    $psErr = "$homefolderPath\java_install_ps_err.txt"

	try{
        lmsg "Installing java on the box under $installPath..."
		$proc = Start-Process -FilePath $sourceLoc -ArgumentList "/s INSTALLDIR=`"$installPath`" /L `"$logPath`"" -Wait -PassThru -RedirectStandardOutput $psLog -RedirectStandardError $psErr -NoNewWindow
        $proc.WaitForExit()
        lmsg "JDK installed under $installPath" "Log file location: $logPath"
        
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

function Download-ElasticSearch
{
    param(
        [Parameter(Mandatory=$true)]
        [string]$elasticVersion,
        [Parameter(Mandatory=$true)]
        [string]$targetDrive
    )
	# download ElasticSearch from a given source URL to destination folder
	try{
			$source = if ($elasticVersion -match '2.0.0') {"https://download.elasticsearch.org/elasticsearch/release/org/elasticsearch/distribution/zip/elasticsearch/$elasticVersion/elasticsearch-$elasticVersion.zip"} else { "https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-$elasticVersion.zip" }
			$destination = "$targetDrive`:\Downloads\ElasticSearch\Elastic-Search.zip"
            
            # create folder if doesn't exists and suppress the output
            $folder = split-path $destination
            if (!(Test-Path $folder)) {
                New-Item -Path $folder -ItemType Directory | Out-Null
            }

			$client = new-object System.Net.WebClient 

            lmsg "Downloading Elasticsearch version $elasticVersion from $source to $destination"

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
    
    lmsg "Setting JAVA_HOME in the registry to $homePath..."
	Set-ItemProperty -Path $regEnvPath -Name JAVA_HOME -Value $homePath
    
    lmsg 'Setting JAVA_HOME for the current session...'
    Set-Item Env:JAVA_HOME "$homePath"

    # Additional check
    if ([environment]::GetEnvironmentVariable("JAVA_HOME","machine") -eq $null)
	{
	    [environment]::setenvironmentvariable("JAVA_HOME",$homePath,"machine")
	}

    lmsg 'Modifying path variable to point to java executable...'
    $currentPath = (Get-ItemProperty -Path $regEnvPath -Name PATH).Path
    $currentPath = $currentPath + ';' + "$homePath\bin"
    Set-ItemProperty -Path $regEnvPath -Name PATH -Value $currentPath
    Set-Item Env:PATH "$currentPath"
}

function Install-ElasticSearch ($driveLetter, $elasticSearchZip, $subFolder = $elasticSearchBaseFolder)
{
	
	# Designate unzip location 
	$elasticSearchPath =  Join-Path "$driveLetter`:" -ChildPath $subFolder
	
	# Unzip
	Unzip-Archive $elasticSearchZip $elasticSearchPath

	return $elasticSearchPath
}

function Implode-Host($discoveryHost)
{
    # Discovery host must be in a given format e.g. 10.0.0.4-3 for the below code to work
    $ipPrefix = $discoveryHost.Substring(0, $discoveryHost.LastIndexOf('.'))
    $lastDigit = $discoveryHost.Substring($discoveryHost.LastIndexOf('.') + 1, 1)
    $loop = $discoveryHost.Substring($discoveryHost.LastIndexOf('-') + 1, 1)

    $ipRange = @(0) * $loop
    for($i=0; $i -lt $loop; $i++)
    {
        $ipRange[$i] = "$ipPrefix." + ($i+ $lastDigit)
    }

    $addresses = $ipRange -join ','
    return $addresses
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
        $svc = Start-Service $elasticService
        $svc.WaitForStatus('Started', '00:00:30')
		Set-Service $elasticService -StartupType Automatic
        
        # Give approximately 20 seconds for service to start before verification
        #Start-Sleep -Seconds 20
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

function Jmeter-Download
{
	try{
			$drive = (get-location).Drive.Name
			$destination = "$drive`:\Downloads\Jmeter\Jmeter_server_agent.zip"
			$source = 'http://jmeter-plugins.org/downloads/file/ServerAgent-2.2.1.zip'
            
            # create folder if doesn't exists and suppress the output
            $folder = split-path $destination
            if (!(Test-Path $folder)) {
                New-Item -Path $folder -ItemType Directory | Out-Null
            }

			$client = new-object System.Net.WebClient 

            lmsg "Downloading Jmeter SA from $source to $destination"

			$client.downloadFile($source, $destination)
		}catch [System.Net.WebException],[System.Exception]{
			lerr $_.Exception.Message
            lerr $_.Exception.StackTrace
			Break
		}
    
    return $destination
}

function Jmeter-Unzip($source)
{
    # Unzip now
    $shell = new-object -com shell.application

	$zip = $shell.NameSpace($source)

	$drive = (get-location).Drive.Name
    $loc = "$drive`:\jmeter_sa"
	
	# Test destination folder
	if (!(Test-Path $loc))
	{
        lmsg "Creating $loc folder"
		New-Item -Path $loc -ItemType Directory | Out-Null
    }

	$loc = $shell.NameSpace($loc)

    #TODO a progress dialog pops up though not sure of its effect on the deployment
	$loc.CopyHere($zip.Items())

    return $loc
}

function Jmeter-ConfigFirewall
{
    lmsg 'Adding firewall rule - Allow Jmeter Inbound Port 4444'
    New-NetFirewallRule -Name 'Jmeter_ServerAgent_IN' -DisplayName 'Allow Jmeter Inbound Port 4444' -Protocol tcp -LocalPort 4444 -Action Allow -Enabled True -Direction Inbound
    
    lmsg 'Adding firewall rule - Allow Jmeter Outbound Port 4444'
    New-NetFirewallRule -Name 'Jmeter_ServerAgent_OUT' -DisplayName 'Allow Jmeter Outbound Port 4444' -Protocol tcp -LocalPort 4444 -Action Allow -Enabled True -Direction Outbound

}

function Jmeter-Run($target)
{
	    cmd.exe /K "$target\startAgent.bat"
        if ($LASTEXITCODE) {
            throw "Command '$scriptPath': exit code: $LASTEXITCODE"
        }
}

function Install-WorkFlow
{
	# Initialize installation drive
	
    # Below script should discover raw data disks and format them
    Initialize-Disks

	# Set first drive
    $firstDrive = (get-location).Drive.Name
    
    # Download Jdk
	$jdkSource = Download-Jdk $firstDrive
	
	# Install Jdk
	$jdkInstallLocation = Install-Jdk $jdkSource $firstDrive

	# Download elastic search zip
	$elasticSearchZip = Download-ElasticSearch $elasticSearchVersion $firstDrive
	
	# Unzip (install) elastic search
	if($elasticSearchBaseFolder.Length -eq 0) { $elasticSearchBaseFolder = 'elasticSearch'}
	$elasticSearchInstallLocation = Install-ElasticSearch $firstDrive $elasticSearchZip

	# Set JAVA_HOME
    SetEnv-JavaHome $jdkInstallLocation
	
	# Configure cluster name and other properties
		
		# Cluster name
		if($elasticClusterName.Length -eq 0) 	{ $elasticClusterName = 'elasticsearch_cluster'}
        
        # Unicast host setup
        $ipAddresses = Implode-Host $discoveryEndpoints
		
		# Extract install folders
		$elasticSearchBinParent = (gci -path $elasticSearchInstallLocation -filter "bin" -Recurse).Parent.FullName
		$elasticSearchBin = Join-Path $elasticSearchBinParent -ChildPath "bin"
		$elasticSearchConfFile = Join-Path $elasticSearchBinParent -ChildPath "config\elasticsearch.yml"
		
		# Set values
        lmsg "Configure cluster name to $elasticClusterName"
        $textToAppend = "`n#### Settings automatically added by deployment script`ncluster.name: $elasticClusterName"
        if($masterOnlyNode)
        {
            lmsg 'Configure node as master only'
            $textToAppend = $textToAppend + "`nnode.master: true`nnode.data: false"
        }
        elseif($dataOnlyNode)
        {
            lmsg 'Configure node as data only'
            $textToAppend = $textToAppend + "`nnode.master: false`nnode.data: true"
        }
        elseif($clientOnlyNode)
        {
            lmsg 'Configure node as client only'
            $textToAppend = $textToAppend + "`nnode.master: false`nnode.data: false"
        }
        else
        {
            lmsg 'Configure node as master and data'
            $textToAppend = $textToAppend + "`nnode.master: true`nnode.data: true"
        }

		$textToAppend = $textToAppend + "`ndiscovery.zen.minimum_master_nodes: 2"
        $textToAppend = $textToAppend + "`ndiscovery.zen.ping.multicast.enabled: false"
        $textToAppend = $textToAppend + "`ndiscovery.zen.ping.unicast.hosts: [$ipAddresses]"

        # In ES 2.0 you explicitly need to set network host to _non_loopback_ or the IP address of the host else other nodes cannot communicate
        if ($elasticSearchVersion -match '2.0.0')
        {
            $textToAppend = $textToAppend + "`nnetwork.host: _non_loopback_"
        }


        Add-Content $elasticSearchConfFile $textToAppend
		

	# Add firewall rules
    lmsg 'Adding firewall rule - Allow Elasticsearch Inbound Port 9200'
    New-NetFirewallRule -Name 'ElasticSearch_In_Lb' -DisplayName 'Allow Elasticsearch Inbound Port 9200' -Protocol tcp -LocalPort 9200 -Action Allow -Enabled True -Direction Inbound

    lmsg 'Adding firewall rule - Allow Elasticsearch Inter Node Communication Inbound Port 9300'
    New-NetFirewallRule -Name 'ElasticSearch_In_Unicast' -DisplayName 'Allow Elasticsearch Inter Node Communication Inbound Port 9300' -Protocol tcp -LocalPort 9300 -Action Allow -Enabled True -Direction Inbound
    
    lmsg 'Adding firewall rule - Allow Elasticsearch Inter Node Communication Outbound Port 9300'
    New-NetFirewallRule -Name 'ElasticSearch_Out_Unicast' -DisplayName 'Allow Elasticsearch Inter Node Communication Outbound Port 9300' -Protocol tcp -LocalPort 9300 -Action Allow -Enabled True -Direction Outbound


    # Install service using the batch file in bin folder
    $scriptPath = Join-Path $elasticSearchBin -ChildPath "service.bat"
    ElasticSearch-InstallService $scriptPath

    # Start service
    ElasticSearch-StartService

    # Install marvel if specified
    if ($installMarvel)
    {
        if ($elasticSearchVersion -match '2.0.0')
        {
            cmd.exe /C "$elasticSearchBin\plugin.bat install license"
            cmd.exe /C "$elasticSearchBin\plugin.bat install marvel-agent"
        }
        else
        {
            cmd.exe /C "$elasticSearchBin\plugin.bat -i elasticsearch/marvel/latest"
        }
    }		
		
	# Temporary measure to configure each ES node for JMeter server agent
	if ($jmeterConfig)
	{
		$jmZip = Jmeter-Download
		$unzipLocation = Jmeter-Unzip $jmZip
		Jmeter-ConfigFirewall
		Jmeter-Run $unzipLocation
	}


    # Verify service TODO: Investigate why verification fails during ARM deployment
    ElasticSearch-VerifyInstall
}

Install-WorkFlow