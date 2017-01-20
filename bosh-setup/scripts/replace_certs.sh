#!/bin/bash

set -ex

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
WORK_DIR=$(mktemp -d /tmp/upgrade-manifest.XXXXX)
BOSH_TEMPLATE="${SCRIPT_DIR}/bosh.yml"
SINGLE_TEMPLATE="${SCRIPT_DIR}/single-vm-cf.yml"
MULTIPLE_TEMPLATE="${SCRIPT_DIR}/multiple-vm-cf.yml"

cleanup() {
  echo "Cleaning up"
  rm -rf ${WORK_DIR}
}
trap cleanup EXIT

indent() {
  sed -e 's/^/  /'
}

indent_contents_of() {
  indent < "$1"
}

contents_of() {
 cat $1
}

replace_variable() {
  sed -i "s/$2/*$3/g" $1
}

replace_value() {
  sed -i "s/$2/$3/g" $1
}

cert_variable() {
  cat <<-EOF
$1: &$1 |
$(indent_contents_of "$2")
EOF
}

variable() {
  cat <<-EOF
$1: &$1 $(contents_of "$2")
EOF
}

variables() {
  cat <<-EOF
# variables start
$(cert_variable blobstore_ca_cert     certs/blobstore-certs/server-ca.crt)
$(cert_variable blobstore_tls_cert certs/blobstore-certs/server.crt)
$(cert_variable blobstore_private_key  certs/blobstore-certs/server.key)

$(cert_variable consul_ca_cert     certs/consul-certs/server-ca.crt)
$(cert_variable consul_agent_cert  certs/consul-certs/agent.crt)
$(cert_variable consul_agent_key   certs/consul-certs/agent.key)
$(cert_variable consul_server_cert certs/consul-certs/server.crt)
$(cert_variable consul_server_key  certs/consul-certs/server.key)

$(cert_variable jwt_verification_key certs/uaa-jwt-certs/jwt_verification_key)
$(cert_variable jwt_signing_key      certs/uaa-jwt-certs/jwt_signing_key)
$(cert_variable uaa_server_cert      certs/uaa-certs/server.crt)
$(cert_variable uaa_server_key       certs/uaa-certs/server.key)

$(cert_variable hm9000_ca_cert     certs/hm9000-certs/server-ca.crt)
$(cert_variable hm9000_client_cert certs/hm9000-certs/agent.crt)
$(cert_variable hm9000_client_key  certs/hm9000-certs/agent.key)
$(cert_variable hm9000_server_cert certs/hm9000-certs/server.crt)
$(cert_variable hm9000_server_key  certs/hm9000-certs/server.key)

$(cert_variable ha_proxy_ssl_pem certs/haproxy-certs/ha-proxy-ssl-pem)

$(cert_variable diego_ca certs/diego-certs/server-ca.crt)

$(cert_variable bbs_client_cert certs/diego-certs/agent.crt)
$(cert_variable bbs_client_key  certs/diego-certs/agent.key)
$(cert_variable bbs_server_cert certs/diego-certs/server.crt)
$(cert_variable bbs_server_key  certs/diego-certs/server.key)

$(cert_variable ssh_proxy_host_key       certs/ssh-proxy-certs/ssh-proxy-host-key.pem)
$(variable      host_key_fingerprint certs/ssh-proxy-certs/ssh-proxy-host-key-fingerprint)

# variables end

EOF
}

random_secret() {
  openssl rand -base64 16 | tr -dc 'a-zA-Z0-9'
}

certstrap_generate_certs() {
  while [[ $# -gt 1 ]]; do
    key="$1"
    case $key in
      --depot_path)
      depot_path="$2"
      shift
      ;;
      --server_cn)
      server_cn="$2"
      shift
      ;;
      --domain)
      domain_with_argument="--domain $2"
      shift
      ;;
      --agent_cn)
      agent_cn="$2"
      agent_cert_name=$(echo ${agent_cn} | sed -r 's/ /_/g')
      shift
      ;;
      *)
      ;;
    esac
    shift
  done

  echo "=== GENERATE ${depot_path} CERTS==="
  mkdir -p ${depot_path}

  # CA to generate client certs
  certstrap --depot-path ${depot_path} init --passphrase '' --common-name cert-authority
  mv -f ${depot_path}/cert-authority.crt ${depot_path}/server-ca.crt
  mv -f ${depot_path}/cert-authority.key ${depot_path}/server-ca.key

  # Server cert
  certstrap --depot-path ${depot_path} request-cert --passphrase '' --common-name "${server_cn}" ${domain_with_argument}
  certstrap --depot-path ${depot_path} sign $server_cn --CA server-ca
  mv -f ${depot_path}/${server_cn}.key ${depot_path}/server.key
  mv -f ${depot_path}/${server_cn}.csr ${depot_path}/server.csr
  mv -f ${depot_path}/${server_cn}.crt ${depot_path}/server.crt

  # Agent cert
  if [ -n "${agent_cn}" ]; then
    certstrap --depot-path ${depot_path} request-cert --passphrase '' --common-name "${agent_cn}"
    certstrap --depot-path ${depot_path} sign ${agent_cert_name} --CA server-ca
    mv -f ${depot_path}/${agent_cert_name}.key ${depot_path}/agent.key
    mv -f ${depot_path}/${agent_cert_name}.csr ${depot_path}/agent.csr
    mv -f ${depot_path}/${agent_cert_name}.crt ${depot_path}/agent.crt
  fi
}

