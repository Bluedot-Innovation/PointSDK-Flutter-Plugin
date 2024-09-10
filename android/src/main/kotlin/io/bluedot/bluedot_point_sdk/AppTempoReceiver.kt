package io.bluedot.bluedot_point_sdk

import android.content.Context
import android.util.Log
import au.com.bluedot.point.net.engine.BDError
import au.com.bluedot.point.net.engine.TempoTrackingReceiver
import au.com.bluedot.point.net.engine.event.TempoTrackingUpdate
import io.flutter.plugin.common.MethodChannel.Result

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
        sendEvent("tempoTrackingDidUpdate", "TempoTrackingUpdate", tempoTrackingUpdate.toJson())
    }

    private fun sendEvent(eventName: String, params: Map<String, Any?>) {
        BluedotPointSdkPlugin.tempoChannel?.invokeMethod(eventName, params)
    }

    // Use Dart to parse the json string and pass the resulting object to the
    // client callback.
    private fun sendEvent(eventName: String, modelName: String, jsonStr: String) {
        BluedotPointSdkPlugin.methodChannelGeoUtils?.invokeMethod("parseJson", listOf(modelName, jsonStr), object : Result {
            override fun success(result: Any?) {
                BluedotPointSdkPlugin.tempoChannel?.invokeMethod(eventName, result)
            }
            override fun error(
                    errorCode: String, errorMessage: String?,
                    errorDetails: Any?
            ) {
                Log.e("AppTempoReceiver", "[sendEvent] failed")
            }

            override fun notImplemented() {}
        })
    }
}