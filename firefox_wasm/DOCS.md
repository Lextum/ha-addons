# Firefox WASM add-on

Runs [firefox-wasm](https://github.com/HeyPuter/firefox-wasm) — the Gecko engine
compiled to WebAssembly — served from your Home Assistant box. Firefox renders
into a canvas in *your* browser; the add-on only serves the static site and the
WISP network proxy the engine uses for TCP.

## Usage

1. Install and start the add-on.
2. Click **Open Web UI**. It opens `https://<ha-host>:8080` in a new tab.
3. With the default self-signed certificate your browser shows a warning once —
   accept it. First load downloads ~50 MB of engine assets.

## Why no ingress / sidebar panel?

The engine needs `SharedArrayBuffer`, which requires the **top-level** page to
be cross-origin isolated (COOP/COEP headers). Inside the Home Assistant UI
iframe that is impossible, so the add-on must be opened directly in its own tab.

## Why SSL?

`SharedArrayBuffer` also requires a secure context. Plain `http://<lan-ip>` is
not secure, so with `ssl: false` the engine will not boot (unless you access it
via `localhost` or add the origin to your browser's insecure-origin allowlist).
If you have the Let's Encrypt / DuckDNS add-on, point `certfile`/`keyfile` at
those certs for a warning-free experience.

## Options

| Option | Default | Description |
|---|---|---|
| `ssl` | `true` | Serve HTTPS. Uses `/ssl/<certfile>` if present, else a generated self-signed cert. |
| `certfile` | `fullchain.pem` | Certificate in `/ssl`. |
| `keyfile` | `privkey.pem` | Private key in `/ssl`. |

## Security note

The `/wisp` endpoint is a TCP proxy used by the engine for networking. Anyone
who can reach port 8080 on your LAN can proxy TCP through it. Do **not** expose
this port to the internet.