if [ ! -e ${BOSH_TEMPLATE} ]; then
  echo "${BOSH_TEMPLATE} is not valid"
  exit 1
fi
if [ ! -e ${SINGLE_TEMPLATE} ]; then
  echo "${SINGLE_TEMPLATE} is not valid"
  exit 1
fi
if [ ! -e ${MULTIPLE_TEMPLATE} ]; then
  echo "${MULTIPLE_TEMPLATE} is not valid"
  exit 1
fi

echo "WORK_DIR: ${WORK_DIR}"
cd ${WORK_DIR}

# install certstrap
# workaround for building certstrap. Once certstrap is released with binary, we can remove this part of code and use the release binary instead
tar -C /usr/local -xzf ${SCRIPT_DIR}/go1.7.3.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
tar xf ${SCRIPT_DIR}/v1.0.1.tar.gz
pushd certstrap-1.0.1
  ./build
  cp -f bin/certstrap /usr/local/bin/
popd


# generate certs
mkdir -p certs
pushd certs
  certstrap_generate_certs --depot_path "consul-certs" --server_cn "server.dc1.cf.internal" --agent_cn "consul agent"
  certstrap_generate_certs --depot_path "hm9000-certs" --server_cn "listener-hm9000.service.cf.internal" --domain '*.listener-hm9000.service.cf.internal,listener-hm9000.service.cf.internal' --agent_cn "hm9000_client"
  certstrap_generate_certs --depot_path "diego-certs" --server_cn "bbs.service.cf.internal" --domain '*.bbs.service.cf.internal,bbs.service.cf.internal' --agent_cn "bbs client"
  certstrap_generate_certs --depot_path "uaa-certs" --server_cn "uaa.service.cf.internal"
  certstrap_generate_certs --depot_path "blobstore-certs" --server_cn "blobstore.service.cf.internal"

  echo -e "=== GENERATING JWT KEY ==="
  cert_path="uaa-jwt-certs"
  mkdir -p ${cert_path}
  openssl genrsa -out ${cert_path}/jwt_signing_key 2048
  openssl rsa -pubout -in ${cert_path}/jwt_signing_key -out ${cert_path}/jwt_verification_key

  echo -e "=== GENERATING SSH PROXY CERT AND FINGERPRINT ==="
  cert_path="ssh-proxy-certs"
  mkdir -p ${cert_path}
  ssh-keygen -N "" -f ${cert_path}/ssh-proxy-host-key.pem
  ssh-keygen -lf ${cert_path}/ssh-proxy-host-key.pem.pub | cut -d ' ' -f2 > ${cert_path}/ssh-proxy-host-key-fingerprint

  echo -e "=== GENERATING HAPRORXY CERTS ==="
  cert_path="haproxy-certs"
  mkdir -p ${cert_path}
  openssl genrsa -out ${cert_path}/ha_proxy_ssl.key 2048
  openssl req -new -x509 -days 365 -key ${cert_path}/ha_proxy_ssl.key -out ${cert_path}/ha_proxy_ssl.cert -subj "/C=US/ST=CA/L=San Francisco/O=Azure/OU=Platform Engineering/CN=xip.io"
  cat ${cert_path}/ha_proxy_ssl.key ${cert_path}/ha_proxy_ssl.cert > ${cert_path}/ha-proxy-ssl-pem
popd


variables > ${WORK_DIR}/variables.yml
echo ${WORK_DIR}/variables.yml

single_template_temp=$(mktemp)
multiple_template_temp=$(mktemp)
cat ${SINGLE_TEMPLATE} > ${single_template_temp} # single template does not use these variables for certs
cat ${WORK_DIR}/variables.yml ${MULTIPLE_TEMPLATE} > ${multiple_template_temp}

