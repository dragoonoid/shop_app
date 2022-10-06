import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shop/models/stripe_const.dart';
import 'package:shop/providers/auth.dart';
import 'package:shop/providers/card_item.dart';
import 'package:shop/providers/category_prod.dart';
import 'package:shop/providers/order.dart';
import 'package:shop/providers/provider_prod.dart';
import 'package:shop/providers/review_provider.dart';
import 'package:shop/screens/app_front_page.dart';
import 'package:shop/screens/auth_screen.dart';
import 'package:shop/screens/cart.dart';
import 'package:shop/screens/edit_product_screen.dart';
import 'package:shop/screens/prev_order.dart';
import 'package:shop/screens/product_load_screen.dart';
import 'package:provider/provider.dart';
import 'package:shop/screens/user_product_screen.dart';
//import 'package:flutter_stripe/flutter_stripe.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Stripe.publishableKey = stripePublishedKey;
  // Stripe.merchantIdentifier='merchant.flutter.stripe.test';
  // Stripe.urlScheme='flutterstripe';
  // await Stripe.instance.applySettings();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Auth()),
        ChangeNotifierProxyProvider<Auth, ProviderProd>(// when any of the obj changes (auth or providerprod) and notifylistner is called
          create: (context) => ProviderProd(),          //then update mehtod is called and token is updated
          update: (_, auth, provider) =>
              provider!..updateToken(auth.token, auth.userId),
        ),
        ChangeNotifierProvider(create: (context) => Cart()),
        ChangeNotifierProxyProvider<Auth, Cart>(
          create: (context) => Cart(),
          update: (_, auth, provider) =>
              provider!..updateToken(auth.token, auth.userId),
        ),
        ChangeNotifierProxyProvider<Auth, Order>(
          create: (context) => Order(),
          update: (_, auth, provider) =>
              provider!..updateToken(auth.token, auth.userId),
        ),
        ChangeNotifierProxyProvider<Auth, CategoryProd>(
          create: (context) => CategoryProd(),
          update: (_, auth, provider) =>
              provider!..updateToken(auth.token, auth.userId),
        ),
        ChangeNotifierProxyProvider<Auth, ReviewProvider>(
          create: (context) => ReviewProvider(),
          update: (_, auth, provider) =>
              provider!..updateToken(auth.token, auth.userId),
        ),
      ],
      child: Consumer<Auth>(builder: (ctx, objAuth, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.purple,
            //primarySwatch: Color.fromRGBO(143, 148, 251, 1),
          ),
          //home: const ProductLoadingScreen(),
          home: objAuth.isAuth
              ? const ProductLoadingScreen()
              : FutureBuilder(
                  future: objAuth.tryAutoLogIn(),
                  builder: (ctx, snapshot) =>
                      snapshot.connectionState == ConnectionState.waiting
                          ? //const SpinKitWave(color: Colors.yellow,)
                          const Scaffold(
                            body: SpinKitWave(color: Colors.yellow,)
                          )
                          : AuthScreen(),
                ),
          routes: {
            ProductLoadingScreen.routeName: (context) =>
                const ProductLoadingScreen(),
            CartPage.routeName: (context) => const CartPage(),
            PreviousOrder.orderKey: (context) => const PreviousOrder(),
            UserProductScreen.routeName: (context) => const UserProductScreen(),
            EditProductScreen.routeName: (context) => const EditProductScreen()
          },
        );
      }),
    );
  }
}
