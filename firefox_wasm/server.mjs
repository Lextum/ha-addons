// Static server for the firefox-wasm chrome-demo + WISP proxy at /wisp.
// COOP/COEP headers are mandatory: the engine needs SharedArrayBuffer,
// which requires a cross-origin-isolated (and secure) context.
import { createServer as https } from 'node:https';
import { createServer as http } from 'node:http';
import { readFileSync, statSync, existsSync, createReadStream } from 'node:fs';
import { join, normalize, extname, sep } from 'node:path';
import { server as wisp } from '@mercuryworkshop/wisp-js/server';

const ROOT = process.env.WWW_ROOT || '/app/www';
const PORT = Number(process.env.PORT) || 8080;

const MIME = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'text/javascript',
  '.mjs': 'text/javascript',
  '.css': 'text/css',
  '.json': 'application/json',
  '.wasm': 'application/wasm',
  '.svg': 'image/svg+xml',
  '.png': 'image/png',
  '.ico': 'image/x-icon',
  '.zst': 'application/octet-stream',
};

function handler(req, res) {
  let path;
  try {
    path = decodeURIComponent((req.url || '/').split('?')[0]);
  } catch {
    res.writeHead(400).end('bad request');
    return;
  }
  if (path.endsWith('/')) path += 'index.html';
  const file = normalize(join(ROOT, path));
  if (!file.startsWith(ROOT + sep) || !existsSync(file) || !statSync(file).isFile()) {
    res.writeHead(404).end('not found');
    return;
  }
  res.writeHead(200, {
    'Content-Type': MIME[extname(file)] ?? 'application/octet-stream',
    // Content-Length so the demo's download progress bar has a total.
    'Content-Length': statSync(file).size,
    'Cross-Origin-Opener-Policy': 'same-origin',
    'Cross-Origin-Embedder-Policy': 'require-corp',
    'Cache-Control': 'no-cache',
  });
  createReadStream(file).pipe(res);
}

const cert = process.env.SSL_CERT;
const key = process.env.SSL_KEY;
const server = cert
  ? https({ cert: readFileSync(cert), key: readFileSync(key) }, handler)
  : http(handler);

server.on('upgrade', (req, socket, head) => {
  if ((req.url || '').startsWith('/wisp')) wisp.routeRequest(req, socket, head);
  else socket.destroy();
});

server.listen(PORT, () =>
  console.log(`firefox-wasm: serving on ${cert ? 'https' : 'http'}://0.0.0.0:${PORT} (wisp at /wisp)`),
);
