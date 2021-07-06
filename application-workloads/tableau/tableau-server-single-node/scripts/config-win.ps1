Param(
    [string]$ts_admin_un,
    [string]$ts_admin_pass,
    [string]$reg_first_name,
    [string]$reg_last_name,
    [string]$reg_email,
    [string]$reg_company,
    [string]$reg_title,
    [string]$reg_department,
    [string]$reg_industry,
    [string]$reg_phone,
    [string]$reg_city,
    [string]$reg_state,
    [string]$reg_zip,
    [string]$reg_country,
    [string]$license_key,
    [string]$install_script_url,
    [string]$local_admin_user,
    [string]$local_admin_pass,
    [string]$ts_build,
    [string]$eula
)    

#v1

$folder = "C:\tab\"  
$reg_file = $folder+"rg.json"
$iDP_config = $folder+"cf.json"
$other = $folder+"other.json"
$log_file = $folder+"install.log"
$event_file = $folder+"event.log"
$bootstrapfile = "bootstrap.json"  

$global:major = ''
$global:minor = '' 
$global:hotfix = ''
$global:DownloadFile = ''

 
function func_createFolder{
                                                   
    if(Test-Path $folder)
    {
        Write-ToLog -text  "'The ' $folder 'folder already exists'"
    }
    else
        {
            New-Item -Path $folder -ItemType Directory
            Write-ToLog -text  "Created folder $folder"
        }
}

function func_regFile{ 
        ## 2. make registration.json
        #TODO: add parameter for accepting eula
   @{
        first_name = $reg_first_name
        last_name = $reg_last_name
        email = $reg_email
        # company = "$reg_company
        company = "$reg_company-azure-arm-windows"
        title = $reg_title
        department = $reg_department
        industry = $reg_industry
        phone = $reg_phone
        city = $reg_city
        state = $reg_state
        zip = $reg_zip
        country = $reg_country
        eula = $eula
    } | ConvertTo-Json | Out-File $reg_file 
}

function func_configFile{ 
    @{
       configEntities = @{
           identityStore= @{
               _type= "identityStoreType"
               type= "local"
           }
       }
   } | ConvertTo-Json| Out-File $iDP_config 
     
}
function func_Other{
    @{
        local_admin_user = $local_admin_user
        local_admin_pass = $local_admin_pass
        content_admin_user = $ts_admin_un
        content_admin_pass = $ts_admin_pass
        product_keys = $license_key
        ts_build = $ts_build
    } | ConvertTo-Json | Out-File $other 

    
    $global:ts_build = $(Get-Content -raw $other  | ConvertFrom-Json | Select-Object ts_build).ts_build
    $global:product_keys = $(Get-Content -raw $other  | ConvertFrom-Json | Select-Object product_keys).product_keys
    
}

function Write-ToLog ($text) {
    
    $message = "[{0:yyyy/MM/dd/} {0:HH:mm:ss}]" -f (Get-Date) +", "+ $text 
    Write-Host  $message
    Write-Output $message | Out-file $event_file -Append -Encoding default

}
function func_Version ($version) {
   
    if(!$Version)
    {
        Write-Host "-Version is missing a value. It should be in the format xxxx.x.x like for example 2019.1.4 or type Trial to active a 14 day trial"
    }
    elseif($version.ToString().Length -ne 8)
    {
        Write-Host "-Version is in the wrong format. It should be in the format xxxx.x.x like for example 2019.1.4"
        
    }

    elseif($version.ToString().Length -eq 8)
            {
            if ($version -like '*.*')
            {
                $global:major = $version.substring(0,4)
                $global:minor = $version.substring(0,$version.lastindexof('.')).substring(5)
                $global:hotfix = $version.substring($version.length-1)
                
            }
            elseif ($version -like '*-*')
            {
                $version = $version.ToString().replace('-','.') 
                $global:major = $version.substring(0,4)
                $global:minor = $version.substring(0,$version.lastindexof('.')).substring(5)
                $global:hotfix = $version.substring($version.length-1)
                
            }
        }
        #return $global:major, $global:minor, $global:hotfix
}
function func_Download($folder, $log_file, $event_file,$version_major, $version_minor, $version_hotfix){
    
    try{#Set the path  to the server version of Tableau that you want to download
        $global:DownloadFile = "TableauServer-64bit-"+$version_major+"-"+$version_minor+"-"+$version_hotfix+".exe"
        $url = "https://downloads.tableau.com/esdalt/"+$version_major+"."+$version_minor+"."+$version_hotfix+"/"+$DownloadFile

        Write-ToLog -text $url
        #Download the server installation file
        if(Test-Path $($folder+$global:DownloadFile))
        {    
            Write-ToLog -text  $($folder+$DownloadFile) ' exists'
        }
        else
        { 
            Write-ToLog -text "Starting Tableau Server media download..." 
            Write-ToLog -text "Start-BitsTransfer -Source $url -Destination $($folder+$DownloadFile) -TransferType Download -Priority High"  
            Start-BitsTransfer -Source $url -Destination $($folder+$DownloadFile) -TransferType Download -Priority High 
            Write-ToLog -text "Tableau Server media download completed successfully"    
        }

    }
    catch
        {
            Write-ToLog -text $PSItem.Exception.Message
        }
}

