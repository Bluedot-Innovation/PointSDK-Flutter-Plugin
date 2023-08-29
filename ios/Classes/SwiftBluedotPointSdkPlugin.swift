import Flutter
import UIKit
import BDPointSDK

public class SwiftBluedotPointSdkPlugin: NSObject, FlutterPlugin {

    private var methodChannel: FlutterMethodChannel?
    private var geoTriggeringMethodChannel: FlutterMethodChannel?
    private var tempoMethodChannel: FlutterMethodChannel?
    private var bluedotServiceMethodChannel: FlutterMethodChannel?
    private var geoTriggeringUtilsChannel: FlutterMethodChannel?
    
    static let flutterPluginChannel = "bluedot_point_flutter/bluedot_point_sdk"
    static let geoTriggeringChannel = "bluedot_point_flutter/geo_triggering_events"
    static let tempoChannel = "bluedot_point_flutter/tempo_events"
    static let bluedotServiceChannel = "bluedot_point_flutter/bluedot_service_events"
    static let geoTriggeringUtilsChannel = "bluedot_point_flutter/geo_triggering_utils"
    
    public override init() {
        super.init()
        BDLocationManager.instance().geoTriggeringEventDelegate = self
        BDLocationManager.instance().tempoTrackingDelegate = self
        BDLocationManager.instance().bluedotServiceDelegate = self
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: flutterPluginChannel, binaryMessenger: registrar.messenger())
        let geoTriggeringMethodChannel = FlutterMethodChannel(name: geoTriggeringChannel, binaryMessenger: registrar.messenger())
        let tempoMethodChannel = FlutterMethodChannel(name: tempoChannel, binaryMessenger: registrar.messenger())
        let bluedotServiceMethodChannel = FlutterMethodChannel(name: bluedotServiceChannel, binaryMessenger: registrar.messenger())
        let geoTriggeringUtilsChannel = FlutterMethodChannel(name: geoTriggeringUtilsChannel, binaryMessenger: registrar.messenger())
        let instance = SwiftBluedotPointSdkPlugin()
        instance.methodChannel = channel
        instance.geoTriggeringMethodChannel = geoTriggeringMethodChannel
        instance.tempoMethodChannel = tempoMethodChannel
        instance.bluedotServiceMethodChannel = bluedotServiceMethodChannel
        instance.geoTriggeringUtilsChannel = geoTriggeringUtilsChannel
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "isInitialized":
            let isInitialized = BDLocationManager.instance().isInitialized()
            result(isInitialized)
        case "isGeoTriggeringRunning":
            let isGeoTriggeringRunning = BDLocationManager.instance().isGeoTriggeringRunning()
            result(isGeoTriggeringRunning)
        case "isTempoRunning":
            let isTempoRunning = BDLocationManager.instance().isTempoRunning()
            result(isTempoRunning)
        case "initialize":
            initialize(call, result)
        case "iOSStartGeoTriggering":
            startGeoTriggering(call, result)
        case "stopGeoTriggering":
            stopGeoTriggering(call, result)
        case "iOSStartTempoTracking":
            startTempoTracking(call, result)
        case "stopTempoTracking":
            stopTempoTracking(result)
        case "setCustomEventMetaData":
            setCustomEventMetaData(call, result)
        case "setNotificationIcon":
            setNotificationIcon(call, result)
        case "setZoneDisableByApplication":
            setZoneDisableByApplication(call)
        case "reset":
            reset(result)
        case "getInstallRef":
            let installRef = BDLocationManager.instance().installRef()
            result(installRef)
        case "getSDKVersion":
            let sdkVersion = BDLocationManager.instance().sdkVersion()
            result(sdkVersion)
        case "getZonesAndFences":
            let zonesAndFences = BDLocationManager.instance().zoneInfos
            result(zonesAndFences)
        case "allowsBackgroundLocationUpdates":
            allowsBackgroundLocationUpdates(call)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func initialize(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any] else {
            result(FlutterError(code: "Invalid arguments", message: "Invalid arguments", details: "Expected arguments"))
            return
        }
        guard let projectId = arguments["projectId"] as? String else {
            result(FlutterError(code: "Invalid projectId", message: "Invalid projectId", details: "Expected projectId as String"))
            return
        }
        BDLocationManager.instance().initialize(withProjectId: projectId) { error in
            self.handleError(error, result)
        }
        
    }
    
    private func startGeoTriggering(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        if let args = call.arguments as? [String: Any], let title = args["title"] as? String, let content = args["content"] as? String {
            BDLocationManager.instance().startGeoTriggering(withAppRestartNotificationTitle: title, notificationButtonText: content) { error in
                self.handleError(error, result)
            }
        } else {
            BDLocationManager.instance().startGeoTriggering { error in
                self.handleError(error, result)
            }
        }
    }
    
    private func stopGeoTriggering(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        BDLocationManager.instance().stopGeoTriggering { error in
            self.handleError(error, result)
        }
    }
    
    private func startTempoTracking(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        if let args = call.arguments as? [String: Any], let destinationId = args["destinationId"] as? String {
            BDLocationManager.instance().startTempoTracking(withDestinationId: destinationId) { error in
                self.handleError(error, result)
            }
        } else {
            let flutterError = FlutterError(code: "Invalid Destination Id", message: "Destination Id is null or blank", details: "")
            result(flutterError)
        }
    }
    
    private func stopTempoTracking(_ result: @escaping FlutterResult) {
        BDLocationManager.instance().stopTempoTracking { error in
            self.handleError(error, result)
        }
    }
    
    private func setCustomEventMetaData(_ call: FlutterMethodCall, _ result: FlutterResult) {
        if let args = call.arguments as? [String: String] {
        do {
            try ObjC.catchException {
                BDLocationManager.instance().setCustomEventMetaData(args)
            }
            result(nil)
        } catch (let error) {
                result(errorToDict(error))
            }
        }
    }
    
    private func setZoneDisableByApplication(_ call: FlutterMethodCall) {
        if let args = call.arguments as? [String: Any], let zoneId = args["zoneId"] as? String, let disable = args["disable"] as? Bool {
            BDLocationManager.instance().setZone(zoneId, disableByApplication: disable)
        }
    }

    private func setNotificationIcon(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        // Do nothing for iOS, only application for Android
    }
    
    private func reset(_ result: @escaping FlutterResult) {
        BDLocationManager.instance().reset { error in
            self.handleError(error, result)
        }
    }
    
    private func allowsBackgroundLocationUpdates(_ call: FlutterMethodCall) {
        if let args = call.arguments as? [String: Any], let value = args["value"] as? Bool {
            BDLocationManager.instance().allowsBackgroundLocationUpdates = value
        }
    }
    
    private func errorToDict(_ error: Error?) -> [String: String] {
        if let error = error as? NSError {
            return ["code": String(error.code), "message": error.localizedDescription, "details" : ""]
        } else {
            return [:]
        }
    }

    private func handleError(_ error: Error?, _ result: FlutterResult) {
        if let error = error as? NSError {
            let flutterError = FlutterError(code: String(error.code), message: error.localizedDescription, details: "")
            result(flutterError)
        } else {
            result(nil)
        }
    }
    
    private func flutterErrorToDict(_ error: FlutterError) -> [String: String] {
        return ["code": error.code, "message" : error.message ?? "Unknown", "details": ""]
    }
}

extension SwiftBluedotPointSdkPlugin: BDPGeoTriggeringEventDelegate {

    public func didUpdateZoneInfo() {
        sendEvent(eventName: "didUpdateZoneInfo", modelName: "", jsonStr: "")
    }
    
    public func didEnterZone(_ enterEvent: GeoTriggerEvent) {
        let json = (try? enterEvent.toJson() as String?) ?? ""
        sendEvent(eventName: "didEnterZone", modelName: "GeoTriggerEvent", jsonStr: json)
    }
    
    public func didExitZone(_ exitEvent: GeoTriggerEvent) {
        let json = (try? exitEvent.toJson() as String?) ?? ""
        sendEvent(eventName: "didExitZone", modelName: "GeoTriggerEvent", jsonStr: json)
    }
    
    // Use Dart to parse the json string and pass the resulting object to the
    // client callback.
    private func sendEvent(eventName: String, modelName: String, jsonStr: String) -> Any {
        self.geoTriggeringUtilsChannel?.invokeMethod(
            "parseJson",
            arguments : [modelName, jsonStr], result: {(r:Any?) -> () in
                self.geoTriggeringMethodChannel?.invokeMethod(eventName, arguments: r)
        })
    }
}

extension SwiftBluedotPointSdkPlugin: BDPTempoTrackingDelegate {
    public func didStopTrackingWithError(_ error: Error!) {
        self.tempoMethodChannel?.invokeMethod("tempoTrackingStoppedWithError", arguments: errorToDict(error))
    }
    
    public func tempoTrackingDidExpire() {
        let error = FlutterError(code: "", message: "Tempo tracking did expire", details: nil)
        self.tempoMethodChannel?.invokeMethod("tempoTrackingStoppedWithError", arguments: flutterErrorToDict(error))
    }
}

extension SwiftBluedotPointSdkPlugin: BDPBluedotServiceDelegate {
    public func bluedotServiceDidReceiveError(_ error: Error!) {
        self.bluedotServiceMethodChannel?.invokeMethod("onBluedotServiceError", arguments: errorToDict(error))
    }
    
    public func locationAuthorizationDidChange(fromPreviousStatus previousAuthorizationStatus: CLAuthorizationStatus, toNewStatus newAuthorizationStatus: CLAuthorizationStatus) {
        let arguments = ["previousAuthorizationStatus" : previousAuthorizationStatus.rawValue, "newAuthorizationStatus": newAuthorizationStatus.rawValue]
        self.bluedotServiceMethodChannel?.invokeMethod("locationAuthorizationDidChange", arguments: arguments)
    }
    
    public func lowPowerModeDidChange(_ isLowPowerMode: Bool) {
        self.bluedotServiceMethodChannel?.invokeMethod("lowPowerModeDidChange", arguments: ["isLowPowerMode": isLowPowerMode])
    }
    
    public func accuracyAuthorizationDidChange(fromPreviousAuthorization previousAccuracyAuthorization: CLAccuracyAuthorization, toNewAuthorization newAccuracyAuthorization: CLAccuracyAuthorization) {
        let arguments = ["previousAccuracyAuthorization": previousAccuracyAuthorization.rawValue, "newAccuracyAuthorization": newAccuracyAuthorization.rawValue]
        self.bluedotServiceMethodChannel?.invokeMethod("accuracyAuthorizationDidChange", arguments: arguments)
    }
}
