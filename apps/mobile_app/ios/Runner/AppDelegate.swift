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
        let installments = (args["installments"] as? Int) ?? 1

        let response: [String: Any] = [
          "token": "mp_tok_ios_native_\(Int(Date().timeIntervalSince1990))",
          "paymentMethodId": "visa",
          "issuerId": "310",
          "installments": installments,
          "last4": "4242"
        ]
        result(response)
      } else {
        result(FlutterMethodNotImplemented)
      }
    })

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
