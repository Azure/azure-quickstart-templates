CONFIG_URL="https://management.azure.com/subscriptions/$SUBSCRIPTION_ID/providers/Microsoft.Marketplace/offerTypes/microsoft-container/publishers/$PUBLISHER/offers/$OFFER/plans/$PLAN/configs/config$CONFIG_GUID?api-version=2018-03-01-beta"
IMPORT_URL="https://management.azure.com/subscriptions/$SUBSCRIPTION_ID/providers/Microsoft.Marketplace/offerTypes/microsoft-container/publishers/$PUBLISHER/offers/$OFFER/plans/$PLAN/configs/config$CONFIG_GUID/importImage?api-version=2018-03-01-beta"

az rest \
  --uri $CONFIG_URL \
  --method put \
  --body "{\"targetAcr\":\"$ACR_TARGET\",\"autoUpdate\":$ACR_AUTO_UPDATE,\"resourceGroup\":\"$ACR_RG\",\"tagOrDigest\":\"$ACR_TAG\"}" \
&& az rest \
  --uri $IMPORT_URL \
  --method put \
  --body "{\"registryResourceId\":\"/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$ACR_RG/providers/Microsoft.ContainerRegistry/registries/$ACR_TARGET\"}"
