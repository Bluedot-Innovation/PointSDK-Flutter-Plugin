import 'bluedot_point_sdk_platform_interface.dart';
import 'dart:io' show Platform;

class GeoTriggeringBuilder {
  String? iosAppRestartNotificationTitle;
  String? iosAppRestartNotificationButtonText;

  /// Set parameters for iOS Restart notification.
  GeoTriggeringBuilder iosNotification(String? iosAppRestartNotificationTitle, String? iosAppRestartNotificationButtonText) {
    this.iosAppRestartNotificationTitle = iosAppRestartNotificationTitle;
    this.iosAppRestartNotificationButtonText = iosAppRestartNotificationButtonText;
    return this;
  }

  /// Start GeoTriggering features of the Bluedot Point SDK
  ///
  /// You can start Geo-triggering feature __only__ while your App is in the Foreground.
  /// An error will be returned if your App does not have either __Always__ or __When In Use__ location permission.
  /// If the  GeoTriggering feature is started successful, error will be returned as nil. However, if the Start GeoTriggering feature fails, an error will be provided.
  ///
  /// ### Android
  /// GeoTriggering always runs via a background worker, with or without a linked
  /// foreground service. The Point SDK no longer starts or displays its own foreground
  /// service notification. If you want low-latency triggers, start and foreground your
  /// own `Service` and call [BluedotPointSdk.linkForegroundService] before calling
  /// [start] — this is entirely optional for GeoTriggering.
  Future<void> start() {
    if (Platform.isAndroid) {
      return BluedotPointSdkPlatform.instance.androidStartGeoTriggering();
    } else if (Platform.isIOS) {
      return BluedotPointSdkPlatform.instance.iOSStartGeoTriggering(iosAppRestartNotificationTitle, iosAppRestartNotificationButtonText);
    } else {
      return BluedotPointSdkPlatform.instance.unimplementedError();
    }
  }
}