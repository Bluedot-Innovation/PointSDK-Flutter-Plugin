import 'bluedot_point_sdk_platform_interface.dart';
import 'dart:io' show Platform;

class TempoBuilder {
  String channelId = "";
  String channelName = "";
  String androidNotificationTitle = "";
  String androidNotificationContent = "";
  int androidNotificationId = -1;

  String? iosNotificationTitle;
  String? iosNotificationButtonText;

  TempoBuilder androidNotification (String channelId, String channelName, String androidNotificationTitle, String androidNotificationContent, int androidNotificationId) {
    this.channelId = channelId;
    this.channelName = channelName;
    this.androidNotificationTitle = androidNotificationTitle;
    this.androidNotificationContent = androidNotificationContent;
    this.androidNotificationId = androidNotificationId;

    return this;
  }

  Future<void> start(String destinationId) {
    if (Platform.isAndroid) {
      return BluedotPointSdkPlatform.instance.androidStartTempoTracking(destinationId, channelId, channelName, androidNotificationTitle,
          androidNotificationContent, androidNotificationId);
    } else if (Platform.isIOS){
      return BluedotPointSdkPlatform.instance.iOSStartTempoTracking(destinationId);
    } else {
      return BluedotPointSdkPlatform.instance.unimplementedError();
    }
  }
}