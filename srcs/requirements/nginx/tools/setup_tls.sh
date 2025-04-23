#!/bin/sh

DOMAIN_NAME="${DOMAIN_NAME:-localhost}"
CERT_PATH="/etc/ssl/certs"
KEY_PATH="/etc/ssl/private"

mkdir -p $CERT_PATH $KEY_PATH

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
	-keyout $KEY_PATH/nginx.key \
	-out $CERT_PATH/nginx.crt \
	-subj "/C=NL/ST=Noord-Holland/L=Amsterdam/O=Codam/OU=Codam/CN=$DOMAIN_NAME"

