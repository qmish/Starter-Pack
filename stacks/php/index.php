<?php
declare(strict_types=1);

require __DIR__ . '/vendor/autoload.php';

use OpenTelemetry\API\Globals;

$tracer = Globals::tracerProvider()->getTracer('php-demo', '1.0.0');
$span = $tracer->spanBuilder('handle_request')->startSpan();

try {
    $serviceName = getenv('OTEL_SERVICE_NAME') ?: 'php-demo';
    header('Content-Type: application/json');
    echo json_encode([
        'message' => 'SigNoz PHP demo',
        'service' => $serviceName,
        'path' => $_SERVER['REQUEST_URI'] ?? '/',
    ]);
} finally {
    $span->end();
}
