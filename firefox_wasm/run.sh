#!/usr/bin/with-contenv bashio
set -e

# SharedArrayBuffer needs a secure context. Resolve certs in order:
# 1. Supervisor present + ssl:true  -> user's /ssl certs
# 2. Supervisor present + ssl:false -> plain http (localhost-only warning)
# 3. No Supervisor (standalone `docker run` for local testing) -> self-signed
CERT="" KEY=""
if bashio::supervisor.ping >/dev/null 2>&1; then
  if bashio::config.true 'ssl'; then
    CERT="/ssl/$(bashio::config 'certfile')"
    KEY="/ssl/$(bashio::config 'keyfile')"
  else
    bashio::log.warning "SSL disabled: SharedArrayBuffer requires a secure context — the engine will NOT boot over plain http from a remote host"
    exec node /app/server.mjs
  fi
fi

if [ ! -f "${CERT}" ] || [ ! -f "${KEY}" ]; then
  CERT=/data/selfsigned.crt
  KEY=/data/selfsigned.key
  mkdir -p /data
  if [ ! -f "${CERT}" ]; then
    bashio::log.warning "No certificate found — generating a self-signed one (browser will warn once)"
    openssl req -x509 -newkey rsa:2048 -nodes -days 3650 \
      -subj "/CN=firefox-wasm" -keyout "${KEY}" -out "${CERT}"
  fi
fi

export SSL_CERT="${CERT}" SSL_KEY="${KEY}"
exec node /app/server.mjs
