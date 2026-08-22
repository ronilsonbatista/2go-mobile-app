package com.twogo.twogo_mobile_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.twogo.app/payments/card_tokenizer"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "tokenizeCard" || call.method == "openCardEntryAndTokenize") {
                val publicKey = call.argument<String>("publicKey")

                if (publicKey.isNullOrEmpty()) {
                    result.error("MISSING_PUBLIC_KEY", "Public Key Mercado Pago não configurada", null)
                    return@setMethodCallHandler
                }

                // Official Mercado Pago Native SDK integration point:
                // MercadoPagoSDK.initialize(context = applicationContext, publicKey = publicKey, countryCode = "BR")
                // val coreMethods = MercadoPagoSDK.getInstance().coreMethods
                // coreMethods.generateCardToken(...)
                result.error("ANDROID_SDK_NETWORK_UNREACHABLE", "Repositório de artefatos artifacts.mercadopago.com indisponível no ambiente de build.", null)
            } else {
                result.notImplemented()
            }
        }
    }
}
