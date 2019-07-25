import Flutter
import UIKit
import AWSMobileClient
import AWSPinpoint

public class SwiftFlutterAwsPlugin: NSObject, FlutterPlugin {
    
    var pinpoint: AWSPinpoint?
    
    var internalRegister: FlutterPluginRegistrar!
    var internalMessenger: FlutterBinaryMessenger!
    var internalChannel: FlutterMethodChannel!
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_aws_plugin", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterAwsPlugin.init(withRegister: registrar, message: registrar.messenger(), channel: channel)
        registrar.addApplicationDelegate(instance)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    init(withRegister register: FlutterPluginRegistrar, message: FlutterBinaryMessenger, channel: FlutterMethodChannel) {
        super.init()
        self.internalRegister = register
        self.internalMessenger = message
        self.internalChannel = channel
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "loginByFacebook" {
            // Option to launch Facebook sign in directly
            let hostedUIOptions = HostedUIOptions(scopes: ["openid", "email"], identityProvider: "Facebook")
            
            let delegate = UIApplication.shared.delegate as! FlutterAppDelegate
            
            if let rootVC = delegate.window?.rootViewController as? UINavigationController {
                // Present the Hosted UI sign in.
                AWSMobileClient.sharedInstance().showSignIn(navigationController: rootVC, hostedUIOptions: hostedUIOptions) { (userState, error) in
                    if let error = error {
                        if let awsError = error as? AWSMobileClientError {
                            if let errorHandler = getErrorMsg(awsError) {
                                var errorDict = [String: Any]()
                                errorDict["errorCode"] = errorHandler.code.localizedDescription
                                errorDict["message"] = errorHandler.errorMsg
                                result(errorDict)
                            }
                        } else {
                            switch error {
                            case URLError.cancelled, URLError.userCancelledAuthentication, URLError.userAuthenticationRequired:
                                result("")
                                break
                            default:
                                var errorDict = [String: Any]()
                                errorDict["errorCode"] = error.localizedDescription
                                errorDict["message"] = error.localizedDescription
                                result(errorDict)
                            }
                        }
                    }
                    if let userState = userState {
                        if userState == .signedIn {
                            AWSMobileClient.sharedInstance().getTokens({ (token, error) in
                                if let error = error as? AWSMobileClientError {
                                    if let errorHandler = getErrorMsg(error) {
                                        var errorDict = [String: Any]()
                                        errorDict["errorCode"] = errorHandler.code.localizedDescription
                                        errorDict["message"] = errorHandler.errorMsg
                                        result(errorDict)
                                    }
                                }
                                if let token = token {
                                    var dict = [String: Any]()
                                    dict["token"] = token.idToken?.tokenString
                                    dict["data"] = token.idToken?.claims
                                    do {
                                        let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
                                        let theJSONText = String(data: jsonData,
                                                                 encoding: .utf8)
                                        result(theJSONText ?? "")
                                    } catch {
                                        print(error.localizedDescription)
                                    }
                                }
                            })
                        }
                    }
                }
            }
        } else if call.method == "loginByGoogle" {
            // Option to launch Facebook sign in directly
            let hostedUIOptions = HostedUIOptions(scopes: ["openid", "email"], identityProvider: "Google")
            
            let delegate = UIApplication.shared.delegate as! FlutterAppDelegate
            if let rootVC = delegate.window?.rootViewController as? UINavigationController {
                // Present the Hosted UI sign in.
                AWSMobileClient.sharedInstance().showSignIn(navigationController: rootVC, hostedUIOptions: hostedUIOptions) { (userState, error) in
                    if let error = error {
                        if let awsError = error as? AWSMobileClientError {
                            if let errorHandler = getErrorMsg(awsError) {
                                var errorDict = [String: Any]()
                                errorDict["errorCode"] = errorHandler.code.localizedDescription
                                errorDict["message"] = errorHandler.errorMsg
                                result(errorDict)
                            }
                        } else {
                            switch error {
                            case URLError.cancelled, URLError.userCancelledAuthentication:
                                result("")
                                break
                            default:
                                var errorDict = [String: Any]()
                                errorDict["errorCode"] = error.localizedDescription
                                errorDict["message"] = error.localizedDescription
                                result(errorDict)
                            }
                        }
                    }
                    if let userState = userState {
                        if userState == .signedIn {
                            AWSMobileClient.sharedInstance().getTokens({ (token, error) in
                                if let error = error as? AWSMobileClientError {
                                    if let errorHandler = getErrorMsg(error) {
                                        var errorDict = [String: Any]()
                                        errorDict["errorCode"] = errorHandler.code.localizedDescription
                                        errorDict["message"] = errorHandler.errorMsg
                                        result(errorDict)
                                    }
                                }
                                if let token = token {
                                    var dict = [String: Any]()
                                    dict["token"] = token.idToken?.tokenString
                                    dict["data"] = token.idToken?.claims
                                    do {
                                        let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
                                        let theJSONText = String(data: jsonData,
                                                                 encoding: .utf8)
                                        result(theJSONText ?? "")
                                    } catch {
                                        print(error.localizedDescription)
                                    }
                                }
                            })
                        }
                    }
                }
            }
        } else if call.method == "signOut" {
            result("Sign Out")
            AWSMobileClient.sharedInstance().signOut()
        } else if call.method == "initPinPoint" {
            let pinpointConfiguration = AWSPinpointConfiguration.defaultPinpointConfiguration(launchOptions: nil)
            pinpoint = AWSPinpoint(configuration: pinpointConfiguration)
        } else if call.method == "initNotificationPermission" {
            UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert]) { (granted, error) in
                if granted {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            }
        } else if call.method == "logEvent" {
            if let analyticsClient = pinpoint?.analyticsClient {
                let event = analyticsClient.createEvent(withEventType: "EventName")
                event.addAttribute("DemoAttributeValue1", forKey: "DemoAttribute1")
                event.addAttribute("DemoAttributeValue2", forKey: "DemoAttribute2")
                event.addMetric(NSNumber(value: arc4random() % 65535), forKey: "EventName")
                analyticsClient.record(event)
                analyticsClient.submitEvents()
            }
        }
    }
    
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable : Any] = [:]) -> Bool {
        let delegate = UIApplication.shared.delegate as! FlutterAppDelegate
        let flutterVC = delegate.window.rootViewController as! FlutterViewController
        let navigation = UINavigationController.init(rootViewController: flutterVC)
        delegate.window.rootViewController = navigation
        navigation.navigationBar.isHidden = true
        delegate.window.makeKeyAndVisible()
        return true
    }
    
    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        var token = ""
        for i in 0..<deviceToken.count {
            token = token + String(format: "%02.2hhx", arguments: [deviceToken[i]])
        }
        self.internalChannel.invokeMethod("pushReceiveToken", arguments: token)
        pinpoint!.notificationManager.interceptDidRegisterForRemoteNotifications(
            withDeviceToken: deviceToken)
    }
    
    public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) -> Bool {
        pinpoint!.notificationManager.interceptDidReceiveRemoteNotification(
            userInfo, fetchCompletionHandler: completionHandler)
        self.internalChannel.invokeMethod("pushReceiveUserInfo", arguments: userInfo)
        return true
    }
}

