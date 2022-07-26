SUBSCRIPTION_ID='edf507a2-6235-46c5-b560-fd463ba2e771'
PUBLISHER='microsoftcorporation1590077852919'
OFFER='horde-storage-container-preview'
PLAN='storage-container-test'
CONFIG_GUID='1dedfbed-4caa-42e8-bc0c-4e7d77707117'

AGREEMENT_URL="https://management.azure.com/subscriptions/$SUBSCRIPTION_ID/providers/Microsoft.Marketplace/offerTypes/microsoft-container/publishers/$PUBLISHER/offers/$OFFER/plans/$PLAN/agreements/current"
CONFIG_URL="https://management.azure.com/subscriptions/$SUBSCRIPTION_ID/providers/Microsoft.Marketplace/offerTypes/microsoft-container/publishers/$PUBLISHER/offers/$OFFER/plans/$PLAN/configs/config$CONFIG_GUID"
IMPORT_URL="https://management.azure.com/subscriptions/$SUBSCRIPTION_ID/providers/Microsoft.Marketplace/offerTypes/microsoft-container/publishers/$PUBLISHER/offers/$OFFER/plans/$PLAN/configs/config$CONFIG_GUID/importImage"

az rest --uri AGREEMENT_URL --method get \
  --output-file agreement.json
az rest --uri AGREEMENT_URL --method put \
  --body @agreement.json

az rest --uri $CONFIG_URL --method put \
  --body "{\"targetAcr\":\"$ACR_TARGET\",\"autoUpdate\":$ACR_AUTO_UPDATE,\"resourceGroup\":\"$ACR_RG\",\"tagOrDigest\":\"$ACR_TAG\"}"

az rest --uri IMPORT_URL --method put \
  --body "{\"registryResourceId\":\"/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$ACR_RG/providers/Microsoft.ContainerRegistry/registries/$ACR_TARGET\"}"
