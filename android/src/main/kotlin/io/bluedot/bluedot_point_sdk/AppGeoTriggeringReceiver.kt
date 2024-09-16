package io.bluedot.bluedot_point_sdk

import android.content.Context
import android.util.Log
import au.com.bluedot.point.net.engine.*
import au.com.bluedot.point.net.engine.event.*
import io.flutter.plugin.common.MethodChannel.Result

class AppGeoTriggeringReceiver : GeoTriggeringEventReceiver() {

  override fun onZoneInfoUpdate(context: Context) {
    sendEvent("didUpdateZoneInfo", "", "")
  }

  override fun onZoneEntryEvent(entryEvent: GeoTriggerEvent, context: Context) {
    sendEvent("didEnterZone", "GeoTriggerEvent", entryEvent.toJson())
  }

  override fun onZoneExitEvent(exitEvent: GeoTriggerEvent, context: Context) {
    sendEvent("didExitZone", "GeoTriggerEvent", exitEvent.toJson())
  }

  // Use Dart to parse the json string and pass the resulting object to the
  // client callback.
  private fun sendEvent(eventName: String, modelName: String, jsonStr: String) {

    BluedotPointSdkPlugin.methodChannelGeoUtils?.invokeMethod("parseJson", listOf(modelName, jsonStr), object : Result {
      override fun success(result: Any?) {
        Log.i("ABCD", "AppGeoTriggeringReceiver sendEvent Success")
        BluedotPointSdkPlugin.geoTriggeringChannel?.invokeMethod(eventName, result)
      }
      override fun error(
        errorCode: String, errorMessage: String?,
        errorDetails: Any?
      ) {
        Log.i("ABCD", "AppGeoTriggeringReceiver sendEvent Error")
        Log.e("AppGeoTriggeringRecv", "[sendEvent] failed")
      }

      override fun notImplemented() {}
    })
  }
}
