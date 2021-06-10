Configuration Main
{

Param ( [string] $nodeName, [string] $webDeployPackage  )

Import-DscResource -ModuleName PSDesiredStateConfiguration

Node $nodeName
  {
   # This commented section represents an example configuration that can be updated as required.
    WindowsFeature WebServerRole
    {
      Name = "Web-Server"
      Ensure = "Present"
    }
    WindowsFeature WebManagementConsole
    {
      Name = "Web-Mgmt-Console"
      Ensure = "Present"
    }
    WindowsFeature WebManagementService
    {
      Name = "Web-Mgmt-Service"
      Ensure = "Present"
    }
    WindowsFeature ASPNet45
    {
      Name = "Web-Asp-Net45"
      Ensure = "Present"
    }
    WindowsFeature HTTPRedirection
    {
      Name = "Web-Http-Redirect"
      Ensure = "Present"
    }
    WindowsFeature CustomLogging
    {
      Name = "Web-Custom-Logging"
      Ensure = "Present"
    }
    WindowsFeature LogginTools
    {
      Name = "Web-Log-Libraries"
      Ensure = "Present"
    }
    WindowsFeature RequestMonitor
    {
      Name = "Web-Request-Monitor"
      Ensure = "Present"
    }
    WindowsFeature Tracing
    {
      Name = "Web-Http-Tracing"
      Ensure = "Present"
    }
    WindowsFeature BasicAuthentication
    {
      Name = "Web-Basic-Auth"
      Ensure = "Present"
    }
    WindowsFeature WindowsAuthentication
    {
      Name = "Web-Windows-Auth"
      Ensure = "Present"
    }
    WindowsFeature ApplicationInitialization
    {
      Name = "Web-AppInit"
      Ensure = "Present"
    }
	##Get-WindowsFeature NET-WCF-* | format-table -property name,displayname -AutoSize	
	WindowsFeature WCFServices45
    {
      Name = "NET-WCF-Services45"
      Ensure = "Present"
    }

	WindowsFeature HTTPActivation
    {
      Name = "NET-WCF-HTTP-Activation45"
      Ensure = "Present"
    }

	WindowsFeature MSMQActivation
    {
      Name = "NET-WCF-MSMQ-Activation45"
      Ensure = "Present"
    }

	WindowsFeature NamedPipeActivation
    {
      Name = "NET-WCF-Pipe-Activation45"
      Ensure = "Present"
    }
	WindowsFeature TCPActivation
    {
      Name = "NET-WCF-TCP-Activation45"
      Ensure = "Present"
    }
    Script DownloadWebDeploy
    {
        TestScript = {
            Test-Path "C:\WindowsAzure\WebDeploy_amd64_en-US.msi"
        }
        SetScript ={
            $source = "https://download.microsoft.com/download/0/1/D/01DC28EA-638C-4A22-A57B-4CEF97755C6C/WebDeploy_amd64_en-US.msi"
            $dest = "C:\WindowsAzure\WebDeploy_amd64_en-US.msi"
            Invoke-WebRequest $source -OutFile $dest
        }
        GetScript = {@{Result = "DownloadWebDeploy"}}
        DependsOn = "[WindowsFeature]WebServerRole"
    }
    Package InstallWebDeploy
    {
        Ensure = "Present"  
        Path  = "C:\WindowsAzure\WebDeploy_amd64_en-US.msi"
        Name = "Microsoft Web Deploy 3.6"
        ProductId = "{ED4CC1E5-043E-4157-8452-B5E533FE2BA1}"
        Arguments = "ADDLOCAL=ALL"
        DependsOn = "[Script]DownloadWebDeploy"
    }
    Service StartWebDeploy
    {                    
        Name = "WMSVC"
        StartupType = "Automatic"
        State = "Running"
        DependsOn = "[Package]InstallWebDeploy"
    } 
	
	# Install the IIS role 
		#WindowsFeature IIS 
		#{ 
		#	Ensure          = "Present" 
		#	Name            = "Web-Server" 
		#} 
		## Install the ASP .NET 4.5 role 
		#WindowsFeature AspNet45 
		#{ 
		#	Ensure          = "Present" 
		#	Name            = "Web-Asp-Net45" 
		#} 
	   
		Script DeployWebPackage
		{
			GetScript = {@{Result = "DeployWebPackage"}}
			TestScript = {$false}
			SetScript ={
				[system.io.directory]::CreateDirectory("C:\WebApp")
				$dest = "C:\WebApp\Site.zip" 
				Remove-Item -path "C:\inetpub\wwwroot" -Force -Recurse -ErrorAction SilentlyContinue
				Invoke-WebRequest $using:webDeployPackage -OutFile $dest
				Add-Type -assembly "system.io.compression.filesystem"
				[io.compression.zipfile]::ExtractToDirectory($dest, "C:\inetpub\wwwroot")	
				$SourceFolder = "C:\inetpub\wwwroot"
				$appPaths = @(Get-ChildItem $SourceFolder -Directory)
				foreach ($appPath in $appPaths) 
				{ 
					$x = "IIS:\Sites\Default Web Site\" + $appPath.Name 
					ConvertTo-WebApplication -PSPath $x 
				}   			
			}
			DependsOn  = "[WindowsFeature]WebServerRole"
		}

		# Copy the website content 
		File WebContent 
		{ 
			Ensure          = "Present" 
			SourcePath      = "C:\WebApp"
			DestinationPath = "C:\Inetpub\wwwroot"
			Recurse         = $true 
			Type            = "Directory" 
			DependsOn       = "[Script]DeployWebPackage" 			

		}
  }
}
