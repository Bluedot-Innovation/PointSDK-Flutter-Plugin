import BDPointSDK
import Flutter
import UIKit
import UserNotifications

public final class BluedotPointSdkPushPlugin: NSObject,
    FlutterPlugin,
    FlutterApplicationLifeCycleDelegate {
    private static let commandChannelName = "bluedot_point_flutter/push_sdk"
    private static let eventsChannelName = "bluedot_point_flutter/push_notification_events"

    private static var current: BluedotPointSdkPushPlugin?

    private let eventsChannel: FlutterMethodChannel
    private var isListenerReady = false
    private var shouldBufferEvents = true
    private var pendingEvents: [(method: String, arguments: [String: Any])] = []

    private init(eventsChannel: FlutterMethodChannel) {
        self.eventsChannel = eventsChannel
        super.init()
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let commandChannel = FlutterMethodChannel(
            name: commandChannelName,
            binaryMessenger: registrar.messenger()
        )
        let eventsChannel = FlutterMethodChannel(
            name: eventsChannelName,
            binaryMessenger: registrar.messenger()
        )
        let instance = BluedotPointSdkPushPlugin(eventsChannel: eventsChannel)

        registrar.addMethodCallDelegate(instance, channel: commandChannel)
        registrar.addApplicationDelegate(instance)

        current = instance
    }

    @objc
    @discardableResult
    public static func handleForegroundNotification(_ notification: UNNotification) -> Bool {
        let handled = BDLocationManager.instance().pushNotifications.handleForeground(notification)
        if handled {
            current?.emit(method: "onNotificationReceived", notification: notification)
        }
        return handled
    }

    @objc
    public static func handleNotificationResponse(_ response: UNNotificationResponse) {
        BDLocationManager.instance().pushNotifications.handleResponse(response)

        let notification = response.notification
        guard let instance = current, instance.isValidBluedotNotification(notification) else {
            return
        }
        instance.emit(method: "onNotificationClicked", notification: notification)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "registerForRemoteNotifications":
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
                result(nil)
            }
        case "notificationListenerReady":
            isListenerReady = true
            shouldBufferEvents = true
            flushPendingEvents()
            result(nil)
        case "notificationListenerRemoved":
            isListenerReady = false
            shouldBufferEvents = false
            pendingEvents.removeAll()
            result(nil)
        case "onNewFcmToken", "onMessageReceived":
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    public func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        BDLocationManager.instance().pushNotifications.register(deviceToken)
    }

    private func emit(method: String, notification: UNNotification) {
        let event = (method: method, arguments: eventArguments(from: notification))
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if self.isListenerReady {
                self.eventsChannel.invokeMethod(event.method, arguments: event.arguments)
            } else if self.shouldBufferEvents {
                self.pendingEvents.append(event)
            }
        }
    }

    private func flushPendingEvents() {
        let events = pendingEvents
        pendingEvents.removeAll()
        for event in events {
            eventsChannel.invokeMethod(event.method, arguments: event.arguments)
        }
    }

    private func isValidBluedotNotification(_ notification: UNNotification) -> Bool {
        let userInfo = notification.request.content.userInfo
        return userInfo["com.rezolveai.push"] != nil
            && !stringValue(userInfo["zoneId"]).isEmpty
            && !stringValue(userInfo["notificationId"]).isEmpty
    }

    private func eventArguments(from notification: UNNotification) -> [String: Any] {
        let content = notification.request.content
        let userInfo = content.userInfo
        let knownKeys = Set([
            "aps",
            "com.rezolveai.push",
            "campaignId",
            "zoneId",
            "notificationId"
        ])
        var customData: [String: String] = [:]

        for (key, value) in userInfo {
            guard let key = key as? String, !knownKeys.contains(key) else { continue }
            customData[key] = stringValue(value)
        }

        return [
            "title": content.title,
            "body": content.body,
            "pushVersion": stringValue(userInfo["com.rezolveai.push"]),
            "campaignId": stringValue(userInfo["campaignId"]),
            "zoneId": stringValue(userInfo["zoneId"]),
            "notificationId": stringValue(userInfo["notificationId"]),
            "data": customData
        ]
    }

    private func stringValue(_ value: Any?) -> String {
        switch value {
        case let value as String:
            return value
        case let value as NSNumber:
            return value.stringValue
        case .some(let value):
            return String(describing: value)
        case .none:
            return ""
        }
    }
}