#http://geekswithblogs.net/Wchrabaszcz/archive/2013/09/04/how-to-install-windows-server-features-using-powershell--server.aspx
Configuration WebServerConfig
{
	Node ("localhost")
	{
		#Install the IIS Role
		WindowsFeature IIS
		{
			Ensure = "Present"
			Name = "Web-Server"
		}

		#Install ASP.NET 4.5
		WindowsFeature ASP45
		{
			Ensure = "Present"
			Name = "Web-Asp-Net45"
		}

		#Install ASP.NET 3.5
		WindowsFeature ASP35
		{
			Ensure = "Present"
			Name = "Web-Asp-Net"
		}

		#Install NET Extensibility 35
		WindowsFeature NetExt35
		{
			Ensure = "Present"
			Name = "Web-Net-Ext"
		}
		
		#Install NET Extensibility 45
		WindowsFeature NetExt45
		{
			Ensure = "Present"
			Name = "Web-Net-Ext45"
		}

		#Install ISAPI Filters
		WindowsFeature ISAPI_Filters
		{
			Ensure = "Present"
			Name = "Web-ISAPI-Filter"
		}

		#Install ISAPI Extensions
		WindowsFeature WebISAPI_EXT
		{
			Ensure = "Present"
			Name = "Web-ISAPI-Ext"
		}

		#Install Default Document
		WindowsFeature DefaultDocument
		{
			Ensure = "Present"
			Name = "Web-Default-Doc"
		}

		#Install Static Content
		WindowsFeature StaticContent
		{
			Ensure = "Present"
			Name = "Web-Static-Content"
		}

		#Install Dynamic Content Compression
		WindowsFeature DynamicContentCompression
		{
			Ensure = "Present"
			Name = "Web-Dyn-Compression"
		}
		
		#Install Static Content Compression
		WindowsFeature StaticContentCompression
		{
			Ensure = "Present"
			Name = "Web-Stat-Compression"
		}

		#Install Request Filtering
		WindowsFeature RequestFiltering
		{
			Ensure = "Present"
			Name = "Web-Filtering"
		}

		WindowsFeature WebServerManagementConsole
		{
			Name = "Web-Mgmt-Console"
			Ensure = "Present"
		}
	}
} 