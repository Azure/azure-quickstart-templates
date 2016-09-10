cls
Set-Location ".\"

# ************************** HOW TO USE THIS SCRIPT ********************************

##### Why do you need this script?#######
## Refer article - https://azure.microsoft.com/en-us/documentation/articles/resource-group-authenticate-service-principal/ 

# STEPS TO MAKE THIS SCRIPT WORK FOR YOU
# 1) Ensure you pass the right subscription name. Parameter $subscriptionName
# 2) When prompted, signin with a Service Admin user for the subscription
# 3) Usually that's all you have to do
#****************************************************************************


### 0. Ensure right Parameters, specially the $subscriptionName
#############################################################################################



$subscriptionName =     "<your subscription name"
$homepage =             "https://www.testapp2.org"
$appIdentifier =        ($homepage + "/avyanxx")
$passwordADApp =        "Password@123" 
$suffix =               "Avyan2"     #-- Name of the company/deployment. This is used to create a unique website name in your organization
$Web1SiteName =         ("cloudwise" + $suffix)
$displayName1 =         ("CloudWise - Azure Governance and Billing Portal -v" + $suffix)
$servicePrincipalPath=  (".\" + $subscriptionName + ".json" )

### 1. Login to Azure Resource Manager and save the profile locally to avoid relogins (used primarily for debugging purposes)
#############################################################################################


# To login to Azure Resource Manager
if(![System.IO.File]::Exists($servicePrincipalPath)){
    # file with path $path doesn't exist

    Add-AzureRmAccount
    
    Save-AzureRmProfile -Path $servicePrincipalPath
}

Select-AzureRmProfile -Path $servicePrincipalPath


# To select a default subscription for your current session
#Get-AzureRmSubscription –SubscriptionName “Cloudly Dev (Visual Studio Ultimate)” | Select-AzureRmSubscription

$sub = Get-AzureRmSubscription –SubscriptionName $subscriptionName | Select-AzureRmSubscription



### 2. Create Azure Active Directory apps in default directory
#############################################################################################
    $u = (Get-AzureRmContext).Account
    $u1 = ($u -split '@')[0]
    $u2 = ($u -split '@')[1]
    $u3 = ($u2 -split '\.')[0]
    $defaultPrincipal = ($u1 + $u3 + ".onmicrosoft.com")
    #$defaultPrincipal = ("gururajAD" + ".onmicrosoft.com")

    # Get tenant ID
    $tenantID = (Get-AzureRmContext).Tenant.TenantId
    # This value is manually set in AD Application settings. Get that value from the portal, if not set you can set it as your HomePageURL
    $PostLogoutRedirectUri1 = $homePageURL1

    $replyURLs = @($PostLogoutRedirectUri1, "http://localhost:62080")

    # Create Active Directory Application
    $homePageURL1 = ("http://" + $Web1SiteName + ".azurewebsites.net")
    $identifierURI1 = ("http://" + $defaultPrincipal + "/" + $Web1SiteName)
$azureAdApplication1 = New-AzureRmADApplication -DisplayName $displayName1 -HomePage $homePageURL1 -IdentifierUris $identifierURI1 -Password $passwordADApp -ReplyUrls $replyURLs

Start-Sleep -s 30 # Wait till the AP App is completely created. Usually takes 10-20secs. Needed as Role assignment needs a fully deployed AD App

### 3. Create a service principal for the AD Application and add a Reader role to the principal
#############################################################################################

$principal = New-AzureRmADServicePrincipal -ApplicationId $azureAdApplication1.ApplicationId

    Select-AzureRmSubscription -SubscriptionName $subscriptionName
    $scopedSubs = ("/subscriptions/" + $sub.Subscription)

New-AzureRmRoleAssignment -RoleDefinitionName Reader -ServicePrincipalName $azureAdApplication1.ApplicationId.Guid -Scope $scopedSubs


### 4. Print out the required project settings parameters
#############################################################################################

Write-Host ("AD Application Details:") -foreground Green
$azureAdApplication1


Write-Host ("Parameters to be used in the registration / configuration.") -foreground Green

Write-Host "SubscriptionID: " -foreground Green –NoNewLine
Write-Host $sub.Subscription -foreground Red 
Write-Host "Domain: " -foreground Green –NoNewLine
Write-Host ($u3 + ".onmicrosoft.com") -foreground Red 
Write-Host "ida:ClientID: " -foreground Green –NoNewLine
Write-Host $azureAdApplication1.ApplicationId -foreground Red 
Write-Host "ida:Password: " -foreground Green –NoNewLine
Write-Host $passwordADApp -foreground Red 
Write-Host "ida:PostLogoutRedirectUri: " -foreground Green –NoNewLine
Write-Host $PostLogoutRedirectUri1 -foreground Red 
Write-Host "ida:TenantId: " -foreground Green –NoNewLine
Write-Host $tenantID -foreground Red 

Write-Host ("- Update '") -foreground Yellow –NoNewLine
Write-Host $displayName1 -foreground Red –NoNewLine
Write-Host ("' Active Directory Application (AD App) settings! (see README.md)") -foreground Yellow

Write-Host ("- On the configuration page of the AD App, find the section name 'Reply URL' and add the URL of the Website deployed via the ARM script ") -foreground Yellow –NoNewLine
Write-Host (" with http and https. Also add http://localhost:62080 in case debugging locally.") -foreground Yellow

