# Create the Azure AD application.
application=$(az ad app create --display-name $AzureADApplicationName)
applicationObjectId=$(jq -r '.id' <<< "$application")
applicationClientId=$(jq -r '.appId' <<< "$application")

# Create a service principal for the application.
servicePrincipal=$(az ad sp create --id $applicationObjectId)
servicePrincipalObjectId=$(jq -r '.id' <<< "$servicePrincipal")

# Save the important properties as deployment script outputs.
outputJson=$(jq -n \
                --arg applicationObjectId "$applicationObjectId" \
                --arg applicationClientId "$applicationClientId" \
                --arg servicePrincipalObjectId "$servicePrincipalObjectId" \
                '{applicationObjectId: $applicationObjectId, applicationClientId: $applicationClientId, servicePrincipalObjectId: $servicePrincipalObjectId}' )
echo $outputJson > $AZ_SCRIPTS_OUTPUT_PATH
