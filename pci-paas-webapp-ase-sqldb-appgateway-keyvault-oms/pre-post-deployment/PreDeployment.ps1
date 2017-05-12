Param(
    [string] [Parameter(Mandatory=$true)] $azureADDomainName,# Provide your azuure Domain Name
	[string] [Parameter(Mandatory=$true)] $subscriptionName, # Provide your Azure subscription
	[string] [Parameter(Mandatory=$true)] $suffix #This is used to create a unique website name in your organization. This could be your company name or business unit name
)

###
#Imp: This script needs to be run by Global AD Administrator (aka Company Administrator)
###
Write-Host ("Pre-Requisite: This script needs to be run by Global AD Administrator (aka Company Administrator)" ) -ForegroundColor Red

$SQLADAdminName = "sqladmin@$azureADDomainName"
$TestUserName = "user@$azureADDomainName"

Write-Host ("Step 1: Create Azure Active Directory users,  SQLAdmin = " + $SQLADAdminName + " and Test User=" + $TestUserName ) -ForegroundColor Gray

Connect-MsolService
$cloudwiseAppServiceURL = "http://localcloudneeti6i.$azureADDomainName"
$sqlADAdminObjectId = (Get-MsolUser -UserPrincipalName $SQLADAdminName -ErrorAction SilentlyContinue -ErrorVariable errorVariable).ObjectID
if ($sqlADAdminObjectId -eq $null)  
{    
    $sqlADAdminDetails = New-MsolUser -UserPrincipalName $SQLADAdminName -DisplayName "SQLADAdministrator PCI Samples" -FirstName "SQL AD Administrator" -LastName "PCI Samples"
	$sqlADAdminObjectId= $sqlADAdminDetails.ObjectID

	Add-MsolRoleMember -RoleName "Company Administrator" -RoleMemberObjectId $sqlADAdminObjectId
}
$testUserObjectId = (Get-MsolUser -UserPrincipalName $TestUserName -ErrorAction SilentlyContinue -ErrorVariable errorVariable).ObjectID
if ($testUserObjectId -eq $null)  
{    
    $testUserDetails = New-MsolUser -UserPrincipalName $TestUserName -DisplayName "Test User PCI Samples" -FirstName "Test User" -LastName "PCI Samples"
	$testUserObjectId= $testUserDetails.ObjectID
}

#------------------------------
Write-Host ("Step 2: Login to Azure AD and Azure. Please provide Global Administrator Credentials that has Owner/Contributor rights on the Azure Subscription ") -ForegroundColor Gray
Set-Location ".\"
$AzureADApplicationClientSecret =        "Password@123" 
$WebSiteName =         ("cloudwise" + $suffix)
$displayName =         ($suffix + "Azure PCI PAAS Sample")
# To login to Azure Resource Manager
	Try  
	{  
		Get-AzureRmContext -ErrorAction Continue  
	}  
	Catch [System.Management.Automation.PSInvalidOperationException]  
	{  
		 #Add-AzureRmAccount 
		Login-AzureRmAccount -SubscriptionName $subscriptionName
	} 

# To select a default subscription for your current session

$sub = Get-AzureRmSubscription –SubscriptionName $subscriptionName | Select-AzureRmSubscription 

### 2. Create Azure Active Directory apps in default directory
Write-Host ("Step 3: Create Azure Active Directory apps in default directory") -ForegroundColor Gray
    $u = (Get-AzureRmContext).Account
    $u1 = ($u -split '@')[0]
    $u2 = ($u -split '@')[1]
    $u3 = ($u2 -split '\.')[0]
    $defaultPrincipal = ($u1 + $u3 + ".onmicrosoft.com")
    # Get tenant ID
    $tenantID = (Get-AzureRmContext).Tenant.TenantId
    $homePageURL = ("http://" + $defaultPrincipal + "azurewebsites.net" + "/" + $Web1SiteName)
    $replyURLs = @( $cloudwiseAppServiceURL, "http://*.azurewebsites.net","http://localhost:62080", "http://localhost:3026/")
    # Create Active Directory Application
    $azureAdApplication = New-AzureRmADApplication -DisplayName $displayName -HomePage $cloudwiseAppServiceURL -IdentifierUris $cloudwiseAppServiceURL -Password $AzureADApplicationClientSecret -ReplyUrls $replyURLs
    Write-Host ("`tStep 3.1: Azure Active Directory apps creation successful. AppID is " + $azureAdApplication.ApplicationId) -ForegroundColor Gray

