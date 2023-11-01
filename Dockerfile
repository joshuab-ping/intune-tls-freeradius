FROM freeradius/freeradius-server:latest-alpine
COPY raddb/ /etc/raddb/
RUN rm -rf /var/tmp/radiusd
RUN mkdir -p /var/tmp/radiusd
