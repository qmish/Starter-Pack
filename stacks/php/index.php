<?php
declare(strict_types=1);

require __DIR__ . '/bootstrap.php';

use OpenTelemetry\API\Globals;

$serviceName = getenv('OTEL_SERVICE_NAME') ?: 'php-demo';
$path = $_SERVER['REQUEST_URI'] ?? '/';
if (strtok($path, '?') === '/health') {
    header('Content-Type: application/json');
    echo json_encode(['status' => 'ok', 'service' => $serviceName]);
    return;
}

$tracer = Globals::tracerProvider()->getTracer('php-demo', '1.0.0');
$span = $tracer->spanBuilder('handle_request')->startSpan();
try {
    header('Content-Type: application/json');
    echo json_encode([
        'message' => 'SigNoz PHP demo',
        'service' => $serviceName,
        'path' => $path,
    ]);
} finally {
    $span->end();
}
