FROM cseelye/rpi-nginx-base
MAINTAINER Carl Seelye <cseelye@gmail.com>

ENV LE_WORKING_DIR=/letsencrypt

RUN apt-get update && \
    apt-get install --assume-yes curl && \
    mkdir --parents "$LE_WORKING_DIR" && \
    curl https://raw.githubusercontent.com/Neilpang/acme.sh/master/acme.sh --output /tmp/acme.sh && \
    chmod 755 /tmp/acme.sh && \
    cd /tmp && \
    ./acme.sh install nocron

COPY nginx-configure.sh template-nginx-proxy.conf /nginx-configure/
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

