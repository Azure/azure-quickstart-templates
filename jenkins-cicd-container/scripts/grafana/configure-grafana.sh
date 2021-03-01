# Utility Log Command
log()
{
    echo "`date -u +'%Y-%m-%d %H:%M:%S'`: ${1}"
}

help()
{
    echo "This script installs Grafana cluster on Ubuntu"
    echo "Parameters:"
    echo "-A admin password"
    echo "-p port to host grafana-server"
    echo "-S Azure subscription id"
    echo "-T Azure tenant id"
    echo "-i Azure service principal client id"
    echo "-s Azure service principal client secret"
    echo "-r Name of the resource group"
    echo "-c Name of the CosmosDB"
    echo "-k Name of the Kubernetes cluster"
    echo "-l Artifacts location"
    echo "-t Artifacts location sas token"
    echo "-h view this help content"
}

#Loop through options passed
while getopts A:p:S:T:i:s:r:c:k:l:t::h optname; do
  log "Option $optname set"
  case $optname in
    A)
      ADMIN_PWD="${OPTARG}"
      ;;
    p) #port number for local grafana server
      GRAFANA_PORT="${OPTARG}"
      ;;
    S)
      SUBSCRIPTION_ID="${OPTARG}"
      ;;
    T)
      TENANT_ID="${OPTARG}"
      ;;
    i)
      CLIENT_ID="${OPTARG}"
      ;;
    s)
      CLIENT_SECRET="${OPTARG}"
      ;;
    r)
      RESOURCE_GROUP="${OPTARG}"
      ;;
    c)
      COMSOSDB_NAME="${OPTARG}"
      ;;
    k)
      CLUSTER_NAME="${OPTARG}"
      ;;
    l)
      ARTIFACTS_LOCATION="${OPTARG}"
      ;;
    t)
      ARTIFACTS_LOCATION_SAS_TOKEN="${OPTARG}"
      ;;
    h) #show help
      help
      exit 2
      ;;
    \?) #unrecognized option - show help
      echo -e \\n"Option -${BOLD}$OPTARG${NORM} not allowed."
      help
      exit 2
      ;;
  esac
done

function retry_until_successful {
  counter=0
  "${@}"
  while [ $? -ne 0 ]; do
    if [[ "$counter" -gt 20 ]]; then
        exit 1
    else
        let counter++
    fi
    sleep 6
    "${@}"
  done;
}

function post_json() {
  curl -X POST http://admin:$ADMIN_PWD@localhost:$GRAFANA_PORT$1 \
     -H "Content-Type: application/json" \
     -d "$2"
}

#install azure-cli
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ wheezy main" | \
     sudo tee /etc/apt/sources.list.d/azure-cli.list
sudo apt-key adv --keyserver packages.microsoft.com --recv-keys 52E16F86FEE04B979B07E28DB02C46DF417A0893
sudo apt-get install apt-transport-https
sudo apt-get update && sudo apt-get install azure-cli

#get vitrual machines
az login --service-principal -u $CLIENT_ID --password $CLIENT_SECRET --tenant $TENANT_ID
location=$(az group show --name $RESOURCE_GROUP --query location --out tsv)
aks_resource_group="MC_${RESOURCE_GROUP}_${CLUSTER_NAME}_${location}"
virtual_machines=$(az resource list --resource-group ${aks_resource_group} --resource-type Microsoft.Compute/virtualMachines --query [*].name --out tsv)

#wait until Grafana gets started
retry_until_successful curl http://localhost:$GRAFANA_PORT

#add Azure Monitor data source
post_json "/api/datasources" "$(cat <<EOF
{
    "name":"Azure Monitor",
    "type":"grafana-azure-monitor-datasource",
    "url":"https://management.azure.com",
    "access": "proxy",
    "isDefault":true,
    "jsonData": {
        "subscriptionId": "${SUBSCRIPTION_ID}",
        "tenantId":"${TENANT_ID}",
        "clientId":"${CLIENT_ID}"
    },
    "secureJsonData": {
        "clientSecret": "${CLIENT_SECRET}"
    }
}
EOF
)"

#create dashboard
dashboard_db=$(curl -s ${ARTIFACTS_LOCATION}scripts/grafana/dashboard-db.json${ARTIFACTS_LOCATION_SAS_TOKEN})
dashboard_db=${dashboard_db//'{RESOURCE-GROUP-PLACEHOLDER}'/${RESOURCE_GROUP}}
dashboard_db=${dashboard_db//'{COSMOSDB-NAME-PLACEHOLDER}'/${COMSOSDB_NAME}}

targets=""
dashboard_aks_target=$(curl -s ${ARTIFACTS_LOCATION}scripts/grafana/dashboard-aks-target.json${ARTIFACTS_LOCATION_SAS_TOKEN})
for virtual_machine in $virtual_machines
do
  target=${dashboard_aks_target//'{RESOURCE-GROUP-PLACEHOLDER}'/${aks_resource_group}}
  target=${target//'{VM-NAME-PLACEHOLDER}'/${virtual_machine}}
  targets=${targets},${target}
done
targets=${targets:1:${#targets}}

dashboard_aks=$(curl -s ${ARTIFACTS_LOCATION}scripts/grafana/dashboard-aks.json${ARTIFACTS_LOCATION_SAS_TOKEN})
dashboard_aks=${dashboard_aks//'"targets": []'/"\"targets\"": [${targets}]}

dashboard=$(curl -s ${ARTIFACTS_LOCATION}scripts/grafana/dashboard.json${ARTIFACTS_LOCATION_SAS_TOKEN})
dashboard=${dashboard//'"rows": []'/"\"rows\"": [${dashboard_db}, ${dashboard_aks}]}

post_json "/api/dashboards/db" "${dashboard}"
