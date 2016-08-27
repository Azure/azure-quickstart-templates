#!/bin/bash

usage() 
{ 
    echo "Usage: $0 -p <resourceGroupName> -q <deploymentName> -l <resourceGroupLocation> -s <scriptstorageaccount> " 1>&2; exit 1; 
}

stagecustomscript()
{
    azure storage account show $scriptstorageaccount -g $resourceGroupName
    if [ $? -eq 1 ]
    then
        echo Creating storate account $scriptstorageaccount in RG $resourceGroupName in $resourceGroupLocation
        azure storage account create $scriptstorageaccount -g $resourceGroupName -l $resourceGroupLocation --kind Storage --sku-name LRS
    fi

    key=$(azure storage account keys list $scriptstorageaccount -g $resourceGroupName | grep -o 'key1\s*[^ ]*' | cut -d' ' -f3)
    echo Uploading custom script to $scriptstorageaccount

    containername='scripts'

    azure storage container show -a $scriptstorageaccount -k $key $containername
    if [ $? -eq 1 ]
    then
        echo Creating Container $containername 
        azure storage container create --container $containername -p Blob -a $scriptstorageaccount -k $key
    fi 
    azure storage blob upload -f ./configuressl.sh -a $scriptstorageaccount -k $key --container $containername -q
}

# Initialize parameters specified from command line
while getopts ":p:q:l:s:" o; do
	case "${o}" in
		t)
			echo "in case t"
			subscriptionId=${OPTARG}
			;;
		p)
			resourceGroupName=${OPTARG}
			;;
		q)
			deploymentName=${OPTARG}
			;;
		l)
			resourceGroupLocation=${OPTARG}
			;;
        s) scriptstorageaccount=${OPTARG}
            ;;
		esac
done
shift $((OPTIND-1))

#Prompt for parameters is some required parameters are missing
if [ -z "$resourceGroupName" ]; then
	echo "ResourceGroupName:"
	read resourceGroupName
fi

if [ -z "$deploymentName" ]; then
	echo "DeploymentName:"
	read deploymentName
fi

if [ -z "$resourceGroupLocation" ]; then
	echo "Enter a location below to create a new resource group else skip this"
	echo "ResourceGroupLocation:"
	read resourceGroupLocation
fi

if [ -z "$scriptstorageaccount" ]; then
	echo "Enter the name of the storage account below to store the custom script"
	echo "scriptstorageaccount:"
	read scriptstorageaccount
fi

#templateFile Path - template file to be used
templateFilePath="azuredeploy.json"

#parameter file path
parametersFilePath="azuredeploy.parameters.json"

if  [ -z "$resourceGroupName" ] || [ -z "$deploymentName" ] || [ -z "$scriptstorageaccount" ]; then
	echo "Either one of subscriptionId, resourceGroupName, deploymentName, scriptstorageaccount is empty"
	usage
fi

#login to azure using your credentials
#azure login

#set the default subscription id
#azure account set $subscriptionId

#switch the mode to azure resource manager
azure config mode arm

#Check for existing resource group
if [ -z "$resourceGroupLocation" ] ; 
then
	echo "Using existing resource group..."
else 
	echo "Creating a new resource group..." 
	azure group create --name $resourceGroupName --location $resourceGroupLocation
fi



stagecustomscript

sed -i 's/REPLACE_SCRIPTSTORAGERG/'$resourceGroupName'/g' ./azuredeploy.parameters.json
sed -i 's/REPLACE_SCRIPTSTORAGE/'$scriptstorageaccount'/g' ./azuredeploy.parameters.json
sed -i 's/REPLACE_LOCATION/'$resourceGroupLocation'/g' ./azuredeploy.parameters.json

#Start deployment
echo "Starting deployment..."
azure group deployment create --name $deploymentName --resource-group $resourceGroupName --template-file $templateFilePath --parameters-file $parametersFilePath