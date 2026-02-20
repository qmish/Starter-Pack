'use strict';

const http = require('http');

const PORT = process.env.PORT || 8080;

const serviceName = process.env.OTEL_SERVICE_NAME || 'node-demo';
const server = http.createServer((req, res) => {
  if (req.url === '/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    return res.end(JSON.stringify({ status: 'ok', service: serviceName }));
  }
  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({
    message: 'SigNoz Node.js demo',
    service: serviceName,
    path: req.url,
  }));
});

server.listen(PORT, () => {
  console.log(`Server listening on http://localhost:${PORT}`);
  console.log('Send requests to see traces in SigNoz (OTLP to localhost:4317).');
});

process.on('SIGTERM', () => {
  server.close(() => process.exit(0));
});
