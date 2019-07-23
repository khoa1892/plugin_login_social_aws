import Flutter
import UIKit
import AWSMobileClient

public class SwiftFlutterAwsPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_aws_plugin", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterAwsPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "loginByFacebook" {
            // Option to launch Facebook sign in directly
            let hostedUIOptions = HostedUIOptions(scopes: ["openid", "email"], identityProvider: "Facebook")
            
            let delegate = UIApplication.shared.delegate as! FlutterAppDelegate
            
            if let rootVC = delegate.window?.rootViewController as? UINavigationController {
                // Present the Hosted UI sign in.
                AWSMobileClient.sharedInstance().showSignIn(navigationController: rootVC, hostedUIOptions: hostedUIOptions) { (userState, error) in
                    if let error = error as? AWSMobileClientError {
                        if let errorHandler = getErrorMsg(error) {
                            var errorDict = [String: Any]()
                            errorDict["errorCode"] = errorHandler.code.localizedDescription
                            errorDict["message"] = errorHandler.errorMsg
                            result(errorDict)
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
                                    result(token.idToken?.claims)
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
                    if let error = error as? AWSMobileClientError {
                        if let errorHandler = getErrorMsg(error) {
                            var errorDict = [String: Any]()
                            errorDict["errorCode"] = errorHandler.code.localizedDescription
                            errorDict["message"] = errorHandler.errorMsg
                            result(errorDict)
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
                                    result(token.idToken?.claims)
                                }
                            })
                        }
                    }
                }
            }
        } else if call.method == "signOut" {
            AWSMobileClient.sharedInstance().signOut { (error) in
                if let error = error as? AWSMobileClientError {
                    if let errorHandler = getErrorMsg(error) {
                        var errorDict = [String: Any]()
                        errorDict["errorCode"] = errorHandler.code.localizedDescription
                        errorDict["message"] = errorHandler.errorMsg
                        result(errorDict)
                    }
                } else {
                    result("Sign Out")
                }
            }
        }
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
