AGREEMENT_URL="https://management.azure.com/subscriptions/$SUBSCRIPTION_ID/providers/Microsoft.Marketplace/offerTypes/microsoft-container/publishers/$PUBLISHER/offers/$OFFER/plans/$PLAN/agreements/current"
CONFIG_URL="https://management.azure.com/subscriptions/$SUBSCRIPTION_ID/providers/Microsoft.Marketplace/offerTypes/microsoft-container/publishers/$PUBLISHER/offers/$OFFER/plans/$PLAN/configs/config$CONFIG_GUID"
IMPORT_URL="https://management.azure.com/subscriptions/$SUBSCRIPTION_ID/providers/Microsoft.Marketplace/offerTypes/microsoft-container/publishers/$PUBLISHER/offers/$OFFER/plans/$PLAN/configs/config$CONFIG_GUID/importImage"

az rest \
  --uri $AGREEMENT_URL \
  --method get \
  --output-file agreement.json \
&& az rest \
  --uri $AGREEMENT_URL \
  --method put \
  --body @agreement.json \
&& az rest \
  --uri $CONFIG_URL \
  --method put \
  --body "{\"targetAcr\":\"$ACR_TARGET\",\"autoUpdate\":$ACR_AUTO_UPDATE,\"resourceGroup\":\"$ACR_RG\",\"tagOrDigest\":\"$ACR_TAG\"}" \
&& az rest \
  --uri $IMPORT_URL \
  --method put \
  --body "{\"registryResourceId\":\"/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$ACR_RG/providers/Microsoft.ContainerRegistry/registries/$ACR_TARGET\"}"
