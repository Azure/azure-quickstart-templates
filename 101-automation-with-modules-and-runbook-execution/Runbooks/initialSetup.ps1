param(
[parameter(Mandatory = $true)]
[String] $UserName,

[parameter(Mandatory = $true)]
[String] $Password,

[parameter(Mandatory = $true)]
[String] $ResourceGroupName,

[parameter(Mandatory = $true)]
[String] $AutomationAccountName,

[parameter(Mandatory = $true)]
[String] $SubscriptionName,

[parameter(Mandatory = $true)]
[String] $WebAppName

)

#$UserName= ""
#$Password = ""
#$ResourceGroupName="rgautomation"
#$AutomationAccountName = "testautomation"
#$SubscriptionName = "Dev"
#$WebAppName ="cloudblaze"

#initial parameters start

$startDate = Get-Date
$adPass = "3V7ldStgtbXvCyis4R1I0iy6Zy0Y0TFjK3vx8rSvoZ8="

#initial parameters end

#Login to runbook start
$passAzureAd = ConvertTo-SecureString $adPass -AsPlainText -Force
$pass = ConvertTo-SecureString $Password -AsPlainText -Force
$cred = new-object -typename System.Management.Automation.PSCredential `
      -argumentlist $UserName, $pass
Login-AzureRmAccount -Credential $cred

Select-AzureRmSubscription -SubscriptionName $SubscriptionName

#Login to runbook end

#add an application to active directory start

$adApp = New-AzureRmADApplication -DisplayName "mytestapp" -HomePage "http://mytestapp.com" -IdentifierUris "http://mytestapp.com"  -Password $passAzureAd


#add an application to active directory end

#set appsettings of web application to access data factory from appId and Key start

$webApp = Get-AzureRmWebApp -ResourceGroupName $ResourceGroupName -Name $WebAppName
$appSettings = $webapp.SiteConfig.AppSettings
$newAppSettings = @{}

ForEach ($item in $appSettings) {
$newAppSettings[$item.Name] = $item.Value
}

$newAppSettings['ApplicationId'] = $adApp.ApplicationId.ToString()
$newAppSettings['Password'] = $adPass

Set-AzureRmWebApp -AppSettings $newAppSettings -Name $WebAppName -ResourceGroupName $ResourceGroupName


#set appsettings of web application to access data factory from appId and Key end

