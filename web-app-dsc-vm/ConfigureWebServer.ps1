Configuration Main
{
  param (
  $MachineName,
  $WebDeployPackagePath,
  $UserName,
  $Password,
  $DbServerName,
  $DbName,
  $DbUserName,
  $DbPassword
  )

  Node ($MachineName)
  {
	   
     WindowsFeature WebServerRole

        {

           

            Name = "Web-Server"

            Ensure = "Present"


            }

	 
        WindowsFeature WebAppDev

        {

            Name = "Web-App-Dev"

            Ensure = "Present"


            DependsOn = "[WindowsFeature]WebServerRole"

            }

	   WindowsFeature WebAspNet45

        {

            Name = "Web-Asp-Net45"

            Ensure = "Present"

            Source = $Source

            DependsOn = "[WindowsFeature]WebServerRole"

            }

        WindowsFeature WebNetExt35

        {

            Name = "Web-Net-Ext"

            Ensure = "Present"

            DependsOn = "[WindowsFeature]WebServerRole"

            }

	   WindowsFeature WebNetExt45

        {

            Name = "Web-Net-Ext45"

            Ensure = "Present"

            DependsOn = "[WindowsFeature]WebServerRole"

            }

	  WindowsFeature WebFtpServer
	  {
		Name = "Web-Ftp-Server"

		Ensure = "Present"

        DependsOn = "[WindowsFeature]WebServerRole"
	  
	  }

	  WindowsFeature WebMgmtCompat
	  {
		Name = "Web-Mgmt-Compat"

		Ensure = "Present"

        DependsOn = "[WindowsFeature]WebServerRole"
	  
	  }

        WindowsFeature WebISAPIExt

        {

            Name = "Web-ISAPI-Ext"

            Ensure = "Present"


            DependsOn = "[WindowsFeature]WebServerRole"

            }

        WindowsFeature WebISAPIFilter

        {

            Name = "Web-ISAPI-Filter"

            Ensure = "Present"

 
            DependsOn = "[WindowsFeature]WebServerRole"

            }

        WindowsFeature WebLogLibraries

        {

            Name = "Web-Log-Libraries"

            Ensure = "Present"

            DependsOn = "[WindowsFeature]WebServerRole"

            }

        WindowsFeature WebRequestMonitor

        {

            Name = "Web-Request-Monitor"

            Ensure = "Present"

            DependsOn = "[WindowsFeature]WebServerRole"

            }

        WindowsFeature WebMgmtTools

        {

            Name = "Web-Mgmt-Tools"

            Ensure = "Present"

            DependsOn = "[WindowsFeature]WebServerRole"

            }

        WindowsFeature WebMgmtConsole

        {

            Name = "Web-Mgmt-Console"

            Ensure = "Present"

            DependsOn = "[WindowsFeature]WebServerRole"

            }

	  WindowsFeature WAS

        {

            Name = "WAS"

            Ensure = "Present"

            DependsOn = "[WindowsFeature]WebServerRole"

            }

	  WindowsFeature WASProcessModel

        {

            Name = "WAS-Process-Model"

            Ensure = "Present"

            DependsOn = "[WindowsFeature]WebServerRole"

            }

	   WindowsFeature WASNetEnvironment

        {

            Name = "WAS-NET-Environment"

            Ensure = "Present"

            DependsOn = "[WindowsFeature]WebServerRole"

            }

	  WindowsFeature WASConfigAPIs

        {

            Name = "WAS-Config-APIs"

            Ensure = "Present"

            DependsOn = "[WindowsFeature]WebServerRole"

            }

   #script block to download WebPI MSI from the Azure storage blob
    Script DownloadWebPIImage
    {
        GetScript = {
            @{
                Result = "WebPIInstall"
            }
        }
        TestScript = {
            Test-Path "C:\WindowsAzure\wpilauncher.exe"
        }
        SetScript ={
            $source = "http://go.microsoft.com/fwlink/?LinkId=255386"
            $destination = "C:\WindowsAzure\wpilauncher.exe"
            Invoke-WebRequest $source -OutFile $destination
       
        }
    }

    Package WebPi_Installation
        {
            Ensure = "Present"
            Name = "Microsoft Web Platform Installer 5.0"
            Path = "C:\WindowsAzure\wpilauncher.exe"
            ProductId = '4D84C195-86F0-4B34-8FDE-4A17EB41306A'
            Arguments = ''
        }

    Package WebDeploy_Installation
        {
            Ensure = "Present"
            Name = "Microsoft Web Deploy 3.5"
            Path = "$env:ProgramFiles\Microsoft\Web Platform Installer\WebPiCmd-x64.exe"
            ProductId = ''
            #Arguments = "/install /products:ASPNET45,ASPNET_REGIIS_NET4,NETFramework452,NETFramework4Update402,NetFx4,NetFx4Extended-ASPNET45,NetFxExtensibility45,DefaultDocument,DirectoryBrowse,StaticContent,StaticContentCompression,WDeploy  /AcceptEula"
			Arguments = "/install /products:WDeploy  /AcceptEula"
			DependsOn = @("[Package]WebPi_Installation")
        }
	

	Script DeployWebPackage
	{
		GetScript = {
            @{
                Result = ""
            }
        }
        TestScript = {
            $false
        }
        SetScript ={

		$WebClient = New-Object -TypeName System.Net.WebClient
		$Destination= "C:\WindowsAzure\WebApplication.zip" 
        $WebClient.DownloadFile($using:WebDeployPackagePath,$destination)
        $ConnectionStringName = "DefaultConnection-Web.config Connection String"
        $ConnectionString = "Server=tcp:"+ "$using:DbServerName" + ".database.windows.net,1433;Database=" + "$using:DbName" + ";User ID=" + "$using:DbUserName" + "@$using:DbServerName" + ";Password=" + "$using:DbPassword"+ ";Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
        $ConnectionString | Out-File -filepath C:\WindowsAzure\outfile.txt -append -width 200
        $Argument = '-source:package="C:\WindowsAzure\WebApplication.zip"' + ' -dest:auto,ComputerName="localhost",'+"username=$using:UserName" +",password=$using:Password" + ' -setParam:name="' + "$ConnectionStringName" + '"'+',value="' + "$ConnectionString" + '" -verb:sync -allowUntrusted'
		$MSDeployPath = (Get-ChildItem "HKLM:\SOFTWARE\Microsoft\IIS Extensions\MSDeploy" | Select -Last 1).GetValue("InstallPath")
        Start-Process "$MSDeployPath\msdeploy.exe" $Argument -Verb runas
        
        }

	}





    
  }

}
