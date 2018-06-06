#!/bin/sh
## Script to Setup NetApp OnCommand Cloud Manager and Deploy Working Environment NetApp ONTAP Cloud on Azure ##

## Arguments : To be passed by Azure Custom Script Extension
region=${1}
otcName=${2}
adminEmail=${3}
encodedadminPassword=${4} 
encodedOTCPassword=${5} 
subscriptionId=${6}
azureTenantId=${7}
applicationId=${8}
applicationKey=${9}
vnetID=${10}
cidr=${11}
subnetID=${12}
nsgID=${13}
licenseType=${14}
instanceType=${15}
storageType=${16}
QuickstartNameTagValue=${17}
QuickstartProviderTagValue=${18}
netappOntapVersion=${19}

adminPassword=`echo $encodedadminPassword| base64 --decode` 
OTCPassword=`echo $encodedOTCPassword| base64 --decode` 


##Variable Values for Setting up OnCommand Manager 
tenantName="azurenetappqs_tenant"
roleID="Role-1"
siteName="AzureQS"
siteCompany="AzureQS"
autoVsaCapacityManagement=true
autoUpgrade=false
## Variable Values for Deploying Working Environment on Azure 
unit="GB"


#Outputing the variables
touch /tmp/inputlog.txt
echo region $region >> /tmp/inputlog.txt
echo otcName $otcName >> /tmp/inputlog.txt
echo adminEmail $adminEmail >> /tmp/inputlog.txt
echo subscriptionId $subscriptionId >> /tmp/inputlog.txt
echo azureTenantId $azureTenantId >> /tmp/inputlog.txt
echo applicationId $applicationId >> /tmp/inputlog.txt
echo vnetID $vnetID >> /tmp/inputlog.txt
echo cidr $cidr >> /tmp/inputlog.txt
echo subnetID $subnetID >> /tmp/inputlog.txt
echo nsgID $nsgID >> /tmp/inputlog.txt
echo licenseType $licenseType >> /tmp/inputlog.txt
echo instanceType $instanceType >> /tmp/inputlog.txt
echo storageType $storageType >> /tmp/inputlog.txt
echo QuickstartNameTagValue $QuickstartNameTagValue >> /tmp/inputlog.txt
echo QuickstartProviderTagValue $QuickstartProviderTagValue >> /tmp/inputlog.txt

## Downloading jQuery 
sudo wget -O /usr/bin/jq http://stedolan.github.io/jq/download/linux64/jq
sleep 5
sudo chmod +x /usr/bin/jq

## Setup NetApp OnCommand Cloud Manager
curl http://localhost/occm/api/occm/setup/init -X POST --header 'Content-Type:application/json' --header 'Referer:AzureQS1' --data '{ "tenantRequest": { "name": "'${tenantName}'", "description": "", "costCenter": "", "nssKeys": {} }, "proxyUrl": { "uri": "" }, "userRequest":{  "email": "'${adminEmail}'","lastName": "user", "firstName":"admin","roleId": "'${roleID}'","password": "'${adminPassword}'", "ldap": "false", "azureCredentials": { "subscriptionId": "'${subscriptionId}'", "tenantId": "'${azureTenantId}'", "applicationId": "'${applicationId}'", "applicationKey": "'${applicationKey}'" }  }, "site": "'${siteName}'", "company": "'${siteCompany}'", "autoVsaCapacityManagement": "'${autoVsaCapacityManagement}'",   "autoUpgrade": "'${autoUpgrade}'" }}'
sleep 40

until sudo wget http://localhost/occmui > /dev/null 2>&1; do sudo wget http://localhost > /dev/null 2>&1 ; done
sleep 60

## Authenticate to NetApp OnCommand CloudManager
curl http://localhost/occm/api/auth/login --header 'Content-Type:application/json' --header 'Referer:AzureQS1' --data '{"email":"'${adminEmail}'","password":"'${adminPassword}'"}' --cookie-jar cookies.txt
sleep 5

## Getting the NetApp Tenant ID, to deploy the ONTAP Cloud
tenantId=""
until [ "$tenantId" != "" ]; do
curl http://localhost/occm/api/auth/login --header 'Content-Type:application/json' --header 'Referer:AzureQS1' --data '{"email":"'${adminEmail}'","password":"'${adminPassword}'"}' --cookie-jar cookies.txt 
tenantId=`sudo curl http://localhost/occm/api/tenants -X GET --header 'Content-Type:application/json' --header 'Referer:AzureQS' --cookie cookies.txt | jq -r .[0].publicId`
sleep 10
done