### 3. Create a service principal for the AD Application and add a Reader role to the principal

    Write-Host ("`tStep 3.2: Attempting to create Service Principal") -ForegroundColor Gray
    $principal = New-AzureRmADServicePrincipal -ApplicationId $azureAdApplication.ApplicationId
    Start-Sleep -s 30 # Wait till the ServicePrincipal is completely created. Usually takes 20+secs. Needed as Role assignment needs a fully deployed servicePrincipal
    Write-Host ("`tStep 3.3: Service Principal creation successful - " + $principal.DisplayName) -ForegroundColor Gray
    $scopedSubs = ("/subscriptions/" + $sub.Subscription)
    Write-Host ("`tStep 3.4: Attempting Reader Role assignment" ) -ForegroundColor Gray
    New-AzureRmRoleAssignment -RoleDefinitionName Reader -ServicePrincipalName $azureAdApplication.ApplicationId.Guid -Scope $scopedSubs
    Write-Host ("`tStep 3.5: Reader Role assignment successful" ) -ForegroundColor Gray


### 4. Print out the required project settings parameters
#############################################################################################
$AzureADApplicationObjectID = (Get-AzureRmADServicePrincipal -ServicePrincipalName $azureAdApplication.ApplicationId).Id

Write-Host -Prompt "Start copy all the values from below here." -ForegroundColor Yellow

Write-Host ("Parameters to be used in the registration / configuration.") -foreground Green
Write-Host "Azure AD Application Client ID: " -foreground Green –NoNewLine
Write-Host $azureAdApplication.ApplicationId -foreground Red 
Write-Host "Azure AD Application Client Secret: " -foreground Green –NoNewLine
Write-Host $AzureADApplicationClientSecret -foreground Red 
Write-Host "Azure AD Application Object ID: " -foreground Green –NoNewLine
Write-Host $AzureADApplicationObjectID -foreground Red 
Write-Host "SQL AD Admin Name: " -foreground Green –NoNewLine
Write-Host $SQLADAdminName -foreground Red 
Write-Host "SQL AD Admin Password:(If user already exists then we have to get password manually) " -foreground Green –NoNewLine
Write-Host $sqlADAdminDetails.password -foreground Red 
Write-Host "Azure AD User Object Id: " -foreground Green –NoNewLine
Write-Host $testUserObjectId -foreground Red 


Write-Host "PostLogoutRedirectUri: " -foreground Green –NoNewLine
Write-Host $cloudwiseAppServiceURL -foreground Red 
Write-Host "TenantId: " -foreground Green –NoNewLine
Write-Host $tenantID -foreground Red 
Write-Host "SubscriptionID: " -foreground Green –NoNewLine
Write-Host $sub.Subscription -foreground Red 


Write-Host ("TODO - Update permissions for the AD Application  '") -foreground Yellow –NoNewLine
Write-Host $displayName1 -foreground Red –NoNewLine
Write-Host ("'. Cloudwise would atleast need 2 apps") -foreground Yellow
Write-Host ("`t 1) Windows Azure Active Directory ") -foreground Yellow
Write-Host ("`t 2) Windows Azure Service Management API ") -foreground Yellow
Write-Host ("`t 3) Key Vault ") -foreground Yellow
Write-Host ("`t 4) Microsoft Graph API ") -foreground Yellow
Write-Host ("see README.md for details") -foreground Yellow

Write-Host -Prompt "End copy all the values from below here." -ForegroundColor Yellow

Read-Host -Prompt "The script completed execution. Press any key to exit"