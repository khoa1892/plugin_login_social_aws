package com.skg.flutter_aws_plugin

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import com.amazonaws.mobile.client.*
import com.amazonaws.mobile.client.results.Tokens


class LoginWithHostedUI : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val bundle = intent.extras
        if (bundle?.getBoolean("facebook") != null && bundle.getBoolean("facebook")) {
            loginWithFaceBook()
        } else if (bundle?.getBoolean("google") != null && bundle.getBoolean("google")) {
            loginWithGoogle()
        } else if (bundle?.getBoolean("logOut") != null && bundle.getBoolean("logOut")) {
            logOut()
        }
    }

    private fun loginWithFaceBook() {
        AWSMobileClient.getInstance().initialize(applicationContext, object : Callback<UserStateDetails> {
            override fun onResult(userStateDetails: UserStateDetails) {
                val hostedUIOptions = HostedUIOptions.builder()
                        .scopes("openid", "email")
                        .identityProvider("Facebook")
                        .build()

                val signInUIOptions = SignInUIOptions.builder()
                        .hostedUIOptions(hostedUIOptions)
                        .build()
                AWSMobileClient.getInstance()
                        .showSignIn(this@LoginWithHostedUI, signInUIOptions, object : Callback<UserStateDetails> {
                            override fun onResult(details: UserStateDetails) {
                                Log.d("LOGIN", "onResult: " + details.userState)
                                print(details.details)
                                val intent = Intent()

                                AWSMobileClient.getInstance().getTokens(object: Callback<Tokens> {
                                    override fun onResult(token: Tokens?) {
                                        token?.idToken?.getClaim("email")
                                        intent.putExtra("email", token?.idToken?.getClaim("email"))
                                        return
                                    }

                                    override fun onError(e: java.lang.Exception?) {
                                        print(e?.message)
                                        return
                                    }

                                })
                                setResult(RESULT_OK, intent)
                                finish()

                            }

                            override fun onError(e: Exception) {
                                Log.e("LOGIN", "onError: ", e)
                                finish()

                            }
                        })

            }

            override fun onError(e: Exception) {
                Log.e("INIT", "Initialization error.", e)
                finish()

            }
        }
        )
    }

    private fun loginWithGoogle() {
        AWSMobileClient.getInstance().initialize(applicationContext, object : Callback<UserStateDetails> {
            override fun onResult(userStateDetails: UserStateDetails) {
                val hostedUIOptions = HostedUIOptions.builder()
                        .scopes("openid", "email")
                        .identityProvider("Google")
                        .build()

                val signInUIOptions = SignInUIOptions.builder()
                        .hostedUIOptions(hostedUIOptions)
                        .build()

                AWSMobileClient.getInstance()
                        .showSignIn(this@LoginWithHostedUI, signInUIOptions, object : Callback<UserStateDetails> {
                            override fun onResult(details: UserStateDetails) {
                                Log.d("LOGIN", "onResult: " + details.userState)
                                val intent = Intent()
                                intent.putExtra("login", "Login Google success")
                                setResult(RESULT_OK, intent)
                                finish()

                            }

                            override fun onError(e: Exception) {
                                Log.e("LOGIN", "onError: ", e)
                                finish()
                            }
                        })
            }

            override fun onError(e: Exception) {
                Log.e("INIT", "Initialization error.", e)
                finish()

            }
        }
        )
    }

    private fun logOut() {
        AWSMobileClient.getInstance()
                .signOut(SignOutOptions.builder().invalidateTokens(true).build(), object : Callback<Void> {
                    override fun onResult(result: Void?) {
                        val intent = Intent()
                        intent.putExtra("login", "LogOut success")
                        setResult(RESULT_OK, intent)
                    }

                    override fun onError(e: Exception?) {
                        Log.e("SIGNOUT", "onError: ", e)
                        intent.putExtra("login", e?.message)
                        setResult(RESULT_OK, intent)
                    }
                })
        finish()
    }

    override fun onResume() {
        super.onResume()
        val activityIntent = intent
        if (activityIntent.data != null && "myapp" == activityIntent.data!!.scheme) {
            AWSMobileClient.getInstance().handleAuthResponse(activityIntent)
            Handler().postDelayed({
                finish()
            }, 1000)

        }
    }
}