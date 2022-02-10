#!/bin/bash

CUSTOM_DOMAIN=$1

if [[ -z $CUSTOM_DOMAIN ]]
then  
    echo "Parameters missing."
    echo "Usage: create-certificates.sh custom_domain"
    echo "Try: create-certificates.sh *.contoso.net"
    exit
fi

create_server_cert () {
    echo "Creating server certificate for $CUSTOM_DOMAIN."

    EXTENSION_CONFIGURATION="subjectAltName=DNS:$CUSTOM_DOMAIN"

    # Create the certificate's key
    openssl ecparam -out domain.key -name prime256v1 -genkey

    # Create the CSR (Certificate Signing Request)
    openssl req -new -sha256 -key domain.key -out domain.csr -subj "/CN=$CUSTOM_DOMAIN" -addext "subjectAltName=DNS:$CUSTOM_DOMAIN" --passin file:pass

    # NOTE: The 'openssl x509' (v1.1.1 - https://www.openssl.org/docs/man1.1.1/man1/openssl-x509.html) currently doesn't support
    #       the '-addext' option.  Thus, need to specify the Subject Alternative Name via configuration.
    #       Instead of providing a configuration file with this sample, the 'subjectAlName' extension is added via a 'printf' statement.
    #       An alternative is to create an extension file with the necessary extensions and provide the path to the extension file.
    #       openssl x509 -req -days 365 -sha256 -in domain.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out domain.crt -extfile ../domain.ext
    #
    #       Extension file sample:
    #       subjectAltName = DNS:*.contoso.net

    # Generate the certificate with the CSR and the key and sign it with the CA's root key
    openssl x509 -req -days 365 -sha256 -in domain.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out domain.crt -extfile <(printf '%s' "$EXTENSION_CONFIGURATION")

    # Export PFX file
    openssl pkcs12 -export -out domain.pfx -inkey domain.key -in domain.crt -password file:pass

    # Base64 encode PFX
    base64 -w 0 domain.pfx > domain.pfx.txt
}

create_root_CA_cert () {
    echo "Creating root CA certificate."

    # Create a root CA certificate
    # Create the root key
    openssl ecparam -out rootCA.key -name prime256v1 -genkey

    # Create a Root Certificate and self-sign it
    # Generate the CSR (Certificate Signing Request)
    openssl req -new -sha256 -key rootCA.key -out rootCA.csr -subj "/CN=Azure Quickstarts Sample CA" --passin file:pass
    
    openssl x509 -req -sha256 -days 365 -in rootCA.csr -signkey rootCA.key -out rootCA.crt

    # Base64 encode CRT
    base64 -w 0 rootCA.crt > rootCA.crt.txt
}

# Create a new directory for the certificates
mkdir -p .certs
cd .certs || exit

# Create password; same password is used for all certs
openssl rand -hex 16 > pass

# Create root CA certificate
create_root_CA_cert

# Create server certificates
create_server_cert