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
 && rm -rf /tmp/chrome-demo.tar.gz /tmp/dist

RUN npm install --omit=dev @mercuryworkshop/wisp-js@^0.4.1

COPY server.mjs run.sh /app/
RUN chmod +x /app/run.sh

CMD ["/app/run.sh"]
