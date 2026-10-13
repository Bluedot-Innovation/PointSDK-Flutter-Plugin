import 'dart:io' show Platform;

import 'bluedot_point_sdk_platform_interface.dart';
import 'tempo_builder.dart';
import 'geo_triggering_builder.dart';

class BluedotPointSdk {
  static const geoTriggering = 'bluedot_point_flutter/geo_triggering_events';
  static const tempo = 'bluedot_point_flutter/tempo_events';
  static const bluedotService = 'bluedot_point_flutter/bluedot_service_events';

  /// The singleton instance of Bluedot Point SDK
  static final instance = BluedotPointSdk();

  /// Initialize PointSDK with [projectId]. You can find your [projectId] on Bluedot
  /// Canvas portal.
  ///
  /// If the initialization is successful, error will be returned as nil.
  /// Otherwise, an error will be provided.
  Future<void> initialize(String projectId) {
    return BluedotPointSdkPlatform.instance.initialize(projectId);
  }

  /// Method to determine if the PointSDK is initialized.
  ///
  /// Returns `true` if PointSDK is initialized, `false` otherwise.
  Future<bool> isInitialized() {
    return BluedotPointSdkPlatform.instance.isInitialized();
  }

  /// Method to determine if GeoTriggering is running.
  ///
  /// Returns `true` if GeoTriggering is running, `false` otherwise.
  Future<bool> isGeoTriggeringRunning() {
    return BluedotPointSdkPlatform.instance.isGeoTriggeringRunning();
  }

  /// Method to determine if Tempo is running
  ///
  /// Returns `true` if Tempo is running, `false` otherwise.
  Future<bool> isTempoRunning() {
    return BluedotPointSdkPlatform.instance.isTempoRunning();
  }

  /// Stops GeoTriggering feature of the Bluedot PointSDK
  ///
  /// Stopping Geo-triggering feature has the intended effect of stopping
  /// location services on the device, thereby conserving battery on your
  /// user’s device unless another feature such as Tempo, is active.
  /// If  Geo-Triggering feature is stopped successfully, error will be
  /// returned as nil. Otherwise, an error will be provided.
  Future<void> stopGeoTriggering() {
    return BluedotPointSdkPlatform.instance.stopGeoTriggering();
  }

  /// Stops Tempo Tracking
  ///
  /// If the Tempo is stopped successfully, error will be returned as nil.
  /// Otherwise, an error will be provided.
  Future<void> stopTempoTracking() {
    return BluedotPointSdkPlatform.instance.stopTempoTracking();
  }

  /// Sets custom metadata for Notification events.
  ///
  /// Only up to 20 custom meta data fields are allowed.
  /// Will throw an exception if the number of custom fields exceeds the limit.
  /// The custom metadata set through this API will be available on the backend
  /// in check-in activity log and via webhooks.
  Future<void> setCustomEventMetaData(Map<String, String> metadata) {
    return BluedotPointSdkPlatform.instance.setCustomEventMetaData(metadata);
  }

  /// Disable or re-enable a specific zone by its [zoneId].
  Future<void> setZoneDisableByApplication(String zoneId, bool disable) {
    return BluedotPointSdkPlatform.instance
        .setZoneDisableByApplication(zoneId, disable);
  }

  /// Returns the installation reference of this PointSDK enabled App.
  ///
  /// This is the same as the Install Ref that appears in a Zone's Activity Log
  /// in Canvas, or queried via Open API.
  /// This reference is randomly generated at the first run-time of the App and
  /// remains fixed for the duration of the App installation.
  Future<String> getInstallRef() {
    return BluedotPointSdkPlatform.instance.getInstallRef();
  }

  /// Returns the version of the Point SDK as a String.
  Future<String> getSDKVersion() {
    return BluedotPointSdkPlatform.instance.getSDKVersion();
  }

  /// Returns a collection of `BDZoneInfo` objects, corresponding to the
  /// Zones created for this project in the Canvas portal.
  Future<dynamic> getZonesAndFences() {
    return BluedotPointSdkPlatform.instance.getZonesAndFences();
  }

  /// Returns a collection of `CustomEventMetaData` objects, corresponding to the
  /// HashMap of Key Value Pairs <String, String>
  Future<dynamic> getCustomEventMetaData() {
    return BluedotPointSdkPlatform.instance.getCustomEventMetaData();
  }

