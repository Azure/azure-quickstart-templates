az extension add --source "$WHEEL_FILE_URL" -y 
az nf fabric provision -g "$RESOURCEGROUP" --resource-name "$FABRICNAME"

while :
do
  fabric=$(az nf fabric show -g "$RESOURCEGROUP" --resource-name "$FABRICNAME" --query "{state:operationalState}")
  status=$(echo "$fabric" | grep state | cut -d\" -f4)
  if [ "$status" = "Provisioned" ]; then
    echo $status
    exit
  fi
  if [ "$status" = "ErrorProvisioning" ]; then
    echo $status
    exit
  fi
  sleep 30s
  echo "end"
done