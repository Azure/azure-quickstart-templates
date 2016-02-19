# Azure template for deployment of the docker with standalone EtherCamp IDE

This template deploys a docker with standalone version of EtherCamp IDE on Ubuntu. The template can be run by azure cli tool:
```
$ azure login
$ azure config mode arm
$ azure group create ether-camp-ide "West US"
$ azure group deployment create --template-uri https://raw.githubusercontent.com/ether-camp/docker-standalone-ether-camp-ide-on-ubuntu/master/azuredeploy.json ether-camp-ide ide-deployment
```

To see log of deployment:
```
$ azure group log show ether-camp-ide -l
```

To grep errors from the log:
```
azure group log show ether-camp-ide -l --json | jq '.[] | select(.status.value == "Failed") | .properties
```