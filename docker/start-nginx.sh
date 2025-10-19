#!/bin/sh

# Debug: show environment variables
echo "Environment variables:"
echo "BACKEND_SERVICE_HOST: ${BACKEND_SERVICE_HOST}"
echo "BACKEND_SERVICE_PORT: ${BACKEND_SERVICE_PORT}"

# Replace environment variables in nginx template
envsubst '${BACKEND_SERVICE_HOST} ${BACKEND_SERVICE_PORT}' < /etc/nginx/nginx-template.conf > /etc/nginx/nginx.conf

# Debug: show the generated config
echo "Generated nginx config:"
cat /etc/nginx/nginx.conf | grep proxy_pass

# Start nginx
exec nginx -g 'daemon off;'
