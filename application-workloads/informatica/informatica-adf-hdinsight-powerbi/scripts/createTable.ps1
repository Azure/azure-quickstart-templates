<#
    .DESCRIPTION
This file create a sql data warehouse and load data


    .NOTES
        AUTHOR: UD
        LASTEDIT: Apr 30, 2016
#>

workflow CreateTable
{
<#	 param (
    [Parameter(Mandatory=$true)]
    [string] 
    $Tdid,
    
    [Parameter(Mandatory=$true)]
    [string] 
    $accountName,
    
    [Parameter(Mandatory=$true)]
    [string] 
    $variableName,
    
    [Parameter(Mandatory=$true)]
    [string] 
    $ISVName,
    
    [Parameter(Mandatory=$true)]
    [string] 
    $credentialName,
    
    [Parameter(Mandatory=$true)]
    [string] 
    $resourceGroupName
    
    )
    #>
	# Login to account and choose subscription
	
	param(
		[Parameter(Mandatory=$true)]
    	[string] 
    	$credentialName,
		
		[Parameter(Mandatory=$true)]
    	[string] 
    	$ServerName,

        [Parameter(Mandatory=$true)]
        [string] 
        $DatabaseName, 

        [Parameter(Mandatory=$true)]
        [string] 
        $DBUsername,

        [Parameter(Mandatory=$true)]
        [string] 
        $DBPassword 
	)
 #    $CredentialAssetName = $credentialName
#	   $Cred = Get-AutomationPSCredential -Name $CredentialAssetName
#    Write-Output $Cred
	#Login-AzureRmAccount
#	if(!$Cred) {
 #       Throw "Could not find an Automation Credential Asset named '${CredentialAssetName}'. Make sure you have created one in this Automation Account."
 #   }
	#Add-AzureRmAccount -Credential $Cred
  #	Login-AzureRmAccount -Credential $Cred 
  #  $subscriptionList = Get-AzureRmSubscription
  #  Select-AzureRmSubscription -SubscriptionId "7eab3893-bd71-4690-84a5-47624df0b0e5"
  #  New-AzureRmResourceGroup -Name ADFTutorialResourceGroup  -Location "West US" 
     
    #  $DatabaseName1 = $DatabaseName  
	inlinescript
    {
      
	
    $ServerName1= $Using:ServerName   
    $DatabaseName1 = $Using:DatabaseName
	$DBUsername1 = 	$Using:DBUsername
	$DBPassword1 = $Using:DBPassword 
    
  <#  $ServerName1= "powerbi.database.windows.net"   
    $DatabaseName1 = "powerbidb"
	$DBUsername1 = 	"sysgain"
	$DBPassword1 = "Sysga1n987!" #>
	
	Write-Output $ServerName1
	Write-Output $DatabaseName1
    Write-Output $DBUsername1
    Write-Output $DBPassword1
    $MasterDatabaseConnection = New-Object System.Data.SqlClient.SqlConnection
    $MasterDatabaseConnection.ConnectionString = "Server = $ServerName1; Database = $DatabaseName1; User ID = $DBUsername1; Password = $DBPassword1;"
    $MasterDatabaseConnection.Open();
    
    Write-Output "connection successful-----" 
    
    $MasterDatabaseCommand = New-Object System.Data.SqlClient.SqlCommand
    $MasterDatabaseCommand.Connection = $MasterDatabaseConnection
    $MasterDatabaseCommand.CommandText = 
    "
        CREATE TABLE dbo.bi9
        (
                ProductID_MD_PD     	varchar(500),
                CustomerID_MD_PD    	varchar(500),
                Temperature_MD_PD   	varchar(500),
                RPM_MD_PD	    		varchar(500),
                SoundDB_MD_PD	    	varchar(500),
                TempInd                 varchar(500),
                RPMInd                  varchar(500),
                SoundInd                varchar(500),
                Date_MD_PD          	varchar(500),
                Id_PD               	varchar(500),
                Name_PD             	varchar(500),
                ProductCode_PD      	varchar(500),
                Description_PD      	varchar(500),
                IsActive_PD  		    varchar(500),
                CreatedDate_PD     		varchar(500),
                CreatedById_PD     		varchar(500),
                LastModifiedDate_PD 	varchar(500),
                LastModifiedById_PD  	varchar(500),
                SystemModstamp_PD    	varchar(500),
                Family_PD             	varchar(500) ,
                IsDeleted_PD		    varchar(500),
                LastViewedDate_PD		varchar(500),
                LastReferencedDate_PD	varchar(500),
                Id                      varchar(500),
                IsDeleted			varchar(500),
                MasterRecordId		varchar(500),
                Name			varchar(500),
                Type			varchar(500),
                ParentId			varchar(500),
                BillingStreet		varchar(500),
                BillingCity			varchar(500),
                BillingState		varchar(500),
                BillingPostalCode		varchar(500),
                BillingCountry		varchar(500),
                BillingLatitude		varchar(500),
                BillingLongitude		varchar(500),
                ShippingStreet		varchar(500),
                ShippingCity		varchar(500),
                ShippingState		varchar(500),
                ShippingPostalCode		varchar(500),
                ShippingCountry		varchar(500),
                ShippingLatitude		varchar(500),
                ShippingLongitude		varchar(500),
                Phone			varchar(500),
                Fax				varchar(500),
                AccountNumber		varchar(500),
                Website			varchar(500),
                PhotoUrl			varchar(500),
                Sic				varchar(500),
                Industry			varchar(500),
                AnnualRevenue		varchar(500),
                NumberOfEmployees		varchar(500),
                Ownership			varchar(500),
                TickerSymbol		varchar(500),
                Description			varchar(500),
                Rating			varchar(500),
                Site			varchar(500),
                OwnerId			varchar(500),
                CreatedDate			varchar(500),
                CreatedById			varchar(500),
                LastModifiedDate		varchar(500),
                LastModifiedById		varchar(500),
                SystemModstamp		varchar(500),
                LastActivityDate		varchar(500),
                LastViewedDate		varchar(500),
                LastReferencedDate		varchar(500),
                Jigsaw			varchar(500),
                JigsawCompanyId		varchar(500),
                CleanStatus			varchar(500),
                AccountSource		varchar(500),
                DunsNumber			varchar(500),
                Tradestyle			varchar(500),
                NaicsCode			varchar(500),
                NaicsDesc			varchar(500),
                YearStarted			varchar(500),
                SicDesc			varchar(500),
                DandbCompanyId		varchar(500),
                CustomerPriority__c     	varchar(500),
                SLA__c			varchar(500),
                Active__c			varchar(500),
                NumberofLocations__c    	varchar(500),
                UpsellOpportunity__c    	varchar(500),
            SLASerialNumber__c      	varchar(500),
            SLAExpirationDate__c        varchar(500)
        )
        
       
    "
       # CREATE CLUSTERED INDEX IX_emp_ID ON dbo.emp (ID); 
       Write-Output "command successful-----"  
      # $MasterDbResult = $MasterDatabaseCommand.ExecuteReader()
      $MasterDatabaseCommand.ExecuteReader()
       Write-Output "command executed-----" 
     #  Write-Output $MasterDbResult
        $MasterDatabaseConnection.Close()  
        Write-Output "connection closed-----"       
    }
	
    #[string] $UserSqlQuery= $("SELECT * FROM [dbo].[User]")
   
   # Write-Output $subscriptionList
	#Select-AzureRmSubscription -SubscriptionId "7eab3893-bd71-4690-84a5-47624df0b0e5"
		
	#Pause the data warehouse
	#$database = Get-AzureRmSqlDatabase –ResourceGroupName "powerbitestdbrg" –ServerName "poerbitestbd" –DatabaseName "powerbitestdb"
	#$resultDatabase = $database | Suspend-AzureRmSqlDatabase
	#Write-Output $resultDatabase
    
    # New-AzureRmSqlDatabase -RequestedServiceObjectiveName "DW100" -DatabaseName "mynewsqldw" -ServerName "poerbitestbd" -ResourceGroupName "powerbitestdbrg" -Edition "DataWarehouse"


