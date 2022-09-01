import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'bluedot_point_sdk_method_channel.dart';

abstract class BluedotPointSdkPlatform extends PlatformInterface {
  /// Constructs a BluedotPointSdkPlatform.
  BluedotPointSdkPlatform() : super(token: _token);

  static final Object _token = Object();

  static BluedotPointSdkPlatform _instance = MethodChannelBluedotPointSdk();

  /// The default instance of [BluedotPointSdkPlatform] to use.
  ///
  /// Defaults to [MethodChannelBluedotPointSdk].
  static BluedotPointSdkPlatform get instance => _instance;
  
  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [BluedotPointSdkPlatform] when
  /// they register themselves.
  static set instance(BluedotPointSdkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> initialize(String projectId) {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  Future<bool> isInitialized() {
    throw UnimplementedError('isInitialized() has not been implemented.');
  }

  Future<bool> isGeoTriggeringRunning() {
    throw UnimplementedError('isGeoTriggeringRunning() has not been implemented.');
  }

  Future<bool> isTempoRunning() {
    throw UnimplementedError('isTempoRunning() has not been implemented.');
  }

  Future<void> iOSStartGeoTriggering(String? notificationTitle, String? notificationButtonText) {
    throw UnimplementedError('iOSStartGeoTriggering() has not been implemented.');
  }

  Future<void> androidStartGeoTriggering(String? channelId, String? channelName, String? title, String? content, int? notificationId) {
    throw UnimplementedError('androidStartGeoTriggering() has not been implemented.');
  }

  Future<void> stopGeoTriggering() {
    throw UnimplementedError("stopGeoTriggering() has not been implemented.");
  }

  Future<void> iOSStartTempoTracking(String destinationId) {
    throw UnimplementedError("iOSStartTempoTracking() has not been implemented.");
  }

  Future<void> androidStartTempoTracking(String destinationId, String channelId, String channelName, String title, String content, int? notificationId) {
    throw UnimplementedError("androidStartTempoTracking() has not been implemented.");
  }

  Future<void> stopTempoTracking() {
    throw UnimplementedError("stopTempoTracking() has not been implemented.");
  }

  void setCustomEventMetaData(Map<String, String> metadata) {
    throw UnimplementedError("setCustomEventMetaData() has not been implemented.");
  }

  void setNotificationIdResourceId(int resourceId) {
    throw UnimplementedError("setNotificationIdResourceId() has not been implemented.");
  }

  void setZoneDisableByApplication(String zoneId, bool disable) {
    throw UnimplementedError("setZoneDisableByApplication() has not been implemented.");
  }

  Future<String> getInstallRef() {
    throw UnimplementedError("getInstallRef() has not been implemented.");
  }

  Future<String> getSDKVersion() {
    throw UnimplementedError("getSDKVersion() has not been implemented.");
  }

  Future<dynamic> getZonesAndFences() {
    throw UnimplementedError("getZonesAndFences() has not been implemented.");
  }

  Future<void> reset() {
    throw UnimplementedError("reset() has not been implemented.");
  }

  Future<void> unimplementedError() {
    throw UnimplementedError("Unimplemented Error");
  }
}
