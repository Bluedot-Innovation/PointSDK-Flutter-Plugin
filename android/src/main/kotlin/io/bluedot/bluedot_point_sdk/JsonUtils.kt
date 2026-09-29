package io.bluedot.bluedot_point_sdk

import org.json.JSONArray
import org.json.JSONObject

// Decode natively so background launches do not depend on a Dart method
// handler being registered before PointSDK delivers an event. Mirrors the
// iOS `decodeJSON` fix for BD-8157.
object JsonUtils {

  fun decodeJSON(jsonStr: String): Any? {
    if (jsonStr.isEmpty()) {
      return null
    }

    return try {
      val trimmed = jsonStr.trim()
      when {
        trimmed.startsWith("{") -> jsonObjectToMap(JSONObject(trimmed))
        trimmed.startsWith("[") -> jsonArrayToList(JSONArray(trimmed))
        else -> null
      }
    } catch (e: Exception) {
      null
    }
  }

  private fun jsonObjectToMap(json: JSONObject): Map<String, Any?> {
    val map = mutableMapOf<String, Any?>()
    val keys = json.keys()
    while (keys.hasNext()) {
      val key = keys.next()
      map[key] = convertValue(json.get(key))
    }
    return map
  }

  private fun jsonArrayToList(array: JSONArray): List<Any?> {
    val list = mutableListOf<Any?>()
    for (i in 0 until array.length()) {
      list.add(convertValue(array.get(i)))
    }
    return list
  }

  private fun convertValue(value: Any?): Any? {
    return when (value) {
      JSONObject.NULL -> null
      is JSONObject -> jsonObjectToMap(value)
      is JSONArray -> jsonArrayToList(value)
      else -> value
    }
  }
}
