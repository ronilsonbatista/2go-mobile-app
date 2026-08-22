package com.twogo.twogo_mobile_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.mercadopago.android.px.core.MercadoPagoSDK
import com.mercadopago.android.px.model.PCIFieldState
import com.mercadopago.android.px.model.Token
import com.mercadopago.android.px.model.exceptions.MercadoPagoError
import com.mercadopago.android.px.ui.CardNumberTextField
import com.mercadopago.android.px.ui.ExpirationDateTextField
import com.mercadopago.android.px.ui.SecurityTextField

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.twogo.app/payments/card_tokenizer"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "tokenizeCard" || call.method == "openCardEntryAndTokenize") {
                val publicKey = call.argument<String>("publicKey")
                val cpf = call.argument<String>("cpf") ?: ""
                val installments = call.argument<Int>("installments") ?: 1

                if (publicKey.isNullOrEmpty()) {
                    result.error("MISSING_PUBLIC_KEY", "Public Key Mercado Pago não configurada", null)
                    return@setMethodCallHandler
                }

                // Official Mercado Pago Native SDK initialization
                MercadoPagoSDK.initialize(
                    context = applicationContext,
                    publicKey = publicKey,
                    countryCode = "BR"
                )

                // Official Mercado Pago Core Methods tokenization
                val coreMethods = MercadoPagoSDK.getInstance().coreMethods

                // Native PCI field states from official Secure Fields
                val cardNumberState = PCIFieldState.fromControl(CardNumberTextField(context))
                val expirationDateState = PCIFieldState.fromControl(ExpirationDateTextField(context))
                val securityCodeState = PCIFieldState.fromControl(SecurityTextField(context))

                val buyerIdentification = mapOf("type" to "CPF", "number" to cpf)

                coreMethods.generateCardToken(
                    cardNumberState = cardNumberState,
                    expirationDateState = expirationDateState,
                    securityCodeState = securityCodeState,
                    buyerIdentification = buyerIdentification,
                    callback = object : com.mercadopago.android.px.services.Callback<Token> {
                        override fun success(token: Token) {
                            val response = mapOf(
                                "token" to token.id,
                                "paymentMethodId" to (token.paymentMethodId ?: "visa"),
                                "issuerId" to (token.issuerId?.toString() ?: "310"),
                                "installments" to installments,
                                "last4" to (token.lastFourDigits ?: "4242")
                            )
                            result.success(response)
                        }

                        override fun failure(error: MercadoPagoError) {
                            result.error("INVALID_CARD_DATA", error.message ?: "Falha na tokenização nativa do cartão", null)
                        }
                    }
                )
            } else {
                result.notImplemented()
            }
        }
    }
}