## Create a ONTAP Cloud working environment on Azure
curl http://localhost/occm/api/azure/vsa/working-environments -X POST  --header 'Content-Type:application/json' --cookie cookies.txt --data '{ "name": "'${otcName}'", "svmPassword": "'${OTCPassword}'",  "vnetId": "'${vnetID}'",   "cidr": "'${cidr}'", "vsaMetadata": { "ontapVersion": "'${netappOntapVersion}'", "licenseType": "'${licenseType}'", "instanceType": "'${instanceType}'" },"tenantId": "'${tenantId}'","region": "'${region}'", "subnetId":"'${subnetID}'", "dataEncryptionType":"NONE", "skipSnapshots": "false", "diskSize": { "size": "1","unit": "TB" }, "storageType": "'${storageType}'", "azureTags": [ { "tagKey" : "provider", "tagValue" : "'${QuickstartProviderTagValue}'"}, { "tagKey" : "quickstartName", "tagValue" : "'${QuickstartNameTagValue}'"}],"writingSpeedState": "NORMAL" }' > /tmp/createnetappotc.txt

OtcPublicId=`cat /tmp/createnetappotc.txt | jq -r .publicId`
if [ ${OtcPublicId} = null ] ; then
  message=`cat /tmp/createnetappotc.txt| jq -r .message`
  echo "OCCM setup failed: $message" > /tmp/occmError.txt
  exit 1
fi
sleep 2

## Getting the NetApp Ontap Cloud Cluster Properties

curl 'http://localhost/occm/api/azure/vsa/working-environments/'${OtcPublicId}'?fields=status' -X GET --header 'Content-Type:application/json' --header 'Referer:AzureQS' --cookie cookies.txt > /tmp/envdetails.json
otcstatus=`cat /tmp/envdetails.json | jq -r .status.status`

check_deploymentstatus()
{
curl 'http://localhost/occm/api/azure/vsa/working-environments/'${OtcPublicId}'?fields=status' -X GET --header 'Content-Type:application/json' --header 'Referer:AzureQS' --cookie cookies.txt > /tmp/envdetails.json
otcstatus=`cat /tmp/envdetails.json | jq -r .status.status`
}

until  [ ${otcstatus} = ON ] 
do
  message="OTC not deployed yet, Checking again in 60 seconds"
  echo  ${message}
  sleep 60
  check_deploymentstatus
done
sleep 5

curl 'http://localhost/occm/api/azure/vsa/working-environments/'${OtcPublicId}'?fields=ontapClusterProperties' -X GET --header 'Content-Type:application/json' --header 'Referer:AzureQS' --cookie cookies.txt > /tmp/ontapClusterProperties.json

## grab the Cluster managment LIF IP address and save in /tmp for refrence
clusterLif=`curl 'http://localhost/occm/api/azure/vsa/working-environments/'${OtcPublicId}'?fields=ontapClusterProperties' -X GET --header 'Content-Type:application/json' --header 'Referer:AzureQS' --cookie cookies.txt |jq -r .ontapClusterProperties.nodes[].lifs[] |grep "Cluster Management" -a2|head -1|cut -f4 -d '"'`
echo "${clusterLif}" > /tmp/clusterLif.txt
## grab the iSCSI data LIF IP address
dataLif=`curl 'http://localhost/occm/api/azure/vsa/working-environments/'${OtcPublicId}'?fields=ontapClusterProperties' -X GET --header 'Content-Type:application/json' --header 'Referer:AzureQS' --cookie cookies.txt |jq -r .ontapClusterProperties.nodes[].lifs[] |grep iscsi -a4|head -1|cut -f4 -d '"'`
echo "${dataLif}" > /tmp/iscsiLif.txt
## grab the NFS and CIFS data LIF IP address
dataLif2=`curl 'http://localhost/occm/api/azure/vsa/working-environments/'${OtcPublicId}'?fields=ontapClusterProperties' -X GET --header 'Content-Type:application/json' --header 'Referer:AzureQS' --cookie cookies.txt |jq -r .ontapClusterProperties.nodes[].lifs[] |grep nfs -a4|head -1|cut -f4 -d '"'`
echo "${dataLif2}" > /tmp/nasLif.txt

# Cluster Ip Addresses Exported in tmp Files
