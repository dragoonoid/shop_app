// import 'dart:convert';

// import 'package:flutter_stripe/flutter_stripe.dart';
// import 'package:http/http.dart' as http;
// import 'package:shop/models/stripe_const.dart';

// class Payments {
//   makePayment() async {
//     // create payment intent
//     final paymentIntentData = _createPaymentIntent();
//     await Stripe.instance.initPaymentSheet(
//       paymentSheetParameters: SetupPaymentSheetParameters(
//         paymentIntentClientSecret: paymentIntentData!['client_secret'],
//         applePay: const PaymentSheetApplePay(merchantCountryCode: 'IND'),
//         googlePay: const PaymentSheetGooglePay(
//           merchantCountryCode: 'IND',
//           testEnv: true,
//         ),
//         merchantDisplayName: 'Test ',
//       ),
//     );
//     await _displayPaymentSheet();
//   }

//   _createPaymentIntent() async {
//     Map<String, dynamic> mp = {
//       'amount': 1200,
//       'currency': 'INR',
//       'payment_mathod_types[]': 'card'
//     };
//     final response = await http.post(
//       Uri.parse('http://api.stripe.com/v1/payment_intents'),
//       body: mp,
//       headers: {
//         'Authorization': 'Bearer $stripeSecretKey',
//         'content_type': 'application/x-www-form-urlencoded',
//       },
//     );
//     return jsonDecode(response.body);
//   }

//   _displayPaymentSheet()async {
//     await Stripe.instance.presentPaymentSheet();
//   }
// }
