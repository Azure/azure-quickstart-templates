<#
    .SYNOPSIS
        Secure SonarQube installation
#>
param
(
      [string]$serverName,
      [string]$websiteName,
      [string]$installationType,
      [string]$reverseProxyType
)
if($installationType -eq 'Secure')
{
    #Install IIS
    #import-module ServerManager
    #Add-WindowsFeature Web-Server,web-management-console
    #Create Web Site
     
    #Install ARR
    Invoke-Expression ((new-object net.webclient).DownloadString("https://chocolatey.org/install.ps1"))
    cinst urlrewrite -y --force
    cinst iis-arr -y --force
    #Update web site binding
    $existingCertificate =Get-ChildItem cert:\LocalMachine\CA | Where-Object subject -eq 'CN=$serverName'
    if($existingCertificate -eq $null)
        {
            Import-Module WebAdministration
            Set-Location IIS:\SslBindings
            New-WebBinding -Name $websiteName -IP "*" -Port 443 -Protocol https
            $c = New-SelfSignedCertificate -DnsName "$serverName" -CertStoreLocation "cert:\LocalMachine\My"
            $c | New-Item 0.0.0.0!443
            #Remove HTTP binding 
            Get-WebBinding -Port 8080 -Name $websiteName | Remove-WebBinding
            #Remove HTTP firewall
            netsh advfirewall firewall delete rule name="SonarQube (TCP-In)"
            #Enable ARR Porxy
            Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST'  -filter "system.webServer/proxy" -name "enabled" -value "True"
            #Disable reverse rewrite host 
            Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST'  -filter "system.webServer/proxy" -name "reverseRewriteHostInResponseHeaders" -value "False"
            Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST'  -filter "system.webServer/rewrite/allowedServerVariables" -name "reverseRewriteHostInResponseHeaders" -value "False"
            #Add Server Variables 
            Add-WebConfiguration  -pspath 'MACHINE/WEBROOT/APPHOST' -filter '/system.webServer/rewrite/allowedServerVariables' -atIndex 0 -value @{name="X_FORWARDED_PROTO";value="https"}
            Add-WebConfiguration  -pspath 'MACHINE/WEBROOT/APPHOST' -filter '/system.webServer/rewrite/allowedServerVariables' -atIndex 0 -value @{name="ORIGINAL_URL";value="{HTTP_HOST}"}
            #Create rewrite rules
            $site = "IIS:\Sites\$websiteName"
            #Add inbound rule
            $filterRoot = "/system.webserver/rewrite/rules/rule[@name='ReverseProxyInboundRule1']"
            Add-WebConfigurationProperty -pspath $site -filter '/system.webserver/rewrite/rules' -name "." -value @{name='ReverseProxyInboundRule1'; patternSyntax='Regular Expresessions'; stopProcessing='True'} 
            Set-WebConfigurationProperty -pspath $site -filter "$filterRoot/match" -name "url" -value "(.*)" 
            Set-WebConfigurationProperty -pspath $site -filter "$filterRoot/action" -name "type" -value "Rewrite"
            Set-WebConfigurationProperty -pspath $site -filter "$filterRoot/action" -name "url" -value "http://localhost:9000/{R:1}"
            Add-WebConfiguration  -pspath $site -filter "$filterRoot/serverVariables" -atIndex 0 -value @{name="X_FORWARDED_PROTO";value="https"}
            Add-WebConfiguration  -pspath $site -filter "$filterRoot/serverVariables" -atIndex 0 -value @{name="ORIGINAL_URL";value="{HTTP_HOST}"}
            #Add outbound rule
            $filterRoot = "/system.webserver/rewrite/outboundRules/rule[@name='ReverseProxyOutboundRule1']"
            Add-WebConfigurationProperty -pspath $site -filter '/system.webserver/rewrite/outboundRules' -name "." -value @{name='ReverseProxyOutboundRule1'; patternSyntax='Regular Expresessions'; stopProcessing='True'; preCondition='IsRedirection'} 
            Set-WebConfigurationProperty -pspath $site -filter "$filterRoot/match" -name "filterByTags" -value "A, Form, Img" 
            Set-WebConfigurationProperty -pspath $site -filter "$filterRoot/match" -name "serverVariable" -value "RESPONSE_LOCATION" 
            Set-WebConfigurationProperty -pspath $site -filter "$filterRoot/match" -name "pattern" -value "^http://[^/]+/(.*)" 
            Set-WebConfigurationProperty -pspath $site -filter "$filterRoot/action" -name "type" -value "Rewrite"
            Set-WebConfigurationProperty -pspath $site -filter "$filterRoot/action" -name "value" -value "https://$serverName/{R:1}"
            #Add preConditions
            Add-WebConfigurationProperty -pspath $site -filter '/system.webserver/rewrite/outboundRules/preConditions' -name "." -value @{name='IsRedirection'}
            Add-WebConfigurationProperty -pspath $site -filter '/system.webserver/rewrite/outboundRules/preConditions' -name "." -value @{name='ResponseIsHtml1'}
            Add-WebConfigurationProperty -pspath $site -filter "system.webServer/rewrite/outboundRules/preConditions/preCondition[@name='IsRedirection']" -name "." -value @{input='{RESPONSE_STATUS}';pattern='3\d\d'}
            Add-WebConfigurationProperty -pspath $site -filter "system.webServer/rewrite/outboundRules/preConditions/preCondition[@name='ResponseIsHtml1']" -name "." -value @{input='{RESPONSE_CONTENT_TYPE}';pattern='^text/html'}
        }
}
