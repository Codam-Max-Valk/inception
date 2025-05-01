#!/bin/sh

set -e

if [ -z "$DOMAIN_NAME" ]; then
	echo "Error: DOMAIN_NAME is not set."
	exit 1
fi

if [ ! -f /etc/ssl/certs/nginx.key ] || [ ! -f /etc/ssl/private/nginx.crt]; then
	echo "=== Generating self-signed SSL certificate ==="
	mkdir -p /etc/ssl/private
	mkdir -p /etc/ssl/certs

	openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
		-keyout /etc/ssl/certs/nginx.key \
		-out /etc/ssl/private/nginx.crt \
		-subj "/C=NL/ST=Noord-Holland/L=Amsterdam/O=Codam/OU=Codam/CN=${DOMAIN_NAME}"
fi

echo "=== Setting up Nginx configuration ==="

envsubst '${DOMAIN_NAME}' < /etc/nginx/conf.d/default.conf > /etc/nginx/conf.d/default.conf

echo "=== Nginx configuration complete ==="	
exec "$@"