#!/bin/bash

function print_usage() {
  cat <<EOF
Command
  $0
Arguments
  --command|-c             [Required]: Jenkins cli command to run
  --command_input_file|-cif          : File path containing the input to the CLI command
  --jenkins_url|-j                   : Jenkins URL, defaulted to "http://localhost:8080/"
  --jenkins_username|-ju             : Jenkins user name, defaulted to "admin"
  --jenkins_password|-jp             : Jenkins password. If not specified and the user name is "admin", the initialAdminPassword will be used
EOF
}

function throw_if_empty() {
  local name="$1"
  local value="$2"
  if [ -z "$value" ]; then
    >&2 echo "Parameter '$name' cannot be empty."
    print_usage
    exit -1
  fi
}

#set defaults
jenkins_url="http://localhost:8080/"
jenkins_username="admin"

while [[ $# > 0 ]]
do
  key="$1"
  shift
  case $key in
    --command|-c)
      command="$1"
      shift
      ;;
    --command_input_file|-cif)
      command_input_file="$1"
      shift
      ;;
    --jenkins_url|-j)
      jenkins_url="$1"
      shift
      ;;
    --jenkins_username|-ju)
      jenkins_username="$1"
      shift
      ;;
    --jenkins_password|-jp)
      jenkins_password="$1"
      shift
      ;;
    --help|-help|-h)
      print_usage
      exit 13
      ;;
    *)
      >&2 echo "ERROR: Unknown argument '$key' to script '$0'"
      exit -1
  esac
done

throw_if_empty jenkins_username $jenkins_username
if [ "$jenkins_username" != "admin" ]; then
  throw_if_empty jenkins_password $jenkins_password
fi

function retry_until_successful {
  counter=0
  "${@}"
  while [ $? -ne 0 ]; do
    if [[ "$counter" -gt 20 ]]; then
        exit 1
    else
        let counter++
    fi
    sleep 5
    "${@}"
  done;
}

function retry_until_successful_with_input {
  input_file=$1
  shift
  counter=0
  cat "$input_file" | "${@}"
  while [ $? -ne 0 ]; do
    if [[ "$counter" -gt 20 ]]; then
        exit 1
    else
        let counter++
    fi
    sleep 5
    cat "$input_file" | "${@}"
  done;
}

if [ ! -e jenkins-cli.jar ]; then
  >&2 echo "Downloading Jenkins CLI..."
  retry_until_successful wget ${jenkins_url}jnlpJars/jenkins-cli.jar -O jenkins-cli.jar
fi

if [ -z "$jenkins_password" ]; then
  # NOTE: Intentionally setting this after the first retry_until_successful to ensure the initialAdminPassword file exists
  jenkins_password=`sudo cat /var/lib/jenkins/secrets/initialAdminPassword`
fi

>&2 echo "Running \"${command}\"..."
if [ -z "${command_input_file}" ]; then
  retry_until_successful java -jar jenkins-cli.jar -s "${jenkins_url}" -auth "${jenkins_username}":"${jenkins_password}" $command
else
  retry_until_successful_with_input "${command_input_file}" java -jar jenkins-cli.jar -s "${jenkins_url}" -auth "${jenkins_username}":"${jenkins_password}" $command
fi
