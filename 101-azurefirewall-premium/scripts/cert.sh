#!/bin/bash

# Create root CA
openssl req -x509 -new -nodes -newkey rsa:4096 -keyout rootCA.key -sha256 -days 3650 -out rootCA.crt -subj "/C=US/ST=US/O=Self Signed/CN=Self Signed Root CA" -config openssl.cnf -extensions rootCA_ext

# Create intermediate CA request
openssl req -new -nodes -newkey rsa:4096 -keyout interCA.key -sha256 -out interCA.csr -subj "/C=US/ST=US/O=Self Signed/CN=Self Signed Intermediate CA"

# Sign on the intermediate CA
openssl x509 -req -in interCA.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out interCA.crt -days 3650 -sha256 -extfile openssl.cnf -extensions interCA_ext

# Export the intermediate CA into PFX
openssl pkcs12 -export -out interCA.pfx -inkey interCA.key -in interCA.crt -password "pass:"

# Convert the PFX and public key into base64
if [ "$(uname)" == "Darwin" ]; then
    cat interCA.pfx | base64 > interCA.pfx.base64
    cat rootCA.crt | base64 > rootCA.crt.base64
else
    cat interCA.pfx | base64 -w 0 > interCA.pfx.base64
    cat rootCA.crt | base64 -w 0 > rootCA.crt.base64
fi

echo ""
echo "================"
echo "Successfully generated root and intermediate CA certificates"
echo "   - rootCA.crt/rootCA.key - Root CA public certificate and private key"
echo "   - interCA.crt/interCA.key - Intermediate CA public certificate and private key"
echo "   - interCA.pfx.base64 - Base64 encoded intermediate CA pkcs12 package to be consumed by caPfxEncodedInBase64 template parameter"
echo "   - rootCA.crt.base64 - Base64 encoded root PEM certificate to be consumed by the rootPemEncodedInBase64 template parameter"
echo "================"
