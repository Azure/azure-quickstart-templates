#!/bin/bash

app_name=${1,,} # Spinnaker only supports lowercase application names
user_name=$2
user_email=$3
artifacts_location=$4
artifacts_location_sas_token=$5

# Create application
application_data=$(curl -s ${artifacts_location}resources/application.json${artifacts_location_sas_token})
application_data=${application_data//APP_NAME/$app_name}
application_data=${application_data//USER_NAME/$user_name}
application_data=${application_data//USER_EMAIL/$user_email}
curl -X POST -H "Content-type: application/json" --data "$application_data" http://localhost:8084/applications/${app_name}/tasks

# Create pipeline
pipeline_data=$(curl -s ${artifacts_location}resources/pipeline.json${artifacts_location_sas_token})
pipeline_data=${pipeline_data//APP_NAME/$app_name}
pipeline_data=${pipeline_data//USER_NAME/$user_name}
curl -X POST -H "Content-type: application/json" --data "$pipeline_data" http://localhost:8084/pipelines

# Create dev load balancer
dev_load_balancer_data=$(curl -s ${artifacts_location}resources/dev_load_balancer.json${artifacts_location_sas_token})
dev_load_balancer_data=${dev_load_balancer_data//APP_NAME/$app_name}
dev_load_balancer_data=${dev_load_balancer_data//USER_NAME/$user_name}
curl -X POST -H "Content-type: application/json" --data "$dev_load_balancer_data" http://localhost:8084/applications/${app_name}/tasks

# Create prod load balancer
prod_load_balancer_data=$(curl -s ${artifacts_location}resources/prod_load_balancer.json${artifacts_location_sas_token})
prod_load_balancer_data=${prod_load_balancer_data//APP_NAME/$app_name}
prod_load_balancer_data=${prod_load_balancer_data//USER_NAME/$user_name}
curl -X POST -H "Content-type: application/json" --data "$prod_load_balancer_data" http://localhost:8084/applications/${app_name}/tasks