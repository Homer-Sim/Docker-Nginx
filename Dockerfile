FROM cseelye/rpi-nginx-base
MAINTAINER Carl Seelye <cseelye@gmail.com>

COPY nginx-configure.sh template-nginx-proxy.conf /nginx-configure/
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