struct ErrorHandler {
    let code: AWSMobileClientError
    let errorMsg: String
}

func getErrorMsg(_ error: AWSMobileClientError) -> ErrorHandler? {
    switch error {
    case .aliasExists(let message):
        return ErrorHandler.init(code: error, errorMsg: message)
    case .codeDeliveryFailure(let message):
        return ErrorHandler.init(code: error, errorMsg: message)
    case .codeMismatch(let message):
        return ErrorHandler.init(code: error, errorMsg: message)
    case .badRequest(let message):
        return ErrorHandler.init(code: error, errorMsg: message)
    case .cognitoIdentityPoolNotConfigured(let message):
        return ErrorHandler.init(code: error, errorMsg: message)
    case .deviceNotRemembered(let message):
        return ErrorHandler.init(code: error, errorMsg: message)
    case .errorLoadingPage(let message):
        return ErrorHandler.init(code: error, errorMsg: message)
    case .expiredCode(let message):
        return ErrorHandler.init(code: error, errorMsg: message)
    case .expiredRefreshToken(let message):
        return ErrorHandler.init(code: error, errorMsg: message)
    case .federationProviderExists(let message):
        return ErrorHandler.init(code: error, errorMsg: message)
    case .groupExists(let message):
        return ErrorHandler.init(code: error, errorMsg: message)
    case .guestAccessNotAllowed(let message):
        return ErrorHandler.init(code: error, errorMsg: message)
    case .identityIdUnavailable(let message):
        return ErrorHandler.init(code: error, errorMsg: message)
    case .idTokenAndAcceessTokenNotIssued(let message):
        return ErrorHandler.init(code: error, errorMsg: message)
    case .idTokenNotIssued(let message):
        return ErrorHandler.init(code: error, errorMsg: message)
    case .internalError(let message):
        return ErrorHandler.init(code: error, errorMsg: message)
    case .invalidConfiguration(let message):
        return ErrorHandler.init(code: error, errorMsg: message)
    case .invalidLambdaResponse(let message):
        return ErrorHandler.init(code: error, errorMsg: message)
    case .invalidOAuthFlow(let message):
        return ErrorHandler.init(code: error, errorMsg: message)
    case .invalidParameter(let message):
        return ErrorHandler.init(code: error, errorMsg: message)
    case .invalidPassword(let message):
        return ErrorHandler.init(code: error, errorMsg: message)
    case .invalidState(let message):
        return ErrorHandler.init(code: error, errorMsg: message)
    case .limitExceeded(let message):
        return ErrorHandler.init(code: error, errorMsg: message)
    case .mfaMethodNotFound(let message):
        return ErrorHandler.init(code: error, errorMsg: message)
    case .notAuthorized(let message):
        return ErrorHandler.init(code: error, errorMsg: message)
    case .passwordResetRequired(let message):
        return ErrorHandler.init(code: error, errorMsg: message)
    case .resourceNotFound(let message):
        return ErrorHandler.init(code: error, errorMsg: message)
    case .scopeDoesNotExist(let message):
        return ErrorHandler.init(code: error, errorMsg: message)
    case .securityFailed(let message):
        return ErrorHandler.init(code: error, errorMsg: message)
    case .softwareTokenMFANotFound(let message):
        return ErrorHandler.init(code: error, errorMsg: message)
    case .tooManyFailedAttempts(let message):
        return ErrorHandler.init(code: error, errorMsg: message)
    case .tooManyRequests(let message):
        return ErrorHandler.init(code: error, errorMsg: message)
    case .unableToSignIn(let message):
        return ErrorHandler.init(code: error, errorMsg: message)
    case .unexpectedLambda(let message):
        return ErrorHandler.init(code: error, errorMsg: message)
    case .unknown(let message):
        return ErrorHandler.init(code: error, errorMsg: message)
    case .userCancelledSignIn(let message):
        return ErrorHandler.init(code: error, errorMsg: message)
    case .userLambdaValidation(let message):
        return ErrorHandler.init(code: error, errorMsg: message)
    case .usernameExists(let message):
        return ErrorHandler.init(code: error, errorMsg: message)
    case .userNotConfirmed(let message):
        return ErrorHandler.init(code: error, errorMsg: message)
    case .userNotFound(let message):
        return ErrorHandler.init(code: error, errorMsg: message)
    case .userPoolNotConfigured(let message):
        return ErrorHandler.init(code: error, errorMsg: message)
    default:
        return nil
    }
}
