# Steps to update your template for the breaking change in API

1. Replace the 2014-12-01-preview API version for resources with 2015-05-01-preview

2. Use the imageReference section to refer to your image and add define the osDisk property to the storageProfile. Here's what the new storageProfile looks like

```json
"storageProfile": {
    "imageReference": {
        "publisher": "[parameters('imagePublisher')]",
        "offer": "[parameters('imageOffer')]",
        "sku" : "[parameters('imageSKU')]",
        "version":"latest"
    },
    "osDisk" : {
        "name": "osdisk",
        "vhd": {
           "uri": "[concat('http://',parameters('newStorageAccountName'),'.blob.core.windows.net/vhds/','osdisk.vhd')]"
        },
        "caching": "ReadWrite",
        "createOption": "FromImage"
    }
}
```

3. Some common values for publisher, offer, sku for images are

| CurrentImageID                                                                                | Publisher              | Offer                     | Sku                           | Version         |
|-----------------------------------------------------------------------------------------------|------------------------|---------------------------|-------------------------------|-----------------|
| a699494373c04fc0bc8f2bb1389d6106__Windows-Server-2012-R2-201503.01-en.us-127GB.vhd            | MicrosoftWindowsServer | WindowsServer             | 2012-R2-Datacenter            | 4.0.201503      |
| 0b11de9248dd4d87b18621318e037d37__RightImage-CentOS-7.0-x64-v14.2                             | RightScaleLinux        | RightImage-CentOS         | 7                             | 14.2.0          |
| 0b11de9248dd4d87b18621318e037d37__RightImage-Ubuntu-14.04-x64-v14.2.1                         | RightScaleLinux        | RightImage-Ubuntu         | 14.04                         | 14.2.1          |
| 2b171e93f07c4903bcad35bda10acf22__CoreOS-Stable-633.1.0                                       | CoreOS                 | CoreOS                    | Stable                        | 633.1.0         |
| b39f27a8b8c64d52b05eac6a62ebad85__Ubuntu-14_04_2_LTS-amd64-server-20150309-en-us-30GB         | Canonical              | UbuntuServer              | 14.04.2-LTS                   | 14.04.201503090 |
| b39f27a8b8c64d52b05eac6a62ebad85__Ubuntu-15_04-amd64-server-20150422-en-us-30GB               | Canonical              | UbuntuServer              | 15.04                         | 15.04.201504220 |
| c6e0f177abd8496e934234bd27f46c5d__SharePoint-2013-Trial-1-20-2015                             | MicrosoftSharePoint    | MicrosoftSharePointServer | 2013                          | 1.0.0           |
| fb83b3509582419d99629ce476bcb5c8__SQL-Server-2014-RTM-12.0.2430.0-DW-ENU-Win2012R2-cy14su11   | MicrosoftSQLServer     | SQL2014-WS2012R2          | Enterprise-Optimized-for-DW   | 12.0.2430       |
| fb83b3509582419d99629ce476bcb5c8__SQL-Server-2014-RTM-12.0.2430.0-Ent-ENU-Win2012R2-cy14su11  | MicrosoftSQLServer     | SQL2014-WS2012R2          | Enterprise                    | 12.0.2430       |
| fb83b3509582419d99629ce476bcb5c8__SQL-Server-2014-RTM-12.0.2430.0-OLTP-ENU-Win2012R2-cy14su11 | MicrosoftSQLServer     | SQL2014-WS2012R2          | Enterprise-Optimized-for-OLTP | 12.0.2430       |
| fb83b3509582419d99629ce476bcb5c8__SQL-Server-2014-RTM-12.0.2430.0-Std-ENU-Win2012R2-cy14su11  | MicrosoftSQLServer     | SQL2014-WS2012R2          | Standard                      | 12.0.2430       |
| fb83b3509582419d99629ce476bcb5c8__SQL-Server-2014-RTM-12.0.2430.0-Web-ENU-Win2012R2-cy14su11  | MicrosoftSQLServer     | SQL2014-WS2012R2          | Web                           | 12.0.2430       |
