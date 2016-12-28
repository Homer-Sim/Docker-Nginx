#!/bin/bash
SSL_DIR=${SSL_DIR:-/etc/nginx/ssl}

mkdir --parents "${SSL_DIR}"
if [[ ! -f "${SSL_DIR}"/dhparams.pem ]]; then
    time openssl dhparam 2048 -out "${SSL_DIR}"/dhparams.pem
fi

