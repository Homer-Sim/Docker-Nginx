FROM cseelye/rpi-nginx-base
MAINTAINER Carl Seelye <cseelye@gmail.com>

ENV LE_WORKING_DIR=/letsencrypt SSL_DIR=/etc/nginx/ssl

RUN [ "cross-build-start" ]
RUN apt-get update && \
    apt-get install --assume-yes curl && \
    mkdir --parents "$LE_WORKING_DIR" && \
    mkdir --parents "$SSL_DIR" && \
    curl https://raw.githubusercontent.com/Neilpang/acme.sh/master/acme.sh --output /tmp/acme.sh && \
    chmod 755 /tmp/acme.sh && \
    cd /tmp && \
    ./acme.sh install nocron
COPY generate-dhparams.sh letsencrypt-nginx.conf $LE_WORKING_DIR/
COPY nginx-configure.sh template-nginx-proxy.conf /nginx-configure/
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN [ "cross-build-end" ]
