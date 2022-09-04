
import 'bluedot_point_sdk_platform_interface.dart';
import 'tempo_builder.dart';
import 'geo_triggering_builder.dart';

class BluedotPointSdk {
  static const GEO_TRIGGERING = "bluedot_point_flutter/geo_triggering_events";
  static const TEMPO = "bluedot_point_flutter/tempo_events";
  static const BLUEDOT_SERVICE = "bluedot_point_flutter/bluedot_service_events";

  Future<void> initialize(String projectId) {
    return BluedotPointSdkPlatform.instance.initialize(projectId);
  }

  Future<bool> isInitialized() {
    return BluedotPointSdkPlatform.instance.isInitialized();
  }

  Future<bool> isGeoTriggeringRunning() {
    return BluedotPointSdkPlatform.instance.isGeoTriggeringRunning();
  }

  Future<bool> isTempoRunning() {
    return BluedotPointSdkPlatform.instance.isTempoRunning();
  }

  Future<void> stopGeoTriggering() {
    return BluedotPointSdkPlatform.instance.stopGeoTriggering();
  }

  Future<void> stopTempoTracking() {
    return BluedotPointSdkPlatform.instance.stopTempoTracking();
  }

  void setCustomEventMetaData(Map<String, String> metadata) {
    return BluedotPointSdkPlatform.instance.setCustomEventMetaData(metadata);
  }

  void setNotificationIdResourceId(int resourceId) {
    return BluedotPointSdkPlatform.instance.setNotificationIdResourceId(resourceId);
  }

  void setZoneDisableByApplication(String zoneId, bool disable) {
    return BluedotPointSdkPlatform.instance.setZoneDisableByApplication(zoneId, disable);
  }

  Future<String> getInstallRef() {
    return BluedotPointSdkPlatform.instance.getInstallRef();
  }

  Future<String> getSDKVersion() {
    return BluedotPointSdkPlatform.instance.getSDKVersion();
  }

  Future<dynamic> getZonesAndFences() {
    return BluedotPointSdkPlatform.instance.getZonesAndFences();
  }

  Future<void> reset() {
    return BluedotPointSdkPlatform.instance.reset();
  }

  GeoTriggeringBuilder geoTriggeringBuilder() {
    return GeoTriggeringBuilder();
  }

  TempoBuilder tempoBuilder() {
    return TempoBuilder();
  }

}

