Configuration Main
{

	Param ( [string] $nodeName,
			[string] $connectionString,
			[string] $sqVM_AppAdmin_UserName,
			[string] $sqVmAdminPwd,
			[string] $sqLtsVersion
		)

	Import-DscResource -ModuleName PSDesiredStateConfiguration ,xNetworking, xRemoteDesktopAdmin, xSystemSecurity, GraniResource, DSC_ColinsALMCorner.com, cSecurityOptions, xWebAdministration

	# Installation Variables
	$sqDestination = 'C:\sq'
	#Expose the parameter instead to enable easily update 
	#$sonarQubeVersion="sonarqube-5.6.1"
	$sonarQubeVersionZip = $sqLtsVersion + ".zip"
	$sonarQubeBitness="windows-x86-64"  #The JDK_8 VM runs 64-bit Java
	$sonarQubeDownloadRoot = "https://sonarsource.bintray.com/Distribution/sonarqube/"
	$sonarQubeDownloadUrl = $sonarQubeDownloadRoot + $sonarQubeVersionZip
	$localDownloadDestination = $sqDestination + "\" + $sonarQubeVersionZip

	# SonarQube config file variables
	$sqConfigFile = "sonar.properties"
	$sqConfigFolder = "conf"
	$pathToSQVersion = $sqDestination + "\" + $sqLtsVersion
	$pathToSQConfig = $pathToSQVersion  + "\" + $sqConfigFolder + "\" + $sqConfigFile
	$sqConnStringToReplace = "#sonar.jdbc.url=jdbc:sqlserver://localhost;databaseName=sonar;integratedSecurity=true"
	$newConnectionString = "sonar.jdbc.url=" + $connectionString

	# Windows Service variables
	$serviceName = "SonarQube"
	$serviceDisplayName = "SonarQube" 
	$serviceDescription = "SonarQube" 
	$serviceInstaller = "InstallNTService.bat"
	$sqServiceDirectoryPath = $sqDestination +  "\" + $sqLtsVersion + "\bin\" + $sonarQubeBitness
	$sqServiceInstallerPath = $sqServiceDirectoryPath + "\" + $serviceInstaller

	# Fully qualify the admin username for use in the SonarQube Windows Service
	$localAdminUserName = $nodeName + '\' + $sqVM_AppAdmin_UserName

	Node $nodeName
	  {
		#Configure the server	
		xIEEsc DisableIEEscForUsers {
				IsEnabled = $false
				UserRole = "Users"
			}
		xIEEsc DisableIEEscForAdmins {
				IsEnabled = $false
				UserRole = "Administrators"
			}
		xRemoteDesktopAdmin RemoteDesktopSettings {
			Ensure = 'Present'
			UserAuthentication = 'Secure'
		}
		xFirewall AllowRDP {
			Name = 'DSC - Remote Desktop Admin Connections'
			DisplayGroup = "Remote Desktop"
			Ensure = 'Present'
			State = 'Enabled'
			Access = 'Allow'
			Profile = ("Domain", "Private", "Public")
		}
				
		#Enable IIS
		WindowsFeature WebServer
        {
            Name = "Web-Server"
            Ensure = "Present"
        }
		WindowsFeature IISManagementxTools {
			Name = "Web-Mgmt-Tools"
			Ensure = "Present"
			IncludeAllSubFeature = $true
			DependsOn = "[WindowsFeature]WebServer"
		}
		File SonarQubeProxyFolder {
            Ensure = "Present"
            Type = "Directory"
            Recurse = $false
            DestinationPath = "C:\Inetpub\wwwroot\SonarQubeProxy"
            Force = $true			
        }
		xWebsite SonarQubeProxy {
            Ensure = "Present"
            Name = "SonarQubeProxy"
            PhysicalPath = "C:\Inetpub\wwwroot\SonarQubeProxy"
            DependsOn = "[File]SonarQubeProxyFolder"
            State = "Started"
			BindingInfo = MSFT_xWebBindingInformation
                        {
                            Protocol = "HTTP"
                            Port = 8080
                            #CertificateThumbprint = $certificate
                    		#CertificateStoreName  = "MY"
							IPAddress ='*'
                        }
        }		
		#This firewall rule is only necessary until we get a secure HTTPS configuration
		xFirewall SonarQubeHTTPFirewallRule {
			Direction = "Inbound"
			Name = "SonarQube"
			DisplayName = "SonarQube (TCP-In)"
			Description = "Inbound rule for SonarQube to allow HTTP traffic."
			DisplayGroup = "SonarQube"
			State = "Enabled"
			Access = "Allow"
			Protocol = "TCP"
			LocalPort = "9000"
			Ensure = "Present"
			Profile = ("Domain", "Private", "Public")
		}

		xFirewall SonarQubeHTTPSFirewallRule {
			Direction = "Inbound"
			Name = "SonarQubeHTTPS"
			DisplayName = "SonarQube HTTPS (TCP-In)"
			Description = "Inbound rule for SonarQube to allow HTTPS traffic."
			DisplayGroup = "SonarQube"
			State = "Enabled"
			Access = "Allow"
			Protocol = "TCP"
			Ensure = "Present"
			Profile = ("Domain", "Private", "Public")
		}		

		#Download, install and configure SonarQube
		File CreateSQFolder
		{
			DestinationPath = "$sqDestination"
			Ensure = "Present"
			Type = "Directory"
		}		
		#Download the SonarQube zip file from SonarQube.org
		cDownload DownloadSonarQube	{
			Uri = "$sonarQubeDownloadUrl"
			DestinationPath = "$localDownloadDestination"
			DependsOn =  '[File]CreateSQFolder', '[xIEEsc]DisableIEEscForUsers'
		}

		#Deploy SonarQube by unzipping
		Archive UnzipSonarQube
		{
			DependsOn = '[cDownload]DownloadSonarQube'
			Ensure = "Present"
			Path = "$localDownloadDestination"
			Destination = "$sqDestination"
		} 

		#Update the connection string in the config file with the passed-in connection string
		cScriptWithParams ReplaceConnectionString {
			DependsOn = '[Archive]UnzipSonarQube'
			GetScript = {
							$Change = Get-Content -Raw -Path $pathToConfig
							$connStringRaw = $Change | Select-String $searchFor 
							return @{'ConnStringFound' = $connStringRaw}
						}
			TestScript = {
							if ((Get-Content $pathToConfig) | Select-String -Pattern $searchFor )
							{
								Write-Verbose -Message ('Commented out connection string found. Updating to correct connection string')
								return $false
							}
							Write-Verbose -Message ('Connection string already updated.  Skipping change.')
							return $true
						}
			SetScript = {
							Write-Verbose -Message ('Replacing commented-out connection string with Azure SQL connection string')
							$content = Get-Content -Raw -Path $pathToConfig
							$content = $content.Replace($searchFor, $replaceWith)
							Set-Content -Path $pathToConfig -Value $content
						}
			cParams = 
				@{
					pathToConfig = $pathToSQConfig;
					searchFor = $sqConnStringToReplace;
					replaceWith = $newConnectionString;
				}
		}

		#Run the SonarQube's InstallNTService.bat file to get the service in place. This runs as LocalService by default
		cScriptWithParams InstallSonarQubeAsAService {
			DependsOn = "[cScriptWithParams]ReplaceConnectionString"
			GetScript = {
							return @{}
						}
			TestScript = {
							if (Get-Service $serviceName -ErrorAction SilentlyContinue) 
							{ 
								Write-Verbose -Message ("SonarQube service already installed.  Skipping change" )
								return $true 
							} 				
							Write-Verbose -Message ("SonarQube service not found.  Installing service" )
							return $false
						}

			SetScript = {
							#Run the SonarQube service installer
							Write-Verbose -Message ("SonarQube Windows Service Installation - Start")
							Write-Verbose -Message ("    Executing Service Installer - Start")
							$p = [System.Diagnostics.Process]::Start("$installerPath")
							$p.WaitForExit();
							Write-Verbose -Message ("    Executing Service Installer - Done")
							Write-Verbose -Message ("SonarQube Windows Service Installation - Done")

						}
			cParams = 
				@{
					serviceName = $serviceName;
					installerPath = $sqServiceInstallerPath;
				}
		}
		#Make sure our service account has LogOn As A Service rights
		UserRightsAssignment SetLogOnAsService {
			Privilege = 'SeServiceLogonRight'
			Ensure = 'Present'
			Identity = $sqVM_AppAdmin_UserName, 'NT SERVICE\ALL SERVICES'
		}

		#Make sure the SonarQube service is running as the service account and not LocalService. 
		cScriptWithParams UpdateSonarQubeServiceAcct {
			DependsOn = "[cScriptWithParams]InstallSonarQubeAsAService", "[UserRightsAssignment]SetLogOnAsService"
			GetScript = {
							return @{}
						}
			TestScript = {
							$fullUser = '.\' + $login
							$svc = Get-WmiObject win32_service -filter "name='$serviceName'"
							if ($svc.Name -eq $fullUser)
							{
								Write-Verbose -Message ("SonarQube service account already set.  Skipping change." )
								return $true 								
							}			
							Write-Verbose -Message ("SonarQube service account not set.  Updating service account." )
							return $false
						}
			SetScript = {			
						Write-Verbose -Message ("SonarQube Windows Service Account Update - Start")
						$fullUser = '.\' + $login		
						Write-Verbose -Message ("    Setting service account to '" + $fullUser + "'")
							$filter = 'Name=' + "'" + $serviceName + "'" + ''
						$service = Get-WMIObject -class Win32_Service -Filter $filter
						$service.Change($null,$null,$null,$null,$null,$false,$fullUser,$password)
						Write-Verbose -Message ("    Restarting service")
						$service.StopService()
						while ($service.Started){
								Write-Verbose -Message ("        Waiting for service to stop")
						        sleep 2
								$service = Get-WMIObject -class Win32_Service -Filter $filter
							}
                            Write-Verbose -Message ("        Service stopped...restarting")
							$service.StartService()

							Write-Verbose -Message ("SonarQube Windows Service Account Update - Done")
						}
			cParams = 
				@{
					serviceName = $serviceName;
					login = $sqVM_AppAdmin_UserName;
					password = $sqVmAdminPwd;
				}
		}
	}
}

	
#****************************************************
#	Lines below are used for debugging when running
#	on the SonarQube VM.
#****************************************************
#$sqVmAdminPwd = Read-Host -AsSecureString
#Main -nodeName "sq2" -connectionString "jdbc://steve" -sqVM_AppAdmin_UserName "steve" -sqVmAdminPwd $sqVmAdminPwd
#Start-DscConfiguration ".\Main" -Wait -Verbose -Force 

