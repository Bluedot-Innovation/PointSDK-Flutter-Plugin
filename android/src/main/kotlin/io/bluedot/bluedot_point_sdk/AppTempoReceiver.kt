package io.bluedot.bluedot_point_sdk

import android.content.Context
import android.util.Log
import au.com.bluedot.point.net.engine.BDError
import au.com.bluedot.point.net.engine.TempoTrackingReceiver
import au.com.bluedot.point.net.engine.event.TempoTrackingUpdate

class AppTempoReceiver : TempoTrackingReceiver() {
    /**
     * Called when there is an error that has caused Tempo to stop.
     *
     * @param error: can be a [TempoInvalidDestinationIdError][au.com.bluedot.point.TempoInvalidDestinationIdError]
     * or a [BDTempoError][au.com.bluedot.point.BDTempoError]
     * @param context: Android context
     * @since 15.3.0
     */

    override fun tempoStoppedWithError(error: BDError, context: Context) {
        val arguments: Map<String, String> =
            mapOf("code" to error.errorCode.toString(), "message" to error.reason.toString(), "details" to error.toString())
        sendEvent("tempoTrackingStoppedWithError", arguments)
    }

    override fun onTempoTrackingUpdate(tempoTrackingUpdate: TempoTrackingUpdate, context: Context) {
        Log.d("AppTempoReceiver", "[onTempoTrackingUpdate] $tempoTrackingUpdate")
        sendEvent("tempoTrackingDidUpdate", tempoTrackingUpdate.toJson())
    }

    private fun sendEvent(eventName: String, params: Map<String, Any?>) {
        BluedotPointSdkPlugin.tempoChannel?.invokeMethod(eventName, params)
    }

    // Decode natively so background launches do not depend on a Dart method
    // handler being registered before PointSDK delivers an event.
    private fun sendEvent(eventName: String, jsonStr: String) {
        BluedotPointSdkPlugin.tempoChannel?.invokeMethod(eventName, JsonUtils.decodeJSON(jsonStr))
    }
}