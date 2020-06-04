#!/bin/bash

# Command Line Opts
GRAFANA_VERSION="4.5.2"
GRAFANA_PORT="3000"


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
    echo "-V version of grafana to use. Default:${GRAFANA_VERSION}"
    echo "-p port to host grafana-server"
    echo "-h view this help content"
}

# Parameters
ADMIN_PWD="admin"

#Loop through options passed
while getopts :A:V::h optname; do
  log "Option $optname set"
  case $optname in
    A)
      ADMIN_PWD="${OPTARG}"
      ;;
    V) #input desired grafana version
        GRAFANA_VERSION="${OPTARG}"
        ;;
    p) #port number for local grafana server
        GRAFANA_PORT="${OPTARG}"
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

# Install Grafana
install_grafana()
{
    log "Downloading grafana with version ${GRAFANA_VERSION}"
    local DOWNLOAD_URL="https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana_${GRAFANA_VERSION}_amd64.deb"
    sudo apt-get install -y adduser libfontconfig
    wget "${DOWNLOAD_URL}"
    sudo dpkg -i "grafana_${GRAFANA_VERSION}_amd64.deb"
    systemctl daemon-reload
}

start_grafana()
{
    log "Staring the grafana-server"
    systemctl start grafana-server
    sudo systemctl enable grafana-server.service
}

# Install the Azure Monitor Datasource
install_azure_monitor_plugin()
{
    log "Install grafana-azure-monitor-datasource"
    grafana-cli plugins install grafana-azure-monitor-datasource
    systemctl restart grafana-server
}

# Update the grafana passord of the admin account
configure_admin_password()
{
    sed -i "s/;admin_password = admin/admin_password = ${ADMIN_PWD}/" /etc/grafana/grafana.ini
}

install_grafana
configure_admin_password
start_grafana
install_azure_monitor_plugin