# replace cf certs
replace_certs_list="REPLACE_WITH_BLOBSTORE_CA_CERT \
                    REPLACE_WITH_BLOBSTORE_TLS_CERT \
                    REPLACE_WITH_BLOBSTORE_PRIVATE_KEY \
                    REPLACE_WITH_CONSUL_CA_CERT \
                    REPLACE_WITH_CONSUL_SERVER_CERT \
                    REPLACE_WITH_CONSUL_SERVER_KEY \
                    REPLACE_WITH_CONSUL_AGENT_CERT \
                    REPLACE_WITH_CONSUL_AGENT_KEY \
                    REPLACE_WITH_JWT_VERIFICATION_KEY \
                    REPLACE_WITH_JWT_SIGNING_KEY \
                    REPLACE_WITH_HM9000_SERVER_KEY \
                    REPLACE_WITH_HM9000_SERVER_CERT \
                    REPLACE_WITH_HM9000_CLIENT_KEY \
                    REPLACE_WITH_HM9000_CLIENT_CERT \
                    REPLACE_WITH_HM9000_CA_CERT \
                    REPLACE_WITH_HA_PROXY_SSL_PEM \
                    REPLACE_WITH_HOST_KEY_FINGERPRINT \
                    REPLACE_WITH_UAA_SERVER_CERT \
                    REPLACE_WITH_UAA_SERVER_KEY \

                    REPLACE_WITH_DIEGO_CA \
                    REPLACE_WITH_BBS_CLIENT_CERT \
                    REPLACE_WITH_BBS_CLIENT_KEY \
                    REPLACE_WITH_BBS_SERVER_CERT \
                    REPLACE_WITH_BBS_SERVER_KEY \
                    REPLACE_WITH_SSH_PROXY_HOST_KEY"

for cert_name in ${replace_certs_list}; do
  cert_variable=$(echo ${cert_name:13} | tr '[A-Z]' '[a-z]')
  replace_variable ${multiple_template_temp} ${cert_name} ${cert_variable}
done

replace_secrets_list="REPLACE_WITH_STAGING_UPLOAD_PASSWORD \
                      REPLACE_WITH_BULK_API_PASSWORD \
                      REPLACE_WITH_DB_ENCRYPTION_KEY \
                      REPLACE_WITH_BLOBSTORE_PASSWORD \
                      REPLACE_WITH_BLOBSTORE_SECRET \
                      REPLACE_WITH_CONSUL_ENCRYPT_KEY \
                      REPLACE_WITH_LOGGREGATOR_ENDPOINT_SHARED_SECRET \
                      REPLACE_WITH_NATS_PASSWORD \
                      REPLACE_WITH_ROUTER_PASSWORD \
                      REPLACE_WITH_ADMIN_SECRET \
                      REPLACE_WITH_CC_CLIENT_SECRET \
                      REPLACE_WITH_CC_ROUTING_SECRET \
                      REPLACE_WITH_CLOUD_CONTROLLER_USERNAME_LOOKUP_SECRET \
                      REPLACE_WITH_DOPPLER_SECRET \
                      REPLACE_WITH_GOROUTER_SECRET \
                      REPLACE_WITH_TCP_EMITTER_SECRET \
                      REPLACE_WITH_TCP_ROUTER_SECRET \
                      REPLACE_WITH_LOGIN_CLIENT_SECRET \
                      REPLACE_WITH_NOTIFICATIONS_CLIENT_SECRET \
                      REPLACE_WITH_CC_SERVICE_DASHBOARDS_SECRET \
                      REPLACE_WITH_CCDB_PASSWORD \
                      REPLACE_WITH_UAADB_PASSWORD \
                      REPLACE_WITH_DIEGODB_PASSWORD \
                      REPLACE_WITH_A_SECURE_PASSPHRASE \
                      REPLACE_WITH_SSH_PROXY_SECRET"

for secret_name in ${replace_secrets_list}; do
  secret_value=$(random_secret)
  replace_value ${single_template_temp} ${secret_name} ${secret_value}
  replace_value ${multiple_template_temp} ${secret_name} ${secret_value}
done

cp ${single_template_temp} ${SINGLE_TEMPLATE}
cp ${multiple_template_temp} ${MULTIPLE_TEMPLATE}

# Replace bosh secrets
replace_bosh_secrets_list="REPLACE_WITH_NATS_PASSWORD \
                           REPLACE_WITH_POSTGRES_PASSWORD \
                           REPLACE_WITH_REGISTRY_PASSWORD \
                           REPLACE_WITH_DIRECTOR_PASSWORD \
                           REPLACE_WITH_ADMIN_PASSWORD \
                           REPLACE_WITH_AGENT_PASSWORD \
                           REPLACE_WITH_HM_PASSWORD \
                           REPLACE_WITH_MBUS_PASSWORD"
for secret_name in ${replace_bosh_secrets_list}; do
  secret_value=$(random_secret)
  replace_value ${BOSH_TEMPLATE} ${secret_name} ${secret_value}
  if [ ${secret_name} == "REPLACE_WITH_ADMIN_PASSWORD" ]; then
    sed -i "s/REPLACE_WITH_ADMIN_PASSWORD/${secret_value}/g" ${SCRIPT_DIR}/deploy_bosh.sh
  fi
done
