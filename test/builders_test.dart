import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bluedot_point_sdk/geo_triggering_builder.dart';
import 'package:bluedot_point_sdk/tempo_builder.dart';
import 'package:bluedot_point_sdk/bluedot_point_sdk_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // These tests run on the host test platform (never Android or iOS), so
  // both builders fall through to `unimplementedError()`. That is enough to
  // prove they dispatch through BluedotPointSdkPlatform.instance rather than
  // touching the method channel directly, without needing to fake
  // dart:io's Platform.
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

  test('GeoTriggeringBuilder.start() throws UnimplementedError off Android/iOS', () {
    expect(() => GeoTriggeringBuilder().start(), throwsA(isA<UnimplementedError>()));
    expect(calls, isEmpty);
  });

  test('TempoBuilder.start() throws UnimplementedError off Android/iOS', () {
    expect(() => TempoBuilder().start('destination-1'), throwsA(isA<UnimplementedError>()));
    expect(calls, isEmpty);
  });
}
