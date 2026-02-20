<?php
declare(strict_types=1);
/**
 * Bootstrap OpenTelemetry for SigNoz.
 * Include before application code: require __DIR__ . '/bootstrap.php';
 * Environment: OTEL_EXPORTER_OTLP_ENDPOINT (default http://localhost:4318),
 * OTEL_SERVICE_NAME, OTEL_EXPORTER_OTLP_HEADERS, OTEL_RESOURCE_ATTRIBUTES.
 * Graceful shutdown via setAutoShutdown(true).
 */
require __DIR__ . '/vendor/autoload.php';

use OpenTelemetry\Contrib\Otlp\LogsExporterFactory;
use OpenTelemetry\Contrib\Otlp\MetricExporterFactory;
use OpenTelemetry\Contrib\Otlp\OtlpHttpTransportFactory;
use OpenTelemetry\Contrib\Otlp\SpanExporter;
use OpenTelemetry\SDK\Logs\LoggerProvider;
use OpenTelemetry\SDK\Logs\Processor\BatchLogRecordProcessor;
use OpenTelemetry\SDK\Metrics\MeterProvider;
use OpenTelemetry\SDK\Metrics\MetricReader\ExportingReader;
use OpenTelemetry\SDK\Resource\ResourceInfoFactory;
use OpenTelemetry\SDK\Sdk;
use OpenTelemetry\SDK\Trace\SpanProcessor\BatchSpanProcessor;
use OpenTelemetry\SDK\Trace\TracerProvider;

$endpoint = getenv('OTEL_EXPORTER_OTLP_ENDPOINT') ?: 'http://localhost:4318';
$transport = (new OtlpHttpTransportFactory())->create($endpoint, 'application/x-protobuf');
$exporter = new SpanExporter($transport);
$tracerProvider = TracerProvider::builder()
    ->addSpanProcessor(new BatchSpanProcessor($exporter))
    ->setResource(ResourceInfoFactory::defaultResource())
    ->build();

$metricExporter = (new MetricExporterFactory())->create();
$meterProvider = MeterProvider::builder()
    ->addReader(new ExportingReader($metricExporter))
    ->setResource(ResourceInfoFactory::defaultResource())
    ->build();

$logsExporter = (new LogsExporterFactory())->create();
$loggerProvider = LoggerProvider::builder()
    ->addLogRecordProcessor(new BatchLogRecordProcessor($logsExporter))
    ->setResource(ResourceInfoFactory::defaultResource())
    ->build();

Sdk::builder()
    ->setTracerProvider($tracerProvider)
    ->setMeterProvider($meterProvider)
    ->setLoggerProvider($loggerProvider)
    ->setAutoShutdown(true)
    ->buildAndRegisterGlobal();
