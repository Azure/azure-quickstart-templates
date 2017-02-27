#!/bin/bash

docker_account_name=$1
registry=$2
repository=$3
port=$4
user_name=$5
user_email=$6
artifacts_location=$7
artifacts_location_sas_token=$8

# Validate and parse repository
if [[ "$repository" =~ ^([^[:space:]\/]+)\/([^[:space:]\/]+)$ ]]; then
    organization="${BASH_REMATCH[1]}"
    app_name="${BASH_REMATCH[2]}"
    app_name=$(echo "${app_name,,}" | tr -cd '[[:alnum:]]') # Convert to lowercase and remove symbols from application name. Kubernetes only supports ^[a-z0-9]+$
else
    echo "Expected repository to be of the form 'organization/applicationname', but instead received '$repository'." 1>&2
    exit 1
fi

# Remove http prefix and trailing slash from registry if they exist
registry=${registry#"https://"}
registry=${registry#"http://"}
registry=${registry%"/"}

# Create application
application_data=$(curl -s ${artifacts_location}resources/application.json${artifacts_location_sas_token})
application_data=${application_data//REPLACE_APP_NAME/$app_name}
application_data=${application_data//REPLACE_USER_NAME/$user_name}
application_data=${application_data//REPLACE_USER_EMAIL/$user_email}
curl -X POST -H "Content-type: application/json" --data "$application_data" http://localhost:8084/applications/${app_name}/tasks

# Create pipeline
pipeline_data=$(curl -s ${artifacts_location}resources/pipeline.json${artifacts_location_sas_token})
pipeline_data=${pipeline_data//REPLACE_APP_NAME/$app_name}
pipeline_data=${pipeline_data//REPLACE_DOCKER_ACCOUNT_NAME/$docker_account_name}
pipeline_data=${pipeline_data//REPLACE_REGISTRY/$registry}
pipeline_data=${pipeline_data//REPLACE_REPOSITORY/$repository}
pipeline_data=${pipeline_data//REPLACE_ORGANIZATION/$organization}
pipeline_data=${pipeline_data//REPLACE_PORT/$port}
curl -X POST -H "Content-type: application/json" --data "$pipeline_data" http://localhost:8084/pipelines

# Create dev load balancer
load_balancer_data=$(curl -s ${artifacts_location}resources/load_balancer.json${artifacts_location_sas_token})
dev_load_balancer_data=${load_balancer_data//REPLACE_APP_NAME/$app_name}
dev_load_balancer_data=${dev_load_balancer_data//REPLACE_USER_NAME/$user_name}
dev_load_balancer_data=${dev_load_balancer_data//REPLACE_PORT/$port}
dev_load_balancer_data=${dev_load_balancer_data//REPLACE_STACK/"dev"}
dev_load_balancer_data=${dev_load_balancer_data//REPLACE_SERVICE_TYPE/"ClusterIP"}
curl -X POST -H "Content-type: application/json" --data "$dev_load_balancer_data" http://localhost:8084/applications/${app_name}/tasks

# Create prod load balancer
prod_load_balancer_data=${load_balancer_data//REPLACE_APP_NAME/$app_name}
prod_load_balancer_data=${prod_load_balancer_data//REPLACE_USER_NAME/$user_name}
prod_load_balancer_data=${prod_load_balancer_data//REPLACE_PORT/$port}
prod_load_balancer_data=${prod_load_balancer_data//REPLACE_STACK/"prod"}
prod_load_balancer_data=${prod_load_balancer_data//REPLACE_SERVICE_TYPE/"LoadBalancer"}
curl -X POST -H "Content-type: application/json" --data "$prod_load_balancer_data" http://localhost:8084/applications/${app_name}/tasks