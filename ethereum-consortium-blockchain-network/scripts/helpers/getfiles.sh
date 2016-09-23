#!/bin/bash

wget -N https://berlintemplates.blob.core.windows.net/arm-templates/MultiNodeEthereumNetwork/scripts/configure-geth.sh
wget -N https://berlintemplates.blob.core.windows.net/arm-templates/MultiNodeEthereumNetwork/scripts/start-private-blockchain.sh
wget -N https://berlintemplates.blob.core.windows.net/arm-templates/MultiNodeEthereumNetwork/scripts/helpers/attach-geth.sh
wget -N https://berlintemplates.blob.core.windows.net/arm-templates/MultiNodeEthereumNetwork/scripts/helpers/start.sh
wget -N https://berlintemplates.blob.core.windows.net/arm-templates/MultiNodeEthereumNetwork/scripts/helpers/stop.sh
wget -N https://berlintemplates.blob.core.windows.net/arm-templates/MultiNodeEthereumNetwork/scripts/helpers/getenodeurl.sh
chmod 744 configure-geth.sh start-private-blockchain.sh attach-geth.sh start.sh stop.sh getenodeurl.sh
