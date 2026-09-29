package io.bluedot.bluedot_point_sdk

import android.content.Context
import android.os.Handler
import android.os.Looper
import au.com.bluedot.point.net.engine.*
import au.com.bluedot.point.net.engine.event.*

class AppGeoTriggeringReceiver : GeoTriggeringEventReceiver() {

  override fun onZoneInfoUpdate(context: Context) {
    sendEvent("didUpdateZoneInfo", "")
  }

  override fun onZoneEntryEvent(entryEvent: GeoTriggerEvent, context: Context) {
    sendEvent("didEnterZone", entryEvent.toJson())
  }

  override fun onZoneExitEvent(exitEvent: GeoTriggerEvent, context: Context) {
    sendEvent("didExitZone", exitEvent.toJson())
  }

  override fun onZoneDwellEvent(dwellEvent: GeoTriggerEvent, context: Context) {
    sendEvent("didDwellInZone", dwellEvent.toJson())
  }

  // Decode natively so background launches do not depend on a Dart method
  // handler being registered before PointSDK delivers an event.
  private fun sendEvent(eventName: String, jsonStr: String) {
    Handler(Looper.getMainLooper()).post {
      BluedotPointSdkPlugin.geoTriggeringChannel?.invokeMethod(eventName, JsonUtils.decodeJSON(jsonStr))
    }
  }
}
