#!/bin/bash

WEB_JOB_NAME="azure-api-mgmt-logs-2-moesif"
WEB_JOB_TYPE="Continuous"
GITHUB_RUN_BAT_URL="https://raw.githubusercontent.com/Moesif/ApimEventProcessor/v1/azure-app-service-webjobs/run.bat"
WEBDEPLOY_ZIP_FILE=apim-2-moesif-webjob-webdeploy.zip

BASE_DIR="/tmp/build-webdeploy-pkg"
WEBJOB_DIR="app_data/Jobs/${WEB_JOB_TYPE}/${WEB_JOB_NAME}"

rm -rf ${BASE_DIR}
mkdir -p ${BASE_DIR}
cd ${BASE_DIR}
mkdir -p .deploy/${WEBJOB_DIR}
curl -s ${GITHUB_RUN_BAT_URL} -o .deploy/${WEBJOB_DIR}/run.bat
cd .deploy 
zip -r ../${WEBDEPLOY_ZIP_FILE} . *
cd ..
echo "$(pwd)/${WEBDEPLOY_ZIP_FILE} has been created"