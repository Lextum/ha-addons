# Firefox WASM — Home Assistant add-on repository

Run [firefox-wasm](https://github.com/HeyPuter/firefox-wasm) (Firefox's Gecko
engine compiled to WebAssembly) from Home Assistant. The engine runs in a
canvas in your browser; the add-on serves the prebuilt static site plus the
WISP networking proxy.

## Install

1. Home Assistant → Settings → Add-ons → Add-on Store → ⋮ → **Repositories**.
2. Add this repository URL.
3. Install **Firefox WASM**, start it, click **Open Web UI**.

See [firefox_wasm/DOCS.md](firefox_wasm/DOCS.md) for options and caveats
(SharedArrayBuffer requires HTTPS + a dedicated tab; ingress is not possible).
