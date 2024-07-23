package io.bluedot.bluedot_point_sdk

import android.content.Context
import au.com.bluedot.point.net.engine.BDError
import au.com.bluedot.point.net.engine.BluedotServiceReceiver

class BluedotErrorReceiver : BluedotServiceReceiver() {
    /**
     * Called when the Bluedot Point SDK encounters errors. If the error is fatal, the SDK services
     * may need to be restarted after the cause of the error has been addressed.
     *
     * @param[error] The error, please see [documentation](https://docs.bluedot.io/android-sdk/android-error-handling/)
     * for possible subtypes and appropriate corrective actions.
     * @param[context] Android context.
     * @since 15.3.0
     */

    override fun onBluedotServiceError(error: BDError, context: Context) {
        val arguments: Map<String, String> = mapOf("code" to error.errorCode.toString(), "message" to error.reason.toString(), "details" to error.toString())
        sendEvent("onBluedotServiceError", arguments)
    }

    private fun sendEvent(eventName: String, params: Map<String, Any?>) {
        BluedotPointSdkPlugin.bluedotServiceChannel.invokeMethod(eventName, params)
    }
}