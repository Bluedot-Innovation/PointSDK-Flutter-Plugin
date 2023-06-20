package io.bluedot.bluedot_point_sdk

import android.content.Context
import au.com.bluedot.point.net.engine.*
import au.com.bluedot.point.net.engine.event.GeoTriggerEvent
import kotlin.collections.ArrayList
import org.json.JSONObject

class AppGeoTriggeringReceiver : GeoTriggeringEventReceiver() {

    override fun onZoneInfoUpdate(context: Context) {
        sendEvent("onZoneInfoUpdate", mapOf())
    }

    override fun onZoneEntryEvent(entryEvent: GeoTriggerEvent, context: Context) {
        // TODO: map GeoTriggerEvent model to arguments
        val arguments: Map<String, String> = mapOf("zone" to entryEvent.zoneInfo.name)
        sendEvent("didEnterZone", arguments)
    }

    override fun onZoneExitEvent(exitEvent: GeoTriggerEvent, context: Context) {
        // TODO: map GeoTriggerEvent model to arguments
        val arguments: Map<String, String> = mapOf("zone" to exitEvent.zoneInfo.name)
        sendEvent("didExitZone", arguments)
    }

    private fun sendEvent(eventName: String, params: Map<String, Any?>) {
        BluedotPointSdkPlugin.geoTriggeringChannel.invokeMethod(eventName, params)
    }
}
