#!/bin/bash
function print_usage() {
  cat <<EOF
Command
  $0
Arguments
  --location|-l            [Required] : The web page location
  --url|-u                 [Required] : Domain URL
  --artifacts_location|-al            : Url used to reference other scripts/artifacts.
  --sas_token|-st                     : A sas token needed if the artifacts location is private.
EOF
}

function throw_if_empty() {
  local name="$1"
  local value="$2"
  if [ -z "$value" ]; then
    echo "Parameter '$name' cannot be empty." 1>&2
    print_usage
    exit -1
  fi
}

#defaults
artifacts_location="https://raw.githubusercontent.com/Azure/azure-devops-utils/master/"

while [[ $# > 0 ]]
do
  key="$1"
  shift
  case $key in
    --location|-l)
      location="$1"
      shift
      ;;
    --url|-u)
      url="$1"
      shift
      ;;
    --artifacts_location|-al)
      artifacts_location="$1"
      shift
      ;;
    --sas_token|-st)
      artifacts_location_sas_token="$1"
      shift
      ;;
    --help|-help|-h)
      print_usage
      exit 13
      ;;
    *)
      echo "ERROR: Unknown argument '$key' to script '$0'" 1>&2
      exit -1
  esac
done

throw_if_empty --location $location
throw_if_empty --url $url

#install jenkins-on-azure web page
sudo mkdir ${location}
artifacts=("headshot.png" "title.png" "azure.svg" "copy.png" "site.css" "site.js" "index.html")
for i in "${artifacts[@]}"; do
  if [[ $i =~ .*html.* ]]
  then
      raw_resource=$(curl --silent "${artifacts_location}/jenkins/jenkins-on-azure/$i${artifacts_location_sas_token}")
      final_resource=${raw_resource//'{domain-name}'/${url}}
      echo "${final_resource}" | sudo tee ${location}/$i > /dev/null
    else
      curl --silent "${artifacts_location}/jenkins/jenkins-on-azure/$i${artifacts_location_sas_token}" -o ${location}/$i
  fi
done