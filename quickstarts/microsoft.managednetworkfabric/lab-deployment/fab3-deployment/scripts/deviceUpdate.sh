az extension add --source "$WHEEL_FILE_URL" -y
az nf device update --resource-group "$RESOURCEGROUP" --location "$LOCATION" --resource-name "$DEVICENAME" --serial-number "$SERIALNUMBER"