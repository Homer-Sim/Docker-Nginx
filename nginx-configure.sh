#!/bin/bash

SSL_DIR=/etc/nginx/ssl
LE_WORKING_DIR=${LE_WORKING_DIR:-/letsencrypt}

# Build a list of location stanzas from the environment
locations=()
for ep in ${ENDPOINTS}; do
    pieces=( $(echo ${ep} | tr '|' ' ') )
    [[ ${#pieces[@]} -lt 2 ]] && continue
    locations+=("location ${pieces[0]} { proxy_pass ${pieces[1]}; }")
done

# Write the nginx config file
IFS=$'\n'
echo "nginx-configure: Writing new locations to nginx config:"
echo "${locations[@]}"
perl -pe 's#__LOCATIONS__#'"${locations[*]}"'#' template-nginx-proxy.conf > /etc/nginx/conf.d/proxy.conf

# Create dhparams.pem if necessary
echo "nginx-configure: generating dhparams"
mkdir --parents "${SSL_DIR}"
export SSL_DIR
"${LE_WORKING_DIR}"/generate-dhparams.sh

# Get SSL certs
if [[ -n ${DOMAIN_NAME} ]]; then
    echo "nginx-configure: Setting up SSL certificate"
    mkdir --parent "${LE_WORKING_DIR}"
    cd "${LE_WORKING_DIR}"

    # Cert chain for stapling
    curl https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.pem -o "${LE_WORKING_DIR}"/lets-encrypt-x3-cross-signed.pem
    ln --symbolic --force "${LE_WORKING_DIR}"/lets-encrypt-x3-cross-signed.pem "${SSL_DIR}"/chain.pem

    # Generate SSL certs for this server
    ./acme.sh --issue -w /usr/share/nginx/html/ -d ${DOMAIN_NAME}
    ln --symbolic --force "${LE_WORKING_DIR}"/${DOMAIN_NAME}/${DOMAIN_NAME}.cer "${SSL_DIR}"/nginx.cer
    ln --symbolic --force "${LE_WORKING_DIR}"/${DOMAIN_NAME}/${DOMAIN_NAME}.key "${SSL_DIR}"/nginx.key
fi

# Start nginx
echo "nginx-configure: Starting nginx"
supervisorctl start nginx

