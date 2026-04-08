class TelemetryService {
  void log(String event) {
    // Basic implementation
  }
}

class Scheduler {
  final TelemetryService telemetry;
  Scheduler({required this.telemetry});
}
