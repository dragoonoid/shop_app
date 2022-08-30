import 'package:flutter/material.dart';
import 'package:shop/models/product.dart';
import 'package:shop/providers/card_item.dart';
import 'package:shop/providers/category_prod.dart';
import 'package:shop/screens/cart.dart';
import 'package:shop/screens/particular_categ_prod_screen.dart';
import 'package:shop/screens/search.dart';
import 'package:shop/widgit/app_drawer.dart';
import 'package:shop/widgit/badge.dart';
import '../providers/provider_prod.dart';
import 'package:provider/provider.dart';
import 'package:shop/widgit/product_item.dart';

class ProductLoadingScreen extends StatefulWidget {
  static const routeName = '/productLoadingScreen';
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
    if (firstTimeLoadData == true) {
      setState(() {
        isLoading = true;
      });
      Provider.of<ProviderProd>(context, listen: false)
          .getItemsFirebase()
          .then((_) {
            Provider.of<Cart>(context,listen: false).getCartItemsFromFirebase();
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
    var categProv = Provider.of<CategoryProd>(context);
    final obj = Provider.of<ProviderProd>(context);
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Shop App'), actions: [
        IconButton(
          icon: const Icon(
            Icons.search,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const Search(),
              ),
            );
          },
        ),
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
          : SafeArea(
              child: SingleChildScrollView(
                physics: const ScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Categories',
                        style: TextStyle(
                          fontSize: 30,
                          //fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.2,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemBuilder: ((_, i) {
                            return Container(
                              margin: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ParticularCategProdScreen(
                                                  categ:
                                                      categProv.maincateg[i]),
                                        ),
                                      );
                                    },
                                    child: CircleAvatar(
                                      backgroundImage:
                                          AssetImage(categProv.images[i]),
                                      radius: 30,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(categProv.maincateg[i]),
                                ],
                              ),
                            );
                          }),
                          itemCount: categProv.maincateg.length,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      const Text(
                        'Recently Added',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 25,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      SizedBox(
                        //height: MediaQuery.of(context).size.height * 0.7,
                        child: Grid(
                          obj: obj,
                          showFav: showFav,
                          categP: categProv,
                          showCateg: false,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (_, i) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                categProv.maincateg[i],
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 25,
                                ),
                              ),
                              Grid(
                                obj: obj,
                                showFav: showFav,
                                showCateg: true,
                                categP: categProv,
                                categ: categProv.maincateg[i],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          );
                        },
                        itemCount: categProv.maincateg.length,
                      ),
                    ],
                  ),
                ),
              ),
            ),
      drawer: const AppDrawer(),
    );
  }
}

class Grid extends StatelessWidget {
  const Grid(
      {Key? key,
      required this.obj,
      required this.showFav,
      required this.showCateg,
      required this.categP,
      this.categ = 'none'})
      : super(key: key);

  final ProviderProd obj;
  final bool showFav;
  final bool showCateg;
  final CategoryProd categP;
  final String categ;
  @override
  Widget build(BuildContext context) {
    List<Product> list = [];
    if (showCateg == true) {
      list = obj.items.where((element) => element.categ == categ).toList();
    } else {
      if (showFav == true) {
        list = obj.favItem;
      } else {
        list = obj.items;
      }
    }
    list = list.reversed.toList();
    return SizedBox(
      height: 250,
      child: GridView.builder(
        // physics: NeverScrollableScrollPhysics(),
        // shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          //mainAxisSpacing: 10,
          //crossAxisSpacing: 10,
          childAspectRatio: 2 / 3,
        ),
        itemCount: list.length,
        itemBuilder: (context, i) => ChangeNotifierProvider.value(
            value: list[i], child: const ProductItem()),
      ),
    );
  }
}
