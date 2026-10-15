import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bluedot_point_sdk/bluedot_point_sdk_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final platform = MethodChannelBluedotPointSdk();
  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final calls = <MethodCall>[];

  /// Stub replies keyed by method name. Methods not present here reply with
  /// `null`.
  Map<String, dynamic> stubReplies = {};

  setUp(() {
    calls.clear();
    stubReplies = {};
    messenger.setMockMethodCallHandler(platform.methodChannel, (call) async {
      calls.add(call);
      return stubReplies[call.method];
    });
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(platform.methodChannel, null);
  });

  group('GeoTriggering', () {
    test('androidStartGeoTriggering sends no arguments', () async {
      await platform.androidStartGeoTriggering();

      expect(calls, hasLength(1));
      expect(calls.single.method, 'androidStartGeoTriggering');
      expect(calls.single.arguments, isNull);
    });

    test('stopGeoTriggering sends no arguments', () async {
      await platform.stopGeoTriggering();

      expect(calls.single.method, 'stopGeoTriggering');
      expect(calls.single.arguments, isNull);
    });

    test('iOSStartGeoTriggering sends the iOS notification arguments', () async {
      await platform.iOSStartGeoTriggering('title', 'buttonText');

      expect(calls.single.method, 'iOSStartGeoTriggering');
      expect(calls.single.arguments, {
        'notificationTitle': 'title',
        'notificationButtonText': 'buttonText',
      });
    });
  });

  group('Tempo', () {
    test('androidStartTempoTracking sends only destinationId', () async {
      await platform.androidStartTempoTracking('destination-1');

      expect(calls, hasLength(1));
      expect(calls.single.method, 'androidStartTempoTracking');
      expect(calls.single.arguments, {'destinationId': 'destination-1'});
    });

    test('iOSStartTempoTracking sends only destinationId', () async {
      await platform.iOSStartTempoTracking('destination-2');

      expect(calls.single.method, 'iOSStartTempoTracking');
      expect(calls.single.arguments, {'destinationId': 'destination-2'});
    });

    test('stopTempoTracking sends no arguments', () async {
      await platform.stopTempoTracking();

      expect(calls.single.method, 'stopTempoTracking');
      expect(calls.single.arguments, isNull);
    });
  });

  group('Foreground service linking', () {
    test('linkForegroundService invokes linkForegroundService with no arguments', () async {
      await platform.linkForegroundService();

      expect(calls, hasLength(1));
      expect(calls.single.method, 'linkForegroundService');
      expect(calls.single.arguments, isNull);
    });

    test('unlinkForegroundService invokes unlinkForegroundService with no arguments', () async {
      await platform.unlinkForegroundService();

      expect(calls, hasLength(1));
      expect(calls.single.method, 'unlinkForegroundService');
      expect(calls.single.arguments, isNull);
    });

    test('isForegroundServiceLinked invokes isForegroundServiceLinked and returns the native reply', () async {
      stubReplies['isForegroundServiceLinked'] = true;

      final result = await platform.isForegroundServiceLinked();

      expect(calls.single.method, 'isForegroundServiceLinked');
      expect(calls.single.arguments, isNull);
      expect(result, isTrue);
    });
  });

  group('Misc', () {
    test('initialize sends projectId', () async {
      await platform.initialize('project-1');

      expect(calls.single.method, 'initialize');
      expect(calls.single.arguments, {'projectId': 'project-1'});
    });

    test('setCustomEventMetaData forwards the metadata map', () async {
      await platform.setCustomEventMetaData({'key': 'value'});

      expect(calls.single.method, 'setCustomEventMetaData');
      expect(calls.single.arguments, {'key': 'value'});
    });

    test('setZoneDisableByApplication sends zoneId and disable', () async {
      await platform.setZoneDisableByApplication('zone-1', true);

      expect(calls.single.method, 'setZoneDisableByApplication');
      expect(calls.single.arguments, {'zoneId': 'zone-1', 'disable': true});
    });

    test('reset sends no arguments', () async {
      await platform.reset();

      expect(calls.single.method, 'reset');
      expect(calls.single.arguments, isNull);
    });

    test('isInitialized, isGeoTriggeringRunning and isTempoRunning round-trip the native reply', () async {
      stubReplies['isInitialized'] = true;
      stubReplies['isGeoTriggeringRunning'] = false;
      stubReplies['isTempoRunning'] = true;

      expect(await platform.isInitialized(), isTrue);
      expect(await platform.isGeoTriggeringRunning(), isFalse);
      expect(await platform.isTempoRunning(), isTrue);
      expect(calls.map((c) => c.method), [
        'isInitialized',
        'isGeoTriggeringRunning',
        'isTempoRunning',
      ]);
    });
  });
}
