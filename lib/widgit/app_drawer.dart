import 'package:flutter/material.dart';
import 'package:shop/providers/auth.dart';
import 'package:shop/screens/prev_order.dart';
import 'package:shop/screens/product_load_screen.dart';
import 'package:shop/screens/user_product_screen.dart';
import 'package:provider/provider.dart';
class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            title:const Text('My Shop'),
            automaticallyImplyLeading: false,
          ),
          ListTile(
            title:const Text('Shop'),
            onTap: (){
              Navigator.pushReplacementNamed(context, ProductLoadingScreen.routeName);
            },
          ),
          const Divider(thickness: 3,),
          ListTile(
            title:const Text('Order'),
            onTap: (){
              Navigator.pushReplacementNamed(context, PreviousOrder.orderKey);
            },
          ),
          const Divider(thickness: 3,),
          ListTile(
            title:const Text('Your Order'),
            onTap: (){
              Navigator.pushReplacementNamed(context, UserProductScreen.routeName);
            },
          ),
          const Divider(thickness: 3,),
          ListTile(
            title:const Text('Logout'),
            onTap: (){
              //Navigator.pushReplacementNamed(context, UserProductScreen.routeName);
              Navigator.of(context).pop();
              Provider.of<Auth>(context,listen: false).logout();
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
          const Divider(thickness: 3,),
        ],
      ),
    );
  }
}
