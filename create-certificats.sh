#!/bin/bash

function print_help() {
    echo "Usage ./create-certificates.sh [domain.name]"
    echo "Default domain.name - localhost"
}

function required_run() {
  local run_it="$@"
  if [ -n "$run_it" ]; then
    #echo "Requred run: $run_it"
    eval $run_it
    if [ $? -ne 0 ]; then
      echo "Error while running: $run_it"
      exit 1
    fi
  fi
}

cd "$(dirname "$(readlink -f "$0")")"
cd builtin-apps/registry-frontend/security

SERVER_HOST="${1:-localhost}"

if [ -z "$SERVER_HOST" ]; then
    print_help
fi

echo "Working folder: $(pwd)"

CA_FILE=ca.pem
CA_KEY_FILE=ca-key.pem

SERVER_CERT_CA_FILE=registry-cert-ca.pem #bundle cert for nginx
SERVER_KEY_FILE=registry-key.pem
SERVER_REQUEST_FILE=registry.csr
SERVER_CERT_FILE=registry-cert.pem

if [ -f $SERVER_CERT_FILE -a -f $SERVER_KEY_FILE ]; then
    echo Found cert and key files: $SERVER_CERT_FILE $SERVER_KEY_FILE
    echo Remove them first to create new
    exit 1
fi

if [ -f "$CA_FILE" -a -f "$CA_KEY_FILE" ]; then
    echo Using existing CA certificate and key $CA_FILE $CA_KEY_FILE
else
    echo Creating CA key ...
    required_run openssl genrsa -aes256 -out $CA_KEY_FILE 2048
    
    echo Creating CA certificate ...
    required_run openssl req -new -x509 -days 365 -key $CA_KEY_FILE -sha256 -out $CA_FILE

    echo Created CA certificate and key
fi

echo Creating server certificate and key ...

required_run openssl genrsa -out $SERVER_KEY_FILE 2048
required_run openssl req -subj "/CN=$SERVER_HOST" -new -key $SERVER_KEY_FILE -out $SERVER_REQUEST_FILE

echo 'subjectAltName = DNS:localhost' > extfile.cnf

required_run openssl x509 -req -days 365 -in $SERVER_REQUEST_FILE -CA $CA_FILE -CAkey $CA_KEY_FILE \
    -CAcreateserial -out $SERVER_CERT_FILE -extfile extfile.cnf

chmod 400 $SERVER_KEY_FILE
chmod 444 $SERVER_CERT_FILE

cat $SERVER_CERT_FILE $CA_FILE > $SERVER_CERT_CA_FILE

echo Done!

echo Register ca certificate at docker client hosts:
echo   cp $(pwd)/ca.pem /usr/local/share/ca-certificates/project-ca.crt
echo   update-ca-certificates

ls -la *.pem
