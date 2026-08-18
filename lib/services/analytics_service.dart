/// Analytics is deliberately abstract so PostHog/Amplitude/etc. can be
/// connected without coupling product code to a vendor.
abstract interface class AnalyticsService {
  Future<void> track(String event, {Map<String, Object?> properties});
  Future<void> recordError(Object error, StackTrace stack, {String? context});
}

class NoopAnalyticsService implements AnalyticsService {
  const NoopAnalyticsService();
  @override
  Future<void> track(String event, {Map<String, Object?> properties = const {}}) async {}
  @override
  Future<void> recordError(Object error, StackTrace stack, {String? context}) async {}
}
