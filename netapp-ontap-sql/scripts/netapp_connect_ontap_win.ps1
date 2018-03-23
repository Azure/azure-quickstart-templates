[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [String]$email,
    [Parameter(Mandatory=$true)]
    [String]$password,
    [Parameter(Mandatory=$true)]
    [String]$OTCpassword,
    [Parameter(Mandatory=$true)]
    [String]$ocmip,
    [Parameter(Mandatory=$true)]
    [decimal]$Capacity
) 

function Get-ONTAPClusterDetails([String]$email, [String]$password, [String]$ocmip)
{

$authbody = @{
    email = "${email}"
    password = "${password}"
}
$authbodyjson = $authbody | ConvertTo-Json

## Listing all URI used for API Calls 
$uriauth = "http://$ocmip/occm/api/auth/login"
$urigetpublicid = "http://$ocmip/occm/api/azure/vsa/working-environments"
$urigetproperties = "http://$ocmip/occm/api/azure/vsa/working-environments/${publicid?fields}?fields=ontapClusterProperties"
$headers = @{"Referer"= "AzureQS1"}

## Authenticating with Cloud Manager
Invoke-RestMethod -Method Post -Headers $headers -UseBasicParsing -Uri ${uriauth} -ContentType 'application/json' -Body $authbodyjson  -SessionVariable session

## Getting public id of NetApp ONTAP Cloud
$publicidjson = Invoke-WebRequest -Method Get -UseBasicParsing -Uri ${urigetpublicid} -ContentType 'application/json' -WebSession $session | ConvertFrom-Json
$publicid = $publicidjson.publicId

## Exporting Cluster Properties to C:\WindowsAzure\logs\netappotc.json
Invoke-WebRequest -Method Get -UseBasicParsing -Uri ${urigetproperties} -ContentType 'application/json' -WebSession $session -OutFile C:\WindowsAzure\logs\netappotc.json

## Getting Cluster Properties in Variable
$ontapclusterproperties = Invoke-WebRequest -Method Get -UseBasicParsing -Uri ${urigetproperties} -ContentType 'application/json' -WebSession $session | convertfrom-json 
 
## Extracting IP Address for AdminLif, iSCSILIF and SCVMName
$Global:AdminLIF = $ontapclusterproperties.ontapclusterproperties.nodes.lifs.ip | Select-Object -index 0
$Global:iScSILIF = $ontapclusterproperties.ontapclusterproperties.nodes.lifs.ip | Select-Object -index 3
$Global:SVMName = $ontapclusterproperties.svmname

## Echo all values
echo "Admin Lif IP is $AdminLIF"
echo "iSCSI Lif IP is $iScSILIF"
echo "svm Name is is $SVMName"

## Ip fetching complete, starting connect function

}

