#!/bin/bash

# Note: This script creates self-signed certificates
# according to https://docs.microsoft.com/en-us/azure/application-gateway/self-signed-certificates.

ROOT_HOST=$1

echo "Setting root custom domain: $ROOT_HOST"

APIM_GATEWAY_HOST="api.$ROOT_HOST"
APIM_PORTAL_HOST="portal.$ROOT_HOST"
APIM_MANAGEMENT_HOST="management.$ROOT_HOST"

create_server_cert () {
    local SERVER_CERT=$1
    echo "Creating server certificate for $SERVER_CERT"

    # ---- Create a server certificate ----
    ## Create the certificate's key
    openssl ecparam -out "$SERVER_CERT.key" -name prime256v1 -genkey

    ## Create the CSR (Certificate Signing Request)
    openssl req -new -sha256 -key "$SERVER_CERT.key" -out "$SERVER_CERT.csr" -subj "/CN=$SERVER_CERT" --passin file:pass

    ## Generate the certificate with the CSR and the key and sign it with the CA's root key
    openssl x509 -req -in "$SERVER_CERT.csr" -CA "$ROOT_HOST.crt" -CAkey "$ROOT_HOST.key" -CAcreateserial -out "$SERVER_CERT.crt" -days 365 -sha256

    # ---- Export PFX file ----
    openssl pkcs12 -export -out "$SERVER_CERT.pfx" -inkey "$SERVER_CERT.key" -in "$SERVER_CERT.crt" -password file:pass

    # ---- Base64 encode PFX ----
    base64 "$SERVER_CERT.pfx" > "$SERVER_CERT.pfx.txt"
}

create_root_cert () {
    echo "Creating root certificate for $ROOT_HOST"

    # ---- Create a root CA certificate ----
    ## Create the root key
    openssl ecparam -out "$ROOT_HOST.key" -name prime256v1 -genkey

    # ---- Create a Root Certificate and self-sign it ----
    openssl req -new -sha256 -key "$ROOT_HOST.key" -out "$ROOT_HOST.csr" -subj "/CN=$ROOT_HOST" --passin file:pass

    openssl x509 -req -sha256 -days 365 -in "$ROOT_HOST.csr" -signkey "$ROOT_HOST.key" -out "$ROOT_HOST.crt"

    # ---- Export PFX file ----
    openssl pkcs12 -export -out "$ROOT_HOST.pfx" -inkey "$ROOT_HOST.key" -in "$ROOT_HOST.crt" -password file:pass

    # ---- Base64 encode PFX ----
    base64 "$ROOT_HOST.pfx" > "$ROOT_HOST.pfx.txt"
    base64 "$ROOT_HOST.crt" > "$ROOT_HOST.crt.txt"
}

# Create a new directory for the certificates
mkdir -p "certs/$ROOT_HOST"
cd "certs/$ROOT_HOST" || exit

# Create password; same password is used for all certs
openssl rand -hex 16 > pass

# Create root certificate
create_root_cert

# Create server certificates
create_server_cert "$APIM_GATEWAY_HOST"
create_server_cert "$APIM_MANAGEMENT_HOST"
create_server_cert "$APIM_PORTAL_HOST"

# Change back to previous directory
cd ../..     
