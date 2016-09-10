cls
Set-Location ".\"

# ************************** HOW TO USE THIS SCRIPT ********************************

##### Why do you need this script?#######
## Refer article - https://azure.microsoft.com/en-us/documentation/articles/resource-group-authenticate-service-principal/ 

# STEPS TO MAKE THIS SCRIPT WORK FOR YOU
# 1) Ensure you pass the right subscription name. Parameter $subscriptionName
# 2) Run the ARM deployment and capture the Cloudwise App Service URL. 
# 3) When prompted, signin with a Service Admin user for the subscription
# 4) Usually that's all you have to do
#****************************************************************************




$subscriptionName =     ""
$cloudwiseAppServiceURL=""          # this is the Unique URL of the Cloudwise App Service deployed by the ARM script
$suffix =               "Avyan"     #-- Name of the company/deployment. This is used to create a unique website name in your organization

$appIdentifier =        ($cloudwiseAppServiceURL + "/avyanxx")
$passwordADApp =        "Password@123" 

$Web1SiteName =         ("cloudwise" + $suffix)
$displayName1 =         ("CloudWise - Azure Governance and Billing Portal (ver." + $suffix + ")")
$servicePrincipalPath=  (".\" + $subscriptionName + ".json" )



### 0. Validate Parameters.
#############################################################################################
if (($subscriptionName -eq "") -or ($cloudwiseAppServiceURL -eq ""))
{
    Write-Host "Please ensure parameters SubscriptionName and cloudwiseAppServiceURL are not empty" -foreground Red
    return
}


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
   
    $replyURLs = @($cloudwiseAppServiceURL, "http://localhost:62080")

    # Create Active Directory Application
    
    $identifierURI1 = $cloudwiseAppServiceURL
$azureAdApplication1 = New-AzureRmADApplication -DisplayName $displayName1 -HomePage $cloudwiseAppServiceURL -IdentifierUris $identifierURI1 -Password $passwordADApp -ReplyUrls $replyURLs

### 3. Create a service principal for the AD Application and add a Reader role to the principal
#############################################################################################

$principal = New-AzureRmADServicePrincipal -ApplicationId $azureAdApplication1.ApplicationId
Start-Sleep -s 30 # Wait till the ServicePrincipal is completely created. Usually takes 20+secs. Needed as Role assignment needs a fully deployed servicePrincipal


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
Write-Host ($u3 + ".onmicrosoft.com") -foreground Red –NoNewLine
Write-Host "- Please verify the domain with the management portal. For debugging purposes we have used the domain of the user signing in. You might have Custom / Organization domains" -foreground Yellow
Write-Host "Application Client ID: " -foreground Green –NoNewLine
Write-Host $azureAdApplication1.ApplicationId -foreground Red 
Write-Host "Application Client Password: " -foreground Green –NoNewLine
Write-Host $passwordADApp -foreground Red 
Write-Host "PostLogoutRedirectUri: " -foreground Green –NoNewLine
Write-Host $cloudwiseAppServiceURL -foreground Red 
Write-Host "TenantId: " -foreground Green –NoNewLine
Write-Host $tenantID -foreground Red 

Write-Host ("TODO - Update permissions for the AD Application  '") -foreground Yellow –NoNewLine
Write-Host $displayName1 -foreground Red –NoNewLine
Write-Host ("'. Cloudwise would atleast need 2 apps") -foreground Yellow
Write-Host ("`t 1) Windows Azure Active Directory ") -foreground Yellow
Write-Host ("`t 2) Windows Azure Service Management API ") -foreground Yellow
Write-Host ("see README.md for details") -foreground Yellow

