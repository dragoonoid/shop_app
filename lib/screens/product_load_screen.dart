import 'package:flutter/material.dart';
import 'package:shop/models/product.dart';
import 'package:shop/providers/card_item.dart';
import 'package:shop/screens/cart.dart';
import 'package:shop/widgit/app_drawer.dart';
import 'package:shop/widgit/badge.dart';
import '../providers/provider_prod.dart';
import 'package:provider/provider.dart';
import 'package:shop/widgit/product_item.dart';

class ProductLoadingScreen extends StatefulWidget {
  static const routeName='/productLoadingScreen';
  const ProductLoadingScreen({Key? key}) : super(key: key);
  @override
  State<ProductLoadingScreen> createState() => _ProductLoadingScreenState();
}

class _ProductLoadingScreenState extends State<ProductLoadingScreen> {
  bool showFav = false;
  bool firstTimeLoadData = true;
  bool isLoading = false;
  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    if (firstTimeLoadData == true) {
      setState(() {
        isLoading = true;
      });
      Provider.of<ProviderProd>(context,listen: false).getItemsFirebase().then((_) {
        setState(() {
          isLoading = false;
        });
      });
    }
    firstTimeLoadData = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final obj = Provider.of<ProviderProd>(context);
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Shop App'), actions: [
        PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              child: Text('Show Fav'),
              value: 0,
            ),
            const PopupMenuItem(
              child: Text('Show All'),
              value: 1,
            )
          ],
          onSelected: (int item) {
            setState(() {
              if (item == 0) {
                showFav = true;
              } else {
                showFav = false;
              }
            });
          },
        ),
        Badge(
          color: Colors.redAccent,
          count: cart.count.toString(),
          icon: IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.of(context).pushNamed(CartPage.routeName);
            },
          ),
        ),
      ]),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
              color: Colors.red,
            ))
          : Grid(
              obj: obj,
              showFav: showFav,
            ),
      drawer: const AppDrawer(),
    );
  }
}

class Grid extends StatelessWidget {
  const Grid({Key? key, required this.obj, required this.showFav})
      : super(key: key);

  final ProviderProd obj;
  final bool showFav;

  @override
  Widget build(BuildContext context) {
    List<Product> list = [];
    if (showFav == true) {
      list = obj.favItem;
    } else {
      list = obj.items;
    }
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        //mainAxisSpacing: 10,
        //crossAxisSpacing: 10,
        childAspectRatio: 1.5,
      ),
      itemCount: list.length,
      itemBuilder: (context, i) => ChangeNotifierProvider.value(
          value: list[i], child: const ProductItem()),
    );
  }
}