function Connect-ONTAP([String]$AdminLIF, [String]$iScSILIF, [String]$SVMName,[String]$SVMPwd, [decimal]$Capacity)
{
    $ErrorActionPreference = 'Stop'

    try {
    
        Start-Transcript -Path C:\WindowsAzure\Logs\SQLNetApp_Connect_Storage.ps1.txt -Append
    
        Write-Output "Started @ $(Get-Date)"
        Write-Output "Admin Lif: $AdminLIF"
        Write-Output "iScSI Lif: $iScSiLIF"
        Write-Output "SVM Name : $SVMName"
        Write-Output "SVM Password: $SVMPwd"
        Write-Output "Capacity: $Capacity"

        $AdminLIF= $AdminLIF.Substring($AdminLIF.IndexOf(':')+1)
        $iScSiLIF= $iScSiLIF.Substring($iScSiLIF.IndexOf(':')+1)
        $SVMName = $SVMName.Trim().Replace("-","_")

        Setup-VM

        $IqnName = "azureqsiqn"
        $SecPasswd = ConvertTo-SecureString $SVMPwd -AsPlainText -Force
        $SvmCreds = New-Object System.Management.Automation.PSCredential ("admin", $SecPasswd)
        $VMIqn = (get-initiatorPort).nodeaddress
        #Pad the data Volume size by 10 percent
        $DataVolSize = [System.Math]::Floor($Capacity * 1.1)
        #Log Volume will be one third of data with 10 percent padding
        $LogVolSize = [System.Math]::Floor($Capacity *.37 ) 

		$DataLunSize = $Capacity
		$LogLunSize =  $Capacity *.33
        
        Import-module 'C:\Program Files (x86)\NetApp\NetApp PowerShell Toolkit\Modules\DataONTAP\DataONTAP.psd1'
        
        Connect-NcController $AdminLIF -Credential $SvmCreds -Vserver $SVMName
        Create-NcGroup $IqnName $VMIqn $SVMName
        New-IscsiTargetPortal -TargetPortalAddress $iScSiLIF
        Connect-Iscsitarget -NodeAddress (Get-IscsiTarget).NodeAddress -IsMultipathEnabled $True -TargetPortalAddress $iScSiLIF
    
        Get-IscsiSession | Register-IscsiSession

        New-Ncvol -name sql_data_root -Aggregate aggr1 -JunctionPath $null -size ([string]($DataVolSize)+"g") -SpaceReserve none
        New-Ncvol -name sql_log_root -Aggregate aggr1 -JunctionPath $null -size ([string]($LogVolSize)+"g") -SpaceReserve none

        New-Nclun /vol/sql_data_root/sql_data_lun ([string]$DataLunSize+"gb") -ThinProvisioningSupportEnabled -OsType "windows_2008"
        New-Nclun /vol/sql_log_root/sql_log_lun ([string]$LogLunSize+"gb") -ThinProvisioningSupportEnabled -OsType "windows_2008" 

        Add-Nclunmap /vol/sql_data_root/sql_data_lun $IqnName
        Add-Nclunmap /vol/sql_log_root/sql_log_lun $IqnName

        
        Start-NcHostDiskRescan
        Wait-NcHostDisk -ControllerLunPath /vol/sql_data_root/sql_data_lun -ControllerName $SVMName
        Wait-NcHostDisk -ControllerLunPath /vol/sql_log_root/sql_log_lun -ControllerName $SVMName


        $DataDisk = (Get-Nchostdisk | Where-Object {$_.ControllerPath -like "*sql_data_lun*"}).Disk
        $LogDisk = (Get-Nchostdisk | Where-Object {$_.ControllerPath -like "*sql_log_lun*"}).Disk

        Stop-Service -Name ShellHWDetection
        Set-Disk -Number $DataDisk -IsOffline $False
        Initialize-Disk -Number $DataDisk
        New-Partition -DiskNumber $DataDisk -UseMaximumSize -AssignDriveLetter  | ForEach-Object { Start-Sleep -s 5; $_| Format-Volume -NewFileSystemLabel "NetApp Disk 1" -Confirm:$False -Force }
    
        Set-Disk -number $LogDisk -IsOffline $False
        Initialize-disk -Number $LogDisk
        New-Partition -DiskNumber $LogDisk -UseMaximumSize -AssignDriveLetter | ForEach-Object { Start-Sleep -s 5; $_| Format-Volume -NewFileSystemLabel "NetApp Disk 2" -Confirm:$False -Force}
        Start-Service -Name ShellHWDetection

        Write-Output "Completed @ $(Get-Date)"
        Stop-Transcript

    } 
    catch {
        Write-Output "$($_.exception.message)@ $(Get-Date)"
		exit 1
    }
 }

 

function Create-NcGroup( [String] $VserverIqn, [String] $InisitatorIqn, [String] $Vserver)
{
    $iGroupList = Get-ncigroup
    $iGroupSetup = $False
    $iGroupInitiatorSetup = $False

    #Find if iGroup is already setup, add if not 
    foreach($igroup in $iGroupList)
    {
        if ($igroup.Name -eq $VserverIqn)   
        {
            $iGroupSetup = $True
            foreach($initiator in $igroup.Initiators)
            {
                if($initiator.InitiatorName.Equals($InisitatorIqn))
                {
                    $iGroupInitiatorSetup = $True
                    Write-Output "Found $VserverIqn Iqn is alerady setup on SvM $Vserver with Initiator $InisitatorIqn" 
                    break
                }
            }

            break
        }
    }
    if($iGroupInitiatorSetup -eq $False)
    {
        if ((get-nciscsiservice).IsAvailable -ne "True") { 
                Add-NcIscsiService 
        }
        if ($iGroupSetup -eq $False) {
            new-ncigroup -name $VserverIqn -Protocol iScSi -Type Windows    
        }
        Add-NcIgroupInitiator -name $VserverIqn -Initiator $InisitatorIqn
        Write-Output "Set up $VserverIqn Iqn on SvM $Vserver"
    }

}

function Set-MultiPathIO()
{
    $IsEnabled = (Get-WindowsOptionalFeature -FeatureName MultiPathIO -Online).State

    if ($IsEnabled -ne "Enabled") {

        Enable-WindowsOptionalFeature –Online –FeatureName MultiPathIO
     }
        
}