<#	
    #The name of the Automation Credential Asset this runbook will use to authenticate to Azure.
    $CredentialAssetName = $credentialName

    #Get the credential with the above name from the Automation Asset store
    $Cred = Get-AutomationPSCredential -Name $CredentialAssetName
    if(!$Cred) {
        Throw "Could not find an Automation Credential Asset named '${CredentialAssetName}'. Make sure you have created one in this Automation Account."
    }

    #Connect to your Azure Account
    #Add-AzureAccount -Credential $Cred
    Add-AzureRmAccount -Credential $Cred
	
	

    $Account1 = $accountName
 #$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
#$headers.Add("x-api-key", 'cmwPU5D5T2aJWaGjtVlon7VqSghAkl6C1oOfrhxB')
	
	$headers = @{
    'x-api-key'= 'cmwPU5D5T2aJWaGjtVlon7VqSghAkl6C1oOfrhxB'
}
	
	
	$fnbody = @{
    testdriveid=$Tdid
}
$json = $fnbody | ConvertTo-Json
$invokeUrl = 'https://sxmguodehi.execute-api.us-west-2.amazonaws.com/prod/licenseManager/'+ $Tdid +'/reserveLicense'
$response = Invoke-RestMethod $invokeUrl -Method Put -Headers $headers -Body $json -ContentType 'application/json'
	
   # $blobURL ='https://fortinetkeys.blob.core.windows.net/licensefiles/arm_template-3.json.zip?st=2016-03-29T03%3A44%3A25Z&se=2016-03-29T07%3A04%3A25Z&sp=r&sv=2015-04-05&sr=b&sig=8qXrBQF0AWcXU6XXOwjCvQhiycy4mqvMmrZhYLdaW4k%3D'
    
	
	
	Write-Output "Current Values of the variables For ISV"
	Write-Output $ISVName
  Write-Output $response


	
	#Set-AutomationVariable –Name TDidVariable –Value $Tdid
	#Set-AutomationVariable –Name LicenseBlobUrl –Value 'http://yejdjtjtj'
	
	Set-AzureRmAutomationVariable `
		-AutomationAccountName $Account1 `
		-Encrypted $False `
		-Name $variableName `
		-ResourceGroupName $resourceGroupName `
		-Value $response.blobUrl


	$LicenseBlobURL = Get-AzureRmAutomationVariable `
		-AutomationAccountName $Account1 `
		-Name $variableName `
		-ResourceGroupName $resourceGroupName
	
	Write-Output "New Values of the variables"	

     Write-Output $LicenseBlobURL
  #>  
}
