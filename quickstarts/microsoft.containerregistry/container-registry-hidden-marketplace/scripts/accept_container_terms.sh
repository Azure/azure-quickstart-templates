AGREEMENT_URL="https://management.azure.com/subscriptions/$SUBSCRIPTION_ID/providers/Microsoft.Marketplace/offerTypes/microsoft-container/publishers/$PUBLISHER/offers/$OFFER/plans/$PLAN/agreements/current?api-version=2018-03-01-beta"

az rest \
  --uri $AGREEMENT_URL \
  --method get \
  --output-file agreement.json \
&& az rest \
  --uri $AGREEMENT_URL \
  --method put \
  --body @agreement.json
