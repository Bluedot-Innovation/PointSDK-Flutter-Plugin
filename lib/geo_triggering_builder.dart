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

  GeoTriggeringBuilder androidNotification(String? channelId, String? channelName, String? androidNotificationTitle, String? androidNotificationContent, int androidNotificationId) {
    this.channelId = channelId;
    this.channelName = channelName;
    this.androidNotificationTitle = androidNotificationTitle;
    this.androidNotificationContent = androidNotificationContent;
    this.androidNotificationId = androidNotificationId;
    return this;
  }

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