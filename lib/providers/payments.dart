import 'dart:convert';

import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:shop/models/stripe_const.dart';
class Payments {
  
  makePayment(
    String amount,
    String? email,
    String? name,
    String? number,
    String? address,
    String? city,
    String? state,
    String? postalCode,
  ) async {
    int a=(double.parse(amount)*1).round();
    amount=a.toString();
    // create payment intent
    print('intnet called');
    final paymentIntentData = await _createPaymentIntent(amount);
    print('received intent');
    print(paymentIntentData);
    //billing address
    final billingDetails = BillingDetails(
      name: name ?? 'Flutter Stripe',
      email: email ?? 'email@stripe.com',
      phone: number ?? '+48888000888',
      address: Address(
        city: city ?? 'Houston',
        country: 'IND',
        line1: address ?? '1459  Circle Drive',
        line2: '',
        state: state ?? 'Delhi',
        postalCode: postalCode ?? '248001',
      ),
    );
    // initiate payment at server
    print('initSheet called');
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: paymentIntentData!['client_secret'],
        customerEphemeralKeySecret: paymentIntentData!['ephemeralkey'],
        applePay: const PaymentSheetApplePay(merchantCountryCode: 'IND'),
        googlePay: const PaymentSheetGooglePay(
          merchantCountryCode: 'IND',
          testEnv: true,
        ),
        merchantDisplayName: 'Test ',
        billingDetails: billingDetails,
      ),
    );
    // show payment sheet
    print('display called');
    bool ans= await _displayPaymentSheet();
    Map<String,dynamic> mp={
      'success': ans,
      'payment_id': ans==true?paymentIntentData!['client_secret']:''
    };
    return mp;
  }

  _createPaymentIntent(String? amt) async {
    Map<String, dynamic> mp = {
      'amount': amt ?? '1200',
      'currency': 'INR',
      'payment_method_types[]': 'card'
    };
    final response = await http.post(
      Uri.parse('https://api.stripe.com/v1/payment_intents'),
      body: mp,
      headers: {
        'Authorization': 'Bearer $stripeSecretKey',
        'content_type': 'application/x-www-form-urlencoded',
      },
    );
    // return intent received
    return jsonDecode(response.body);
  }

  _displayPaymentSheet() async {
    try {
      final x = await Stripe.instance.presentPaymentSheet();
      return true;
    } on StripeException catch (e) {
      print(e);
      return false;
    }
  }
}
