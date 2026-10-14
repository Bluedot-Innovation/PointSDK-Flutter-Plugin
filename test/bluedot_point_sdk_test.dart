import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bluedot_point_sdk/bluedot_point_sdk.dart';
import 'package:bluedot_point_sdk/bluedot_point_sdk_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // These tests run on the host test platform (macOS/Linux/Windows), i.e.
  // never Android, so they exercise the "off Android" branch of the public
  // API without needing to fake dart:io's Platform.
  final methodChannel = BluedotPointSdkPlatform.instance.methodChannel;
  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    messenger.setMockMethodCallHandler(methodChannel, (call) async {
      calls.add(call);
      return null;
    });
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(methodChannel, null);
  });

  group('Foreground service linking off Android', () {
    test('linkForegroundService resolves without touching the method channel', () async {
      await BluedotPointSdk.instance.linkForegroundService();

      expect(calls, isEmpty);
    });

    test('unlinkForegroundService resolves without touching the method channel', () async {
      await BluedotPointSdk.instance.unlinkForegroundService();

      expect(calls, isEmpty);
    });

    test('isForegroundServiceLinked returns false without touching the method channel', () async {
      final result = await BluedotPointSdk.instance.isForegroundServiceLinked();

      expect(result, isFalse);
      expect(calls, isEmpty);
    });
  });

  group('Event name constants', () {
    test('GeoTriggeringEvents exposes the expected channel event names', () {
      expect(GeoTriggeringEvents.didUpdateZoneInfo, 'didUpdateZoneInfo');
      expect(GeoTriggeringEvents.didEnterZone, 'didEnterZone');
      expect(GeoTriggeringEvents.didExitZone, 'didExitZone');
      expect(GeoTriggeringEvents.didDwellInZone, 'didDwellInZone');
    });

    test('TempoEvents exposes the expected channel event names', () {
      expect(TempoEvents.tempoTrackingStoppedWithError, 'tempoTrackingStoppedWithError');
      expect(TempoEvents.tempoTrackingDidUpdate, 'tempoTrackingDidUpdate');
    });
  });
}