function Start-ThisService([String]$ServiceName)
{
    
    $Service = Get-Service -Name $ServiceName
    if ($Service.Status -ne "Running"){
        Start-Service $ServiceName
        Write-Output "Starting $ServiceName"
    }
    if ($Service.StartType -ne "Automatic") {
        Set-Service $ServiceName -startuptype "Automatic"
        Write-Output "Setting $ServiceName Service Startup to Automatic"
    }
   
}

 function Setup-VM ()
 {
    Set-MultiPathIO
    Start-ThisService "MSiSCSI"
 }



# Function for Loading Sample Adventure works database on NetApp 
function Load-SampleDatabase
{
## Creating SQL directory structure on NetApp drives
$DataDirectory = "F:\SQL\DATA"
$LogDirectory = "G:\SQL\Logs"
$BackupDirectory = "F:\SQL\BACKUPS"

function Create-DirectoryStructure
{
New-Item -ItemType directory -Path $DataDirectory
New-Item -ItemType directory -Path $LogDirectory
New-Item -ItemType directory -Path $BackupDirectory

}

## Setting default location of database, logs and backup files to NetApp Drives.
function Set-SQLDataLocation
{
$DataRegKeyPath = "HKLM:\Software\Microsoft\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQLServer"
$DataRegKeyName = "DefaultData"
If ((Get-ItemProperty -Path $DataRegKeyPath -Name $DataRegKeyName -ErrorAction SilentlyContinue) -eq $null) {
  New-ItemProperty -Path $DataRegKeyPath -Name $DataRegKeyName -PropertyType String -Value $DataDirectory
} Else {
  Set-ItemProperty -Path $DataRegKeyPath -Name $DataRegKeyName -Value $DataDirectory
}
 
$LogRegKeyPath = "HKLM:\Software\Microsoft\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQLServer"
$LogRegKeyName = "DefaultLog"
If ((Get-ItemProperty -Path $LogRegKeyPath -Name $LogRegKeyName -ErrorAction SilentlyContinue) -eq $null) {
  New-ItemProperty -Path $LogRegKeyPath -Name $LogRegKeyName -PropertyType String -Value $LogDirectory
} Else {
  Set-ItemProperty -Path $LogRegKeyPath -Name $LogRegKeyName -Value $LogDirectory
}
 
$BackupRegKeyPath = "HKLM:\Software\Microsoft\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQLServer"
$BackupRegKeyName = "BackupDirectory"

If ((Get-ItemProperty -Path $BackupRegKeyPath -Name $BackupRegKeyName -ErrorAction SilentlyContinue) -eq $null) {
  New-ItemProperty -Path $BackupRegKeyPath -Name $BackupRegKeyName -PropertyType String -Value $BackupDirectory
} Else {
  Set-ItemProperty -Path $BackupRegKeyPath -Name $BackupRegKeyName -Value $BackupDirectory
}
}
# Downloading and extracting AdventureWorks2014 DB 

function Download-SampleDatabase
{
wget https://msftdbprodsamples.codeplex.com/downloads/get/880661 -OutFile $BackupDirectory\AdventureWorks2014bakzip.zip

Add-Type -AssemblyName System.IO.Compression.FileSystem

function Unzip
{
    param([string]$zipfile, [string]$outpath)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}

Unzip $BackupDirectory\AdventureWorks2014bakzip.zip $BackupDirectory

}

Create-DirectoryStructure
Set-SQLDataLocation
Restart-Service -Force MSSQLSERVER
Download-SampleDatabase

}
function Remove-Password([String]$password)
{
$azurelogfilepath = 'C:\WindowsAzure\Logs\Plugins\Microsoft.Compute.CustomScriptExtension\1.8\CustomScriptHandler.log'
$scriptlogfilepath = 'C:\WindowsAzure\Logs\SQLNetApp_Connect_Storage.ps1.txt'
(get-content $azurelogfilepath) | % { $_ -replace $password, 'passwordremoved' } | set-content $azurelogfilepath
(get-content $scriptlogfilepath) | % { $_ -replace $password, 'passwordremoved' } | set-content $scriptlogfilepath
}

function Install-NetAppPSToolkit
{
New-Item C:\NetApp -Type Directory
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/netapp-ontap-sql/scripts/NetApp_PowerShell_Toolkit_4.3.0.msi","C:\NetApp\NetApp_PowerShell_Toolkit_4.3.0.msi")
Invoke-Command -ScriptBlock { & cmd /c "msiexec.exe /i C:\NetApp\NetApp_PowerShell_Toolkit_4.3.0.msi" /qn ADDLOCAL=F.PSTKDOT}
}
## Starting functions execution

$SVMPwd = $OTCpassword
Install-NetAppPSToolkit
Get-ONTAPClusterDetails $email $password $ocmip
Connect-ONTAP $AdminLIF $iScSILIF $SVMName $SVMPwd $Capacity
Load-SampleDatabase
Remove-Password $password