function func_Install($file_path, $log_path)
{
    
        try {
                if((Test-Path HKLM:\SOFTWARE\Tableau\) -eq $false)
                {
                    Write-ToLog -text  "Starting Tableau Server installation"
                    if($global:major -le 2019 -and $global:minor -lt 4 -or $global:major -le 2018 ){
                        Write-Host -text "$file_path /install /silent /ACCEPTEULA = 1 /LOG $log_path"      
                        Start-Process -FilePath $file_path -ArgumentList " /install /silent /ACCEPTEULA = 1 /LOG '$log_path'" -Verb RunAs -Wait
                    }
                    elseif ($global:major -ge 2019 -and $global:minor -eq 4 -or $global:major -ge 2020) {
                        Write-ToLog -text "$file_path /install /passive ACCEPTEULA=1"
                        Start-Process -FilePath $file_path -ArgumentList " /install /passive ACCEPTEULA=1" -Verb RunAs -Wait  
                    }
                    
                    Write-ToLog -text "Tableau Server installation completed successfully"
                }
                else
                {
                    Write-ToLog -text 'Tableau server is already installed'
                }

                #Identifying path to TSM
                #Get-ItemProperty -Path HKLM:\SOFTWARE\Tableau $version_full*
                Write-ToLog -text "Adding TSM to local Windows system PATH"
    
                #Check if Tableau is installed on the Server
                if((Test-Path HKLM:\SOFTWARE\Tableau\) -eq $true)
                {
                    $reg_path = "HKLM:\SOFTWARE\Tableau\Tableau Server *\Directories"
                    #Get the AppVersion Property from the registry that contains the path to the 
                    if ( (Get-Item $reg_path | Get-ItemProperty | Select-Object Application).Application -eq '\$')
                    {
                        $packages =  ((Get-Item $reg_path | Get-ItemProperty | Select-Object Application).Application+"Packages")
                    }
                    else
                    {
                        $packages =  ((Get-Item $reg_path | Get-ItemProperty | Select-Object Application).Application+"\Packages")
                    }
                    Write-ToLog -text "$packages"
                    $bin = (Get-ItemProperty ($packages+"\bin.*") | Select-Object Name).Name
                    $global:tsm_path = $packages+"\"+$bin+"\";
                    
                    #Add TSM to Windows Path
                    $Env:path += $global:tsm_path
                }

                #Generate bootstrap file
                if($Bootstrap -eq $true)
                {
                    Write-ToLog -text  "Creating bootstrap file in $folder"
                    Invoke-Expression "tsm topology nodes get-bootstrap-file --file '$bootstrapfile'"
                }
        }
        catch
            {
                Write-ToLog -text $PSItem.Exception.Message
            }
}
 
