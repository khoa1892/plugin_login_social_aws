package com.skg.flutter_aws_plugin

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.util.Log
import com.amazonaws.mobile.client.AWSMobileClient
import com.amazonaws.mobile.client.Callback
import com.amazonaws.mobile.client.UserState
import com.amazonaws.mobile.client.UserStateDetails
import com.amazonaws.mobile.client.results.Tokens
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.lang.Exception

class FlutterAwsPlugin @SuppressLint("ObsoleteSdkInt") constructor(var context: Context, var activity: Activity, var registrar: Registrar): MethodCallHandler {
  val REQUEST_CODE_FACEBOOK = 1
  val REQUEST_CODE_GOOGLE = 2
  val REQUEST_CODE_LOGOUT = 3

  var data: String =""
  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "flutter_aws_plugin")
      channel.setMethodCallHandler(FlutterAwsPlugin(registrar.activity().baseContext, registrar.activity(), registrar))
    }
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when {
      call.method == "loginByFacebook" -> {
        val intent = Intent(activity.applicationContext, LoginWithHostedUI::class.java)
        val bundle = Bundle()
        bundle.putBoolean("facebook", true)
        intent.putExtras(bundle)
        activity.startActivityForResult(intent, REQUEST_CODE_FACEBOOK)
      }
      call.method == "loginByGoogle" -> {
        val intent = Intent(activity.applicationContext, LoginWithHostedUI::class.java)
        val bundle = Bundle()
        bundle.putBoolean("google", true)
        intent.putExtras(bundle)
        activity.startActivityForResult(intent, REQUEST_CODE_GOOGLE)

      }
      call.method == "signOut" -> {
        val intent = Intent(activity.applicationContext, LoginWithHostedUI::class.java)
        val bundle = Bundle()
        bundle.putBoolean("logOut", true)
        intent.putExtras(bundle)
        activity.startActivityForResult(intent, REQUEST_CODE_LOGOUT)
      }
      else -> {
        result.notImplemented()
      }
    }
    registrar.addActivityResultListener { requestCode, resultCode, intent ->
      if (requestCode == REQUEST_CODE_GOOGLE && resultCode == 0 || requestCode == REQUEST_CODE_FACEBOOK && resultCode == 0) {
          Handler().postDelayed({
          }, 1000)
        AWSMobileClient.getInstance().initialize(activity.applicationContext,object: Callback<UserStateDetails>{
          override fun onResult(state: UserStateDetails?) {
              if(state?.userState== UserState.SIGNED_IN){
                AWSMobileClient.getInstance().getTokens(object: Callback<Tokens> {
                  override fun onResult(token: Tokens?) {
                    result.success(mapOf("email" to token?.idToken?.getClaim("email"),
                            "name" to token?.idToken?.getClaim("name")))
                    Log.d("LOGIN", "onResult: success" )
                    return
                  }

                  override fun onError(e: Exception?) {
                    result.error(e?.message,e?.localizedMessage,e)
                    return
                  }

                })

              }
          }

          override fun onError(e: Exception?) {
          }

        })
        intent.getStringArrayExtra("email")

      }else if(requestCode == REQUEST_CODE_LOGOUT && resultCode == 0 ){
        AWSMobileClient.getInstance().initialize(activity.applicationContext,object: Callback<UserStateDetails>{
          override fun onResult(state: UserStateDetails?) {
            result.success(mapOf("state" to state?.details?.values))
            return
          }

          override fun onError(e: Exception?) {
            result.error(e?.message,e?.localizedMessage,null)

          }


        })
      }else{

      }
      true
    }
  }
}
// Try with call back
