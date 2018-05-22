#!/bin/bash
ADD_ACR=$1
AQUA_PASSWORD=$2
AZURE_AD_ID=$3
AZURE_AD_PASSWORD=$4
AZURE_TENANT_ID=$5

if [ $ADD_ACR == "yes" ];then
    sleep 30
    #Validate all parameters are set
    echo "step start: validate input parameters"
    if [[ -z "$AQUA_PASSWORD" ]] || [[ -z "$AZURE_AD_ID" ]] || [[ -z "$AZURE_AD_PASSWORD" ]] || [[ -z "$AZURE_TENANT_ID" ]];then
        echo "Missing parameters: AQUA_PASSWORD=$AQUA_PASSWORD,AZURE_AD_ID=$AZURE_AD_ID,AZURE_AD_PASSWORD=$AZURE_AD_PASSWORD  ---- exiting"
        exit 1
    else
        echo "Parameter validation passed successfully"
    fi
    echo "step end: validate input parameters"

    #AZ login service-principal
    echo "step start: run microsoft/azure-cli container and login to SP"
    docker rm azure-cli -f
    docker run --name azure-cli -it -d microsoft/azure-cli 
    AZ_LOGIN=$(docker exec azure-cli sh -c "az login --service-principal -u $AZURE_AD_ID -p $AZURE_AD_PASSWORD --tenant $AZURE_TENANT_ID"  | jq -r '.[].state')
    if [ $AZ_LOGIN == "Enabled" ];then 
        echo "AZ login successful"
    else
        echo "AZ login failed,exiting"
        exit 1
    fi
    echo "step end: run microsoft/azure-cli container and login to SP"
    #LIST available ACRs
    echo "step start: list available ACRs"
    ACR_NAME=$(docker exec azure-cli sh -c "az acr list -o json | jq -r '.[] | select(.adminUserEnabled==true) | .name'")
    if [[ -z "$ACR_NAME" ]];then
        echo "No available ACRs found: ACR_NAME=$ACR_NAME. Exiting"
        exit 1
    else
        echo "Following ACRs will be added: $ACR_NAME"
    fi
    echo "step end: list available ACRs"
    #Get ACR details and add ACR to Aqua server
    echo "step start: Add ACRs"
    for ACR_NAME in ${ACR_NAME[@]};do
        lRG=$(docker exec azure-cli sh -c "az acr list -o json" | jq -r --arg ACR_NAME "$ACR_NAME" '.[] | select(.name==$ACR_NAME) | .resourceGroup')
        lLoginServer="https://${ACR_NAME}.azurecr.io"
        lACRPassword=$(docker exec azure-cli sh -c "az acr credential show --name $ACR_NAME --resource-group $lRG" | jq -r '.passwords[] | select(.name=="password") | .value')
        echo "Adding $ACR_NAME"
        ADD_ACR=$(curl -s --write-out %{http_code} --output /dev/null -H 'Content-Type: application/json' -u "administrator:$AQUA_PASSWORD" -X POST http://$(hostname -i):8080/api/v1/registries -d '{"name": "'$ACR_NAME'","type": "ACR","url": "'$lLoginServer'","username": "'$ACR_NAME'","password": "'$lACRPassword'","auto_pull": false}')
        if [ $ADD_ACR == "204" ];then
            echo "Add ACR $ACR_NAME successful with response code= $ADD_ACR"
        else
            echo "Add ACR $ACR_NAME failed with response code= $ADD_ACR"

        fi  
    done
    echo "step end: Add ACRs"
 else
    echo "ADD_ACR is set to $ADD_ACR, ACR's will not be added"
fi
