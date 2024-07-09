import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'bluedot_point_sdk_platform_interface.dart';

/// An implementation of [BluedotPointSdkPlatform] that uses method channels.
class MethodChannelBluedotPointSdk extends BluedotPointSdkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('bluedot_point_flutter/bluedot_point_sdk');

  Future<void> initialize(String projectId) async {
    final initialize = await methodChannel.invokeMethod('initialize', {'projectId': projectId});
    return initialize;
  }

  Future<bool> isInitialized() async {
    final isInitialized = await methodChannel.invokeMethod('isInitialized');
    return isInitialized;
  }

  Future<bool> isGeoTriggeringRunning() async {
    final isGeoTriggeringRunning = await methodChannel.invokeMethod('isGeoTriggeringRunning');
    return isGeoTriggeringRunning;
  }

  Future<bool> isTempoRunning() async {
    final isTempoRunning = await methodChannel.invokeMethod('isTempoRunning');
    return isTempoRunning;
  }

  Future<void> iOSStartGeoTriggering(String? notificationTitle, String? notificationButtonText) async {
    final arguments = {'notificationTitle': notificationTitle, 'notificationButtonText': notificationButtonText};
    final iOSStartGeoTriggering = await methodChannel.invokeMethod('iOSStartGeoTriggering', arguments);
    return iOSStartGeoTriggering;
  }

  Future<void> stopGeoTriggering() async {
    final stopGeoTriggering = await methodChannel.invokeMethod('stopGeoTriggering');
    return stopGeoTriggering;
  }

  Future<void> androidStartGeoTriggering(String? channelId, String? channelName, String? title, String? content, int? notificationId) async {
    final arguments = {'channelId': channelId, 'channelName': channelName, 'title': title, 'content': content, 'notificationId': notificationId};
    final androidStartGeoTriggering = await methodChannel.invokeMethod('androidStartGeoTriggering', arguments);
    return androidStartGeoTriggering;
  }

  Future<void> iOSStartTempoTracking(String destinationId) async {
    final iOSStartTempoTracking = await methodChannel.invokeMethod('iOSStartTempoTracking', {'destinationId' : destinationId});
    return iOSStartTempoTracking;
  }

  Future<void> androidStartTempoTracking(String destinationId, String channelId, String channelName, String title, String content, int? notificationId) async {
    final arguments = {'destinationId': destinationId, 'channelId': channelId, 'channelName': channelName, 'title': title, 'content': content, 'notificationId': notificationId};
    final androidStartTempoTracking = await methodChannel.invokeMethod('androidStartTempoTracking', arguments);
    return androidStartTempoTracking;
  }

  Future<void> stopTempoTracking() async {
    final stopTempoTracking = await methodChannel.invokeMethod('stopTempoTracking');
    return stopTempoTracking;
  }

  Future<void> setCustomEventMetaData(Map<String, String> metadata) async {
    await methodChannel.invokeMethod('setCustomEventMetaData', metadata);
  }

  Future<void> setNotificationIcon(String icon) async {
    await methodChannel.invokeMethod('setNotificationIcon', {'icon' : icon});
  }

  Future<void> setZoneDisableByApplication(String zoneId, bool disable) async {
    await methodChannel.invokeMethod('setZoneDisableByApplication', {'zoneId': zoneId, 'disable': disable});
  }

  Future<String> getInstallRef() async {
    final installRef = await methodChannel.invokeMethod('getInstallRef');
    return installRef;
  }

  Future<String> getSDKVersion() async {
    final getSDKVersion = await methodChannel.invokeMethod('getSDKVersion');
    return getSDKVersion;
  }

  Future<dynamic> getZonesAndFences() async {
    final getZonesAndFences = await methodChannel.invokeMethod('getZonesAndFences');
    return getZonesAndFences;
  }

  Future<dynamic> getCustomEventMetaData() async {
      final getCustomEventMetaData = await methodChannel.invokeMethod('getCustomEventMetaData');
      return getCustomEventMetaData;
  }

  Future<void> reset() async {
    final resetSDK = await methodChannel.invokeMethod('reset');
    return resetSDK;
  }

  void backgroundLocationAccessForWhileUsing(bool value) async {
    await methodChannel.invokeMethod('backgroundLocationAccessForWhileUsing', {'value': value});
  }

}

