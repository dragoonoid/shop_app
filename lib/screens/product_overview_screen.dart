import 'package:flutter/material.dart';
import 'package:shop/models/product.dart';
import 'package:shop/providers/card_item.dart';
import 'package:shop/providers/provider_prod.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/review_provider.dart';
import 'package:shop/screens/cart.dart';
import 'package:shop/screens/product_load_screen.dart';
import 'package:shop/widgit/badge.dart';
import 'package:shop/widgit/review_list.dart';

class ProductOverview extends StatefulWidget {
  final String id;
  const ProductOverview({Key? key, required this.id}) : super(key: key);

  @override
  State<ProductOverview> createState() => _ProductOverviewState();
}

class _ProductOverviewState extends State<ProductOverview> {
  bool firstLoad = true;
  bool isLoading = false;
  int selected = 0;
  //String x = '1'; // filter value
  @override
  void initState() {
    if (firstLoad == true) {
      setState(() {
        isLoading = true;
      });
      Provider.of<ReviewProvider>(context, listen: false)
          .getReviewsFromFirebase(widget.id)
          .then((value) {
        firstLoad = false;
        setState(() {
          isLoading = false;
        });
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final list = Provider.of<ProviderProd>(context).findId(widget.id);
    final cart = Provider.of<Cart>(context);
    final scaffold = ScaffoldMessenger.of(context);
    return isLoading
        ? const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Colors.purple,
              ),
            ),
          )
        : Scaffold(
            bottomNavigationBar: Container(
              color: Colors.white54,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 50,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Price',
                          style: TextStyle(color: Colors.grey),
                        ),
                        Text(
                          list.price.toString() + ' ₹',
                          style: const TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: (() async {
                      await cart
                          .add(list.id, list.price.toString(), list.title)
                          .then((value) {
                        scaffold.removeCurrentSnackBar();
                        scaffold.showSnackBar(
                          SnackBar(
                            content: const Text('Added to Cart Successfully!'),
                            duration: const Duration(seconds: 5),
                            action: SnackBarAction(
                              label: 'Undo',
                              onPressed: () {
                                cart.deleteEle(list.id);
                              },
                            ),
                          ),
                        );
                      });
                    }),
                    child: Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width * 0.4,
                      decoration: BoxDecoration(
                          color: Colors.purple,
                          borderRadius: BorderRadius.circular(20)),
                      child: const Center(
                          child: Text(
                        'Add to Cart',
                        style: TextStyle(color: Colors.white),
                      )),
                    ),
                  ),
                ],
              ),
            ),
            appBar: AppBar(
              backgroundColor: Colors.white54,
              elevation: 0,
              title: Text(list.title),
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: ((context) => const ProductLoadingScreen()),
                    ),
                  );
                },
              ),
              actions: [
                Badge(
                  color: Colors.redAccent,
                  count: cart.count.toString(),
                  icon: IconButton(
                    icon: const Icon(
                      Icons.shopping_cart,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.of(context).pushNamed(CartPage.routeName);
                    },
                  ),
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Container(
                color: Colors.white54,
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      list.title,
                      style: const TextStyle(fontSize: 30),
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Center(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: Card(
                          elevation: 40,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          child: Image.network(
                            list.imageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    _tabSection(context, list),
                  ],
                ),
              ),
            ),
          );
  }

  Widget _tabSection(BuildContext context, Product list) {
    return DefaultTabController(
      length: 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            child: TabBar(
                labelColor: Colors.black,
                indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(50), // Creates border
                    color: Colors.greenAccent),
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: "Overview"),
                  Tab(text: "Reviews"),
                ]),
          ),
          Container(
            constraints:
                BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
            child: TabBarView(
              children: [
                Container(
                  constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height),
                  child: Text(
                    list.desc,
                    style: const TextStyle(color: Colors.grey, fontSize: 20),
                  ),
                ),
                Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height,
                  ),
                  child: const ReviewList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
