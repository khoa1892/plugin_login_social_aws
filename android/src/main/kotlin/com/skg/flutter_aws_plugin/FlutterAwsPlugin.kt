package com.skg.flutter_aws_plugin

import android.annotation.SuppressLint
import android.app.Activity
import android.app.Application
import android.os.Bundle
import android.util.Log
import com.amazonaws.mobile.client.*
import com.amazonaws.mobile.client.results.Token
import com.amazonaws.mobile.client.results.Tokens
import com.google.gson.Gson
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar


class FlutterAwsPlugin @SuppressLint("ObsoleteSdkInt") constructor(var activity: Activity, var registrar: Registrar) : MethodCallHandler {
    var callBack: Application.ActivityLifecycleCallbacks
    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "flutter_aws_plugin")
            channel.setMethodCallHandler(FlutterAwsPlugin(registrar.activity(), registrar))
        }
    }

    init {
        callBack = object : Application.ActivityLifecycleCallbacks {
            override fun onActivityPaused(p0: Activity?) {

            }

            override fun onActivityResumed(p0: Activity?) {
                val activityIntent = p0?.intent
                if (activityIntent?.data != null && "myapp" == activityIntent.data!!.scheme) {
                    AWSMobileClient.getInstance().handleAuthResponse(activityIntent)
                }
            }

            override fun onActivityStarted(p0: Activity?) {
            }

            override fun onActivityDestroyed(p0: Activity?) {
            }

            override fun onActivitySaveInstanceState(p0: Activity?, p1: Bundle?) {
            }

            override fun onActivityStopped(p0: Activity?) {
            }

            override fun onActivityCreated(p0: Activity?, p1: Bundle?) {
            }
        }
        activity.application.registerActivityLifecycleCallbacks(callBack)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when {
            call.method == "loginByFacebook" -> {
                AWSMobileClient.getInstance().initialize(activity.applicationContext, object : Callback<UserStateDetails> {
                    override fun onResult(userStateDetails: UserStateDetails) {
                        val hostedUIOptions = HostedUIOptions.builder()
                                .scopes("openid", "email")
                                .identityProvider("Facebook")
                                .build()

                        val signInUIOptions = SignInUIOptions.builder()
                                .hostedUIOptions(hostedUIOptions)
                                .build()
                        AWSMobileClient.getInstance()
                                .showSignIn(activity, signInUIOptions, object : Callback<UserStateDetails> {
                                    override fun onResult(details: UserStateDetails) {
                                        Log.d("LOGIN", "onResult: " + details.userState)
                                        AWSMobileClient.getInstance().getTokens(object : Callback<Tokens> {
                                            override fun onResult(token: Tokens?) {
                                                val gson = Gson()
                                                val mapData = HashMap<String, Any?>()
                                                mapData["auth_time"] = token?.idToken?.getClaim("auth_time")?.toInt()
                                                mapData["at_hash"] = token?.idToken?.getClaim("at_hash")
                                                mapData["aud"] = token?.idToken?.getClaim("aud")
                                                mapData["identities"] = token?.idToken?.getClaim("identities")
                                                mapData["email"] = token?.idToken?.getClaim("email")
                                                mapData["token_use"] = token?.idToken?.getClaim("token_use")
                                                mapData["sub"] = token?.idToken?.getClaim("sub")
                                                mapData["iss"] = token?.idToken?.getClaim("iss")
                                                mapData["exp"] = token?.idToken?.getClaim("exp")?.toInt()
                                                mapData["iat"] = token?.idToken?.getClaim("iat")?.toInt()
                                                mapData["cognito:username"] = token?.idToken?.getClaim("cognito:username")
                                                mapData["cognito:groups"] = token?.idToken?.getClaim("cognito:groups")
                                                val jsonData: String = gson.toJson(mapData)
                                                this@FlutterAwsPlugin.activity.runOnUiThread {
                                                    result.success(jsonData)
                                                }
                                            }

                                            override fun onError(e: Exception?) {
                                                print(e?.message)

                                            }

                                        })
                                    }

                                    override fun onError(e: Exception) {
                                        Log.e("LOGIN", "onError: ", e)
                                    }
                                })

                    }

                    override fun onError(e: Exception) {
                        Log.e("INIT", "Initialization error.", e)
                        this@FlutterAwsPlugin.activity.runOnUiThread {

                            result.error("Error", "Message", e)
                        }
                    }
                }
                )
            }
            call.method == "loginByGoogle" -> {
                AWSMobileClient.getInstance().initialize(activity.applicationContext, object : Callback<UserStateDetails> {
                    override fun onResult(userStateDetails: UserStateDetails) {
                        val hostedUIOptions = HostedUIOptions.builder()
                                .scopes("openid", "email")
                                .identityProvider("Google")
                                .build()

                        val signInUIOptions = SignInUIOptions.builder()
                                .hostedUIOptions(hostedUIOptions)
                                .build()

                        AWSMobileClient.getInstance()
                                .showSignIn(activity, signInUIOptions, object : Callback<UserStateDetails> {
                                    override fun onResult(details: UserStateDetails) {
                                        Log.d("LOGIN", "onResult: " + details.userState)
                                        AWSMobileClient.getInstance().getTokens(object : Callback<Tokens> {
                                            override fun onResult(token: Tokens?) {
                                                val gson = Gson()
                                                val mapData = HashMap<String, Any?>()
                                                mapData["auth_time"] = token?.idToken?.getClaim("auth_time")
                                                mapData["at_hash"] = token?.idToken?.getClaim("at_hash")
                                                mapData["aud"] = token?.idToken?.getClaim("aud")
                                                mapData["identities"] = token?.idToken?.getClaim("identities")
                                                mapData["email"] = token?.idToken?.getClaim("email")
                                                mapData["token_use"] = token?.idToken?.getClaim("token_use")
                                                mapData["sub"] = token?.idToken?.getClaim("sub")
                                                mapData["nonce"] = token?.idToken?.getClaim("nonce")
                                                mapData["iss"] = token?.idToken?.getClaim("iss")
                                                mapData["exp"] = token?.idToken?.getClaim("exp")
                                                mapData["iat"] = token?.idToken?.getClaim("iat")
                                                mapData["cognito:username"] = token?.idToken?.getClaim("cognito:username")
                                                mapData["cognito:groups"] = token?.idToken?.getClaim("cognito:groups")
                                                val jsonData: String = gson.toJson(mapData)
                                                this@FlutterAwsPlugin.activity.runOnUiThread {
                                                    result.success(jsonData)
                                                }
                                            }

                                            override fun onError(e: Exception?) {
                                                print(e?.message)
                                            }

                                        })
                                    }

                                    override fun onError(e: Exception) {
                                        Log.e("LOGIN", "onError: ", e)
                                    }
                                })
                    }

                    override fun onError(e: Exception) {
                        Log.e("INIT", "Initialization error.", e)
                    }
                }
                )

            }
            call.method == "signOut" -> {
                AWSMobileClient.getInstance()
                        .signOut(SignOutOptions.builder().invalidateTokens(true).build(), object : Callback<Void> {
                            override fun onResult(result: Void?) {

                            }

                            override fun onError(e: Exception?) {
                            }
                        })
            }
            call.method == "getToken" -> {
                AWSMobileClient.getInstance().getTokens(object: Callback<Tokens>{
                    override fun onResult(token: Tokens?) {
                        this@FlutterAwsPlugin.activity.runOnUiThread {
                            result.success(token?.idToken?.tokenString)
                        }
                    }

                    override fun onError(e: java.lang.Exception?) {
                        Log.i("Error",e?.message)
                    }


                })
            }
            else -> {
                result.notImplemented()
            }
        }
    }
}
// Try with call back
