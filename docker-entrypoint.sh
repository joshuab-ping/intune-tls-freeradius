.env
rm -rf /var/tmp/radiusd
mkdir -p /var/tmp/radiusd

envsubst <"/etc/freeradius/raddb/mods-enabled/eap.tmpl" >"/etc/freeradius/raddb/mods-enabled/eap"
envsubst <"/etc/freeradius/raddb/clients.conf.tmpl" >"/etc/freeradius/raddb/clients.conf"
