
import 'bluedot_point_sdk_platform_interface.dart';
import 'tempo_builder.dart';
import 'geo_triggering_builder.dart';

class BluedotPointSdk {
  static const geoTriggering = 'bluedot_point_flutter/geo_triggering_events';
  static const tempo = 'bluedot_point_flutter/tempo_events';
  static const bluedotService = 'bluedot_point_flutter/bluedot_service_events';

  /// The singleton instance of Bluedot Point SDK
  static final instance = BluedotPointSdk();

  /// Initialize SDK with [projectId]. You can find your [projectId] on Bluedot Canvas.
  ///
  /// If the initialization is successful, error will be returned as nil. However, if the initialization fails, an error will be provided.
  Future<void> initialize(String projectId) {
    return BluedotPointSdkPlatform.instance.initialize(projectId);
  }

  /// Method to determine if the Point SDK is initialized.
  ///
  /// Returns whether Bluedot Point SDK is initialized or not.
  Future<bool> isInitialized() {
    return BluedotPointSdkPlatform.instance.isInitialized();
  }

  /// Method to determine if GeoTriggering is running.
  ///
  /// Returns whether GeoTriggering is running.
  Future<bool> isGeoTriggeringRunning() {
    return BluedotPointSdkPlatform.instance.isGeoTriggeringRunning();
  }

  /// Method to determine if Tempo is running
  ///
  /// Returns whether Tempo is running
  Future<bool> isTempoRunning() {
    return BluedotPointSdkPlatform.instance.isTempoRunning();
  }

  /// Stop GeoTriggering features of the Bluedot Point SDK
  ///
  /// Stopping Geo-triggering feature has the intended effect of stopping location services on the device, thereby conserving battery on your user’s device unless another feature such as Tempo, is active.
  /// If the Geo-Triggering feature is stopped successful, error will be returned as nil. However, if the Stop Geo-Triggering fails, an error will be provided.
  Future<void> stopGeoTriggering() {
    return BluedotPointSdkPlatform.instance.stopGeoTriggering();
  }

  /// Stop Tempo Tracking
  ///
  /// If the Tempo is stopped successful, error will be returned as nil. However, if the Start Tempo fails, an error will be provided.
  Future<void> stopTempoTracking() {
    return BluedotPointSdkPlatform.instance.stopTempoTracking();
  }

  /// Sets custom metadata for Notification events.
  ///
  /// Only up to 20 custom meta data fields are allowed. Will throw an exception if the number of custom fields exceeded.
  /// The custom metadata set through this API will be available on the backend in check-in activity log and via webhooks.
  Future<void> setCustomEventMetaData(Map<String, String> metadata) {
    return BluedotPointSdkPlatform.instance.setCustomEventMetaData(metadata);
  }

  /// Sets notification icon for Android foreground notification.
  Future<void> setNotificationIcon(String icon) {
    return BluedotPointSdkPlatform.instance.setNotificationIcon(icon);
  }

  /// Disabled or re-enable a specific zone by its [zoneId].
  Future<void> setZoneDisableByApplication(String zoneId, bool disable) {
    return BluedotPointSdkPlatform.instance.setZoneDisableByApplication(zoneId, disable);
  }

  /// Returns the installation reference of this Point SDK enabled App.
  ///
  ///  This is the same as the Install Ref that appears in a Zone's Activity Log in Canvas, or queried via Open API.
  ///  This reference is randomly generated at the first run-time of the App and remains fixed for the duration of the App installation.
  Future<String> getInstallRef() {
    return BluedotPointSdkPlatform.instance.getInstallRef();
  }

  /// Returns the version of the Point SDK as a String.
  Future<String> getSDKVersion() {
    return BluedotPointSdkPlatform.instance.getSDKVersion();
  }

  /// Method to get a collection of `BDZoneInfo` objects, corresponding to the Zones you created for this project, in the Canvas interface.
  Future<dynamic> getZonesAndFences() {
    return BluedotPointSdkPlatform.instance.getZonesAndFences();
  }

  /// Reset Bluedot Point SDK (only if you wish to switch to a different projectId)
  ///
  /// Call this method only if you need to switch to a different projectId, this will reset the Bluedot Point SDK to its original state.
  /// Upon completion callback, you can make the call [initialize(String projectId)]  to initialize with a different projectId.
  Future<void> reset() {
    return BluedotPointSdkPlatform.instance.reset();
  }

  /// GeoTriggeringBuilder is use to build GeoTriggeringService object.
  GeoTriggeringBuilder geoTriggeringBuilder() {
    return GeoTriggeringBuilder();
  }

  /// TempoBuilder is use to build TempoService object
  TempoBuilder tempoBuilder() {
    return TempoBuilder();
  }

  /// Enable or disable background location updates (iOS only)
  ///
  /// For the background location usage indicator to work, allowsBackgroundLocationUpdates must be set to true while the app is in the foreground, and the app has While using the app location authorization.
  /// If allowsBackgroundLocationUpdates is set to true while the app is in the background, or the user changes the location permission to While using the app while the app is in the background, the background location usage indicator will not be enabled.
  /// The default value of allowsBackgroundLocationUpdates is false, and it can be disabled while the app is either in the foreground or the background.
  /// If the application requests Always location authorization, be sure to check that Always location authorization has not been granted before setting allowsBackgroundLocationUpdates to false, as setting the value to false will prevent the app from accessing location from the background.
  void allowsBackgroundLocationUpdates(bool value) {
    return BluedotPointSdkPlatform.instance.allowsBackgroundLocationUpdates(value);
  }

}

class GeoTriggeringEvents {
  static const onZoneInfoUpdate = 'onZoneInfoUpdate';
  static const didEnterZone = 'didEnterZone';
  static const didExitZone = 'didExitZone';
}

class TempoEvents {
  static const tempoTrackingStoppedWithError = 'tempoTrackingStoppedWithError';
}

class BluedotServiceEvents {
  static const onBluedotServiceError = 'onBluedotServiceError';

  // iOS-only events
  static const locationAuthorizationDidChange = 'locationAuthorizationDidChange';
  static const lowPowerModeDidChange = 'lowPowerModeDidChange';
  static const accuracyAuthorizationDidChange = 'accuracyAuthorizationDidChange';
}
