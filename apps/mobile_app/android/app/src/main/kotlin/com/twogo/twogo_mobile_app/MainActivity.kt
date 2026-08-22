package com.twogo.twogo_mobile_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.twogo.app/payments/card_tokenizer"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "tokenizeCard") {
                val publicKey = call.argument<String>("publicKey")
                val installments = call.argument<Int>("installments") ?: 1

                if (publicKey.isNull_or_empty()) {
                    result.error("MISSING_PUBLIC_KEY", "Public Key Mercado Pago não configurada", null)
                    return@setMethodCallHandler
                }

                // Simulate Mercado Pago Native Card Tokenization Response on Android
                // In production build, MercadoPagoCore.createToken(...) receives secure fields in memory
                val response = mapOf(
                    "token" to "mp_tok_android_native_${System.currentTimeMillis()}",
                    "paymentMethodId" to "visa",
                    "issuerId" to "310",
                    "installments" to installments,
                    "last4" to "4242"
                )

                result.success(response)
            } else {
                result.notImplemented()
            }
        }
    }
}

private fun String?.isNull_or_empty(): Boolean {
    return this == null || this.trim().isEmpty()
}
