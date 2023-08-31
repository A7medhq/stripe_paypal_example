import 'dart:convert';
import 'dart:io';

import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:stripe_example/consts.dart';

class PaymentsManager {
//amount, currency , secret <- http request -> client secret

  static Future<String> makePaymentIntent(
      String amount, String currency) async {
    final response = await http
        .post(Uri.parse('https://api.stripe.com/v1/payment_intents'), headers: {
      HttpHeaders.authorizationHeader: 'Bearer ${ApiKeys.secretKey}'
    }, body: {
      'amount': amount,
      'currency': currency
    });

    return jsonDecode(response.body)['client_secret'];
  }

// payment sheet <- client secret

  static Future<void> initPaymentSheet(String clientSecret) async {
    await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: clientSecret,
            merchantDisplayName: 'Ahmed'));
  }

  static Future<void> makePayment(String amount, String currency) async {
    try {
      String clientSecret = await makePaymentIntent(amount, currency);
      await initPaymentSheet(clientSecret);

      Stripe.instance.presentPaymentSheet();
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
