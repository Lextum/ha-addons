#!/usr/bin/with-contenv bashio
set -e

# SharedArrayBuffer needs a secure context: use the user's /ssl certs when
# present, otherwise fall back to a persistent self-signed cert in /data.
if bashio::config.true 'ssl'; then
  CERT="/ssl/$(bashio::config 'certfile')"
  KEY="/ssl/$(bashio::config 'keyfile')"
  if [ ! -f "${CERT}" ] || [ ! -f "${KEY}" ]; then
    CERT=/data/selfsigned.crt
    KEY=/data/selfsigned.key
    if [ ! -f "${CERT}" ]; then
      bashio::log.warning "No certificate in /ssl — generating a self-signed one (browser will warn once)"
      openssl req -x509 -newkey rsa:2048 -nodes -days 3650 \
        -subj "/CN=firefox-wasm" -keyout "${KEY}" -out "${CERT}"
    fi
  fi
  export SSL_CERT="${CERT}" SSL_KEY="${KEY}"
else
  bashio::log.warning "SSL disabled: SharedArrayBuffer requires a secure context — the engine will NOT boot over plain http from a remote host"
fi

exec node /app/server.mjs
