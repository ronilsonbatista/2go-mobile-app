import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    let cardChannel = FlutterMethodChannel(
      name: "com.twogo.app/payments/card_tokenizer",
      binaryMessenger: controller.binaryMessenger
    )

    cardChannel.setMethodCallHandler({ (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "tokenizeCard" {
        guard let args = call.arguments as? [String: Any],
              let publicKey = args["publicKey"] as? String, !publicKey.isEmpty else {
          result(FlutterError(code: "MISSING_PUBLIC_KEY", message: "Public Key Mercado Pago não configurada", details: nil))
          return
        }

        // Official Mercado Pago Swift SDK integration point
        // MercadoPagoSDK.shared.initialize(publicKey: publicKey)
        // CoreMethods.generateCardToken(...) returns real token from Mercado Pago API
        result(FlutterError(code: "IOS_RUNTIME_NOT_VALIDATED", message: "Ambiente iOS sem Xcode completo para validação nativa de runtime.", details: nil))
      } else {
        result(FlutterMethodNotImplemented)
      }
    })

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
