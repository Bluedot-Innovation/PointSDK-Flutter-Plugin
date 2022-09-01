package io.bluedot.bluedot_point_sdk

import android.content.Context
import au.com.bluedot.point.net.engine.*
import kotlin.collections.ArrayList

class AppGeoTriggeringReceiver : GeoTriggeringEventReceiver() {

    override fun onZoneInfoUpdate(zones: List<ZoneInfo>, context: Context) {
        val zoneList: ArrayList<Map<String, Any?>> = arrayListOf()
        for (zoneInfo in zones) {
            val customDataZone: MutableMap<String, Any?> = mutableMapOf()
            val customDataMap = zoneInfo.getCustomData()
            if (customDataMap != null) {
                for (entry in customDataMap.keys) {
                    customDataZone[entry] = customDataMap[entry]
                }
            }
            val zone: Map<String, Any?> = mapOf("id" to zoneInfo.zoneId, "name" to zoneInfo.zoneName, "customData" to customDataZone)
            zoneList.add(zone)
        }
        val map: Map<String, Any> = mapOf("zoneInto" to zoneList)
        sendEvent("onZoneInfoUpdate", map)
    }

    override fun onZoneEntryEvent(entryEvent: ZoneEntryEvent, context: Context) {
        val (id, name) = entryEvent.fenceInfo
        val fenceDetails: Map<String, Any?> = mapOf("id" to id, "name" to name)
        val zoneInfo = entryEvent.zoneInfo
        val customDataZone: MutableMap<String, Any?> = mutableMapOf()
        val customDataMap = zoneInfo.getCustomData()
        if (customDataMap != null) {
            for (entry in customDataMap.keys) {
                customDataZone[entry] = customDataMap[entry]
            }
        }
        val zoneDetails: Map<String, Any?> = mapOf("id" to zoneInfo.zoneId, "name" to zoneInfo.zoneName, "description" to zoneInfo.toString() ,"customData" to customDataZone)
        val locationInfo = entryEvent.locationInfo
        val locationDetails: Map<String, Any?> = mapOf("latitude" to locationInfo.latitude, "longitude" to locationInfo.longitude,
                                                        "speed" to locationInfo.getSpeed(), "bearing" to locationInfo.getBearing(),
                                                        "timeStamp" to locationInfo.timeStamp)
        val map: Map<String, Any?> = mapOf("fenceInfo" to fenceDetails, "zoneInfo" to zoneDetails,
                                            "locationInfo" to locationDetails, "isExitEnabled" to entryEvent.isExitEnabled)
        sendEvent("didEnterZone", map)
    }

    override fun onZoneExitEvent(exitEvent: ZoneExitEvent, context: Context) {
        val (id, name) = exitEvent.fenceInfo
        val fenceDetails = mapOf("id" to id, "name" to name)
        val zoneInfo = exitEvent.zoneInfo
        val customDataZone: MutableMap<String, Any?> = mutableMapOf()
        val customDataMap = zoneInfo.getCustomData()
        if (customDataMap != null) {
            for (entry in customDataMap.keys) {
                customDataZone[entry] = customDataMap[entry]
            }
        }
        val zoneDetails: Map<String, Any?> = mapOf("id" to zoneInfo.zoneId, "name" to zoneInfo.zoneName, "description" to zoneInfo.toString(),"customData" to customDataZone)
        val map: Map<String, Any?> = mapOf("fenceInfo" to fenceDetails, "zoneInfo" to zoneDetails, "dwellTime" to exitEvent.dwellTime)
        sendEvent("didExitZone", map)
    }

    private fun sendEvent(eventName: String, params: Map<String, Any?>) {
        BluedotPointSdkPlugin.geoTriggeringChannel.invokeMethod(eventName, params)
    }
}
