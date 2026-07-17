# Supervisor 2026.04.0+ no longer injects BUILD_FROM; use the multi-arch base directly.
FROM ghcr.io/home-assistant/base:3.21

ARG BUILD_ARCH=amd64
ARG BUILD_VERSION=1.0.0
LABEL \
  io.hass.version="${BUILD_VERSION}" \
  io.hass.type="app" \
  io.hass.arch="${BUILD_ARCH}"

# Prebuilt chrome-demo (static Vite site) from the firefox-wasm release —
# building Gecko->wasm from source needs ~26 GB disk + hours; never do it here.
ARG FFWASM_VERSION=v0.0.1

RUN apk add --no-cache nodejs npm openssl curl

WORKDIR /app

RUN curl -fsSL -o /tmp/chrome-demo.tar.gz \
      "https://github.com/HeyPuter/firefox-wasm/releases/download/${FFWASM_VERSION}/chrome-demo-${FFWASM_VERSION}.tar.gz" \
 && mkdir -p /app/www \
 && tar -xzf /tmp/chrome-demo.tar.gz -C /tmp \
 && mv /tmp/dist/* /app/www/ \
 && rm -rf /tmp/chrome-demo.tar.gz /tmp/dist \
 # The release demo hardcodes fetching its WISP relay URL from puter.work,
 # which rejects unknown origins ("not authorized"). Flip the flag so the
 # demo falls back to same-origin /wisp/ (this add-on's own proxy).
 # grep guards the build: fails loudly if a new release changes the minified name.
 && grep -rl 'const F=!0' /app/www/assets | xargs sed -i 's/const F=!0/const F=!1/'

# bufferutil (hard dep of wisp-js) ships no aarch64-musl prebuild; compile it.
RUN apk add --no-cache --virtual .build-deps python3 make g++ \
 && npm install --omit=dev @mercuryworkshop/wisp-js@^0.4.1 \
 && apk del .build-deps

COPY server.mjs run.sh /app/
RUN chmod +x /app/run.sh

CMD ["/app/run.sh"]