function func_Configure($folder, $reg_file, $iDP_config, $log_file, $event_file, $license_key)
{
                                
            try{
                
                $tsm = $global:tsm_path +"tsm.cmd"
                $tabcmd = $global:tsm_path +"tabcmd.exe"
                Write-ToLog $tsm
                #Activate Tableau Server license
                Write-ToLog -text  "Tableau Server License activation started"

                #Activate Tableau server 14 day trial 
                if($license_key.ToLower() -eq 'trial'){
                    Write-ToLog -text  "$tsm licenses activate -t"
                    Start-Process $tsm -ArgumentList " licenses activate -t" -Wait
                    Write-ToLog -text "Tableau Server 14 day Trial activated"
                }
                #Activate Tableau server 
                elseif($license_key -match '^[0-9A-Za-z]{4}[-][0-9A-Za-z]{4}[-][0-9A-Za-z]{4}[-][0-9A-Za-z]{4}[-][0-9A-Za-z]{4}$'){
                    Write-ToLog -text  "$tsm licenses activate -k $license_key"
                    Start-Process $tsm -ArgumentList " licenses activate -k $license_key" -Wait
                    Write-ToLog -text "Tableau Server License activation completed successfully"
                }
               
                #Register Tableau Server 
                Write-ToLog -text "Starting Tableau Server registration"
                Write-ToLog "$tsm register --file $reg_file"
                Start-Process $tsm -ArgumentList " register --file $reg_file" -Wait
                Write-ToLog -text "Completed Tableau Server registration"

                #Set local repository
                Write-ToLog -text "Starting Tableau Server local Repository setup"
                Write-ToLog -text "$tsm settings import -f $iDP_config"
                Start-Process $tsm -ArgumentList " settings import -f $iDP_config" -Wait
                Write-ToLog -text "Completed Tableau Server local Repository setup"

                Write-ToLog -text "Setting Tableau Server Run As Service Account"
                if($local_admin_user -match "[\\]" -or $local_admin_user -match "@") 
                {
                    Write-ToLog -text "$tsm configuration set -k service.runas.username -v $local_admin_user"
                    Start-Process $tsm -ArgumentList " configuration set -k service.runas.username -v $local_admin_user"  -Wait
                }
                elseif($local_admin_user -notmatch "[\\]" -or $local_admin_user -notmatch "@")
                {
                    Write-ToLog -text "$tsm configuration set -k service.runas.username -v .\$local_admin_user"
                    Start-Process $tsm -ArgumentList " configuration set -k service.runas.username -v .\$local_admin_user" -Wait
                }
                Write-ToLog -text "Completed configuring Tableau Server Run As Service Account"

                Write-ToLog -text "Setting Tableau Server Run As Service Account password"
                Write-ToLog -text "$tsm configuration set -k service.runas.password -v $local_admin_pass"
                Start-Process $tsm -ArgumentList " configuration set -k service.runas.password -v $local_admin_pass" -Wait
                Write-ToLog -text "Completed configuring Tableau Server Run As Service Account password"    

                #Apply pending changes
                Write-ToLog -text "Applying pending TSM changes"
                Write-ToLog -text "$tsm pending-changes apply"
                Start-Process $tsm -ArgumentList " pending-changes apply" -Wait
                Write-ToLog -text "TSM changes applied successfully."

                #Initialize configuration
                Write-ToLog -text "Initializing Tableau Server"
                Write-ToLog -text "$tsm initialize -r"
                Start-Process $tsm -ArgumentList " initialize -r " -Wait
                Write-ToLog -text "Tableau Server initialized"

                #Initialize configuration
                Write-ToLog -text "Adding initial Admin user"
                Write-ToLog -text "$tabcmd initialuser -s http://localhost -u $ts_admin_un -p $ts_admin_pass"
                Start-Process $tabcmd -ArgumentList " initialuser -s http://localhost -u $ts_admin_un -p $ts_admin_pass"  -Wait
                Write-ToLog -text "Initial Admin user added"
            } 
            catch
            {
                Write-ToLog -text $PSItem.Exception.Message
            }
}

function func_fw_Rules{
                        Write-ToLog -text "New-NetFirewallRule -DisplayName 'Open Inbound Port 80' -Direction Inbound -LocalPort 80 -Protocol TCP -Action Allow"
                        New-NetFirewallRule -DisplayName "Open Inbound Port 80" -Direction Inbound -LocalPort 80 -Protocol TCP -Action Allow
                        Write-ToLog -text "New-NetFirewallRule -DisplayName 'Open Inbound Port 8850' -Direction Inbound -LocalPort 8850 -Protocol TCP -Action Allow"
                        New-NetFirewallRule -DisplayName "Open Inbound Port 8850" -Direction Inbound -LocalPort 8850 -Protocol TCP -Action Allow
}
function func_AntiVirus(){
    #Disable antivirus scan for the folder that is being used during the installation
    Write-ToLog -text "Adding C:\Downloads to AV Exlusion"
    Add-MpPreference -ExclusionPath $folder

    if((Test-Path HKLM:\SOFTWARE\Tableau\) -eq $true){
        $ts_install = (Get-Item "HKLM:\SOFTWARE\Tableau\Tableau Server *\Directories" | Get-ItemProperty | Select-Object Application).Application
        Write-ToLog -text $ts_install

        $ts_data =  (Get-Item "HKLM:\SOFTWARE\Tableau\Tableau Server *\Directories" | Get-ItemProperty | Select-Object Data).Data   
        Write-ToLog -text $ts_data 
        
        Add-MpPreference -ExclusionPath $ts_install 
        Write-ToLog -text "Added Tableau server install folder to AntiVirus Exlusions"
        Add-MpPreference -ExclusionPath $ts_data 
        Write-ToLog -text "Added Tableau server data folder to AntiVirus Exlusions"
    }
}  
function func_cleanUp{
    Write-ToLog -text "Remove-Item -Path $($folder+$DownloadFile) -Force"
    Remove-Item -Path $($folder+$DownloadFile) -Force
}
function func_main(){
    func_createFolder
    func_regFile
    func_configFile
    func_Other

    #Set paramaters for the Tableau Server version
    func_Version -version $global:ts_build
    #Download Tableau server installation files
    func_Download  -folder $folder $log_file -event_file $event_file -version_major $global:major -version_minor $global:minor -version_hotfix $global:hotfix
    #Install Tableau server
    func_Install -log_path $log_file -file_path $($folder+$global:DownloadFile)
    #Configure tableau server
    func_Configure -folder $folder -reg_file $reg_file -iDP_config $iDP_config -log_file $log_file  -event_file $event_file -license_key $global:product_keys
    #func_AntiVirus
    func_fw_Rules
    func_cleanUp
}

func_main