  /// Reset Bluedot PointSDK (only if you wish to switch to a different projectId)
  ///
  /// Call this method only if you need to switch to a different projectId,
  /// this will reset the Bluedot Point SDK to its original state.
  /// Upon completion callback, you can call [initialize(String projectId)]
  /// to initialize with a different projectId.
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
  /// For the background location usage indicator to work,
  /// `backgroundLocationAccessForWhileUsing` must be set to `true` while the app is in
  /// the foreground, and the app has `While using` location authorization.
  /// If `backgroundLocationAccessForWhileUsing` is set to `true` while the app is in
  /// the background, or the user changes the location permission to `While using`
  /// while the app is in the background, the background location usage
  /// indicator will not be enabled.
  ///
  /// The default value of `backgroundLocationAccessForWhileUsing` is `false`, and it
  /// can be disabled while the app is either in the foreground or background.
  /// If the application requests `Always` location authorization, be sure to
  /// check that `Always` location authorization has not been granted before
  /// setting `backgroundLocationAccessForWhileUsing` to `false`, as setting the value
  /// to `false` will prevent the app from accessing location from the background.
  void backgroundLocationAccessForWhileUsing(bool value) {
    return BluedotPointSdkPlatform.instance
        .backgroundLocationAccessForWhileUsing(value);
  }

  /// Android only. No-op on iOS.
  ///
  /// The Point SDK no longer declares, starts, or displays its own foreground
  /// service. Your app is responsible for implementing, starting and
  /// foregrounding its own `Service` (with its own persistent notification).
  /// Call this once that service has successfully called `startForeground()`
  /// to link it to the Point SDK:
  ///
  /// - GeoTriggering always runs via a background worker, with or without a
  ///   linked foreground service — linking it is optional and only reduces
  ///   location-update latency.
  /// - Tempo __requires__ a linked foreground service in order to start.
  ///   Calling [TempoBuilder.start] with none linked fails synchronously.
  ///
  /// If the linked foreground service later stops ([unlinkForegroundService]
  /// is called, or the service process is killed) while Tempo is tracking,
  /// Tempo stops and reports it asynchronously via the
  /// `tempoTrackingStoppedWithError` event with
  /// `isForegroundServiceNotLinked: true`.
  ///
  /// There is a single, shared link state, not one per feature — if your app
  /// uses both GeoTriggering and Tempo, share one foreground service and one
  /// link for both.
  Future<void> linkForegroundService() {
    if (Platform.isAndroid) {
      return BluedotPointSdkPlatform.instance.linkForegroundService();
    }
    return Future.value();
  }

  /// Android only. No-op on iOS.
  ///
  /// Unlinks the foreground service previously linked via
  /// [linkForegroundService]. Call this when your foreground service is
  /// stopping, e.g. from its `onDestroy()`.
  Future<void> unlinkForegroundService() {
    if (Platform.isAndroid) {
      return BluedotPointSdkPlatform.instance.unlinkForegroundService();
    }
    return Future.value();
  }

}

class GeoTriggeringEvents {
  static const didUpdateZoneInfo = 'didUpdateZoneInfo';
  static const didEnterZone = 'didEnterZone';
  static const didExitZone = 'didExitZone';
  static const didDwellInZone = 'didDwellInZone';
}

class TempoEvents {
  /// Fired when Tempo stops because of an error.
  ///
  /// On Android, the event arguments include `code`, `message` and `details`.
  /// If Tempo stopped because the linked foreground service went away mid
  /// session (see [BluedotPointSdk.linkForegroundService]), the arguments
  /// also include `isForegroundServiceNotLinked: true` — handle this
  /// explicitly if your app uses Tempo, e.g. by re-linking a foreground
  /// service and restarting Tempo, or by updating the UI to reflect that
  /// tracking has stopped.
  static const tempoTrackingStoppedWithError = 'tempoTrackingStoppedWithError';
  static const tempoTrackingDidUpdate = 'tempoTrackingDidUpdate';
}

class BluedotServiceEvents {
  static const onBluedotServiceError = 'onBluedotServiceError';

  // iOS-only events
  static const locationAuthorizationDidChange =
      'locationAuthorizationDidChange';
  static const lowPowerModeDidChange = 'lowPowerModeDidChange';
  static const accuracyAuthorizationDidChange =
      'accuracyAuthorizationDidChange';
}
