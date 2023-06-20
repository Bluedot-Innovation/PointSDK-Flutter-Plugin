package io.bluedot.bluedot_point_sdk

import android.content.Context
import au.com.bluedot.point.net.engine.BDError
import au.com.bluedot.point.net.engine.TempoTrackingReceiver
import au.com.bluedot.point.net.engine.event.TempoTrackingUpdate
import org.json.JSONObject

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
        val arguments: Map<String, String> = mapOf("code" to error.errorCode.toString(), "message" to error.reason, "details" to error.toString())
        sendEvent("tempoTrackingStoppedWithError", arguments)
    }

    override fun onTempoTrackingUpdate(tempoTrackingUpdate: TempoTrackingUpdate, context: Context) {

        // TODO: map TempoTrackingUpdate model to arguments
        val arguments: Map<String, String> = mapOf("eta" to tempoTrackingUpdate.eta.toString())
        sendEvent("tempoTrackingUpdated", arguments)
    }

    private fun sendEvent(eventName: String, params: Map<String, Any?>) {
        BluedotPointSdkPlugin.tempoChannel.invokeMethod(eventName, params)
    }
}