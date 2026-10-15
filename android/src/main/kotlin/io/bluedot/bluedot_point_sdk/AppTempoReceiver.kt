package io.bluedot.bluedot_point_sdk

import android.content.Context
import android.util.Log
import au.com.bluedot.point.error.ForegroundServiceNotLinkedError
import au.com.bluedot.point.net.engine.BDError
import au.com.bluedot.point.net.engine.TempoTrackingReceiver
import au.com.bluedot.point.net.engine.event.TempoTrackingUpdate

class AppTempoReceiver : TempoTrackingReceiver() {
    /**
     * Called when there is an error that has caused Tempo to stop.
     *
     * @param error: can be a [ForegroundServiceNotLinkedError][au.com.bluedot.point.error.ForegroundServiceNotLinkedError]
     * (SDK 19.0.0+ — fired when the foreground service linked via `linkForegroundService()`
     * stopped or was killed while Tempo was tracking), a
     * [TempoInvalidDestinationIdError][au.com.bluedot.point.TempoInvalidDestinationIdError]
     * or a [BDTempoError][au.com.bluedot.point.BDTempoError]
     * @param context: Android context
     * @since 15.3.0
     */

    override fun tempoStoppedWithError(error: BDError, context: Context) {
        val arguments = mutableMapOf<String, Any?>(
            "code" to error.errorCode.toString(),
            "message" to error.reason.toString(),
            "details" to error.toString()
        )
        // The host app owns the foreground service (see ServiceManager.linkForegroundService()/
        // unlinkForegroundService()). If it goes away mid-session, Tempo stops and reports this
        // flag so Dart listeners can re-link and restart, or reflect that tracking has stopped.
        if (error is ForegroundServiceNotLinkedError) {
            arguments["isForegroundServiceNotLinked"] = true
        }
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