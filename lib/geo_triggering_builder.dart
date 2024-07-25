import 'bluedot_point_sdk_platform_interface.dart';
import 'dart:io' show Platform;

class GeoTriggeringBuilder {
  String? channelId;
  String? channelName;
  String? androidNotificationTitle;
  String? androidNotificationContent;
  int androidNotificationId = -1;

  String? iosAppRestartNotificationTitle;
  String? iosAppRestartNotificationButtonText;

  /// Set parameters for foreground service notification. Only required for apps targeting Android O and above.
  GeoTriggeringBuilder androidNotification(String? channelId, String? channelName, String? androidNotificationTitle, String? androidNotificationContent, int androidNotificationId) {
    this.channelId = channelId;
    this.channelName = channelName;
    this.androidNotificationTitle = androidNotificationTitle;
    this.androidNotificationContent = androidNotificationContent;
    this.androidNotificationId = androidNotificationId;
    return this;
  }

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
  Future<void> start() {
    if (Platform.isAndroid) {
      return BluedotPointSdkPlatform.instance.androidStartGeoTriggering(channelId, channelName, androidNotificationTitle, androidNotificationContent, androidNotificationId);
    } else if (Platform.isIOS) {
      return BluedotPointSdkPlatform.instance.iOSStartGeoTriggering(iosAppRestartNotificationTitle, iosAppRestartNotificationButtonText);
    } else {
      return BluedotPointSdkPlatform.instance.unimplementedError();
    }
  }
}