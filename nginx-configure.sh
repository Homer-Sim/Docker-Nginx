#!/bin/bash
set -eu

SSL_DIR=${SSL_DIR:-/etc/nginx/ssl}
LE_WORKING_DIR=${LE_WORKING_DIR:-/letsencrypt}

# Get SSL certs
if [[ -n ${DOMAIN_NAME} ]]; then
    pushd "${LE_WORKING_DIR}" > /dev/null

    echo "nginx-configure: starting nginx to authenticate SSL certs"
    cp "${LE_WORKING_DIR}"/letsencrypt-nginx.conf /etc/nginx/conf.d/
    supervisorctl start nginx

    # Cert chain for stapling
    curl https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.pem -o "${LE_WORKING_DIR}"/lets-encrypt-x3-cross-signed.pem
    mkdir --parents "${SSL_DIR}"
    ln --symbolic --force "${LE_WORKING_DIR}"/lets-encrypt-x3-cross-signed.pem "${SSL_DIR}"/chain.pem

    # Generate SSL certs for this server
    echo "nginx-configure: Setting up SSL certificate"
    ./acme.sh --issue -w /usr/share/nginx/html/ -d ${DOMAIN_NAME}

    ln --symbolic --force "${LE_WORKING_DIR}"/${DOMAIN_NAME}/${DOMAIN_NAME}.cer "${SSL_DIR}"/nginx.cer
    ln --symbolic --force "${LE_WORKING_DIR}"/${DOMAIN_NAME}/${DOMAIN_NAME}.key "${SSL_DIR}"/nginx.key

    echo "nginx-configure: stopping nginx"
    supervisorctl stop nginx
    popd > /dev/null
fi

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
perl -pe 's#__LOCATIONS__#'"${locations[*]}"'#' /nginx-configure/template-nginx-proxy.conf > /etc/nginx/conf.d/proxy.conf

# Create dhparams.pem if necessary
echo "nginx-configure: generating dhparams"
mkdir --parents "${SSL_DIR}"
export SSL_DIR
"${LE_WORKING_DIR}"/generate-dhparams.sh

# Start nginx
echo "nginx-configure: Starting nginx"
supervisorctl start nginx

