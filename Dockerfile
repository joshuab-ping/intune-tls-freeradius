FROM freeradius/freeradius-server:latest-alpine
COPY raddb/ /etc/raddb/

ENTRYPOINT ["docker-entrypoint.sh"]
