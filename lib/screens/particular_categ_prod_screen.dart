import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/models/product.dart';
import 'package:shop/providers/category_prod.dart';
import 'package:shop/widgit/product_item.dart';

import '../widgit/app_drawer.dart';

class ParticularCategProdScreen extends StatefulWidget {
  final String categ;

  const ParticularCategProdScreen({Key? key, required this.categ})
      : super(key: key);

  @override
  State<ParticularCategProdScreen> createState() =>
      _ParticularCategProdScreenState();
}

class _ParticularCategProdScreenState extends State<ParticularCategProdScreen> {
  List<Product> list = [];
  bool firstLoad = true;
  bool circleIndicator = false;
  @override
  void didChangeDependencies() {
    if (firstLoad) {
      setState(() {
        circleIndicator = true;
      });
      Provider.of<CategoryProd>(context, listen: false)
          .getCategoryItemsFromFirebase(widget.categ)
          .then((value) {
        setState(() {
          circleIndicator = false;
        });
      });
      firstLoad = false;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    var obj = Provider.of<CategoryProd>(context);
    list = obj.items;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop App'),
      ),
      drawer: const AppDrawer(),
      body: circleIndicator
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : (list.isNotEmpty
              ? GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: list.length,
                  itemBuilder: (context, i) => ChangeNotifierProvider.value(
                      value: list[i], child: const ProductItem()),
                )
              : Image.network(
                  'https://images.unsplash.com/photo-1626881255770-2397375aad8d?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=385&q=80',
                  fit: BoxFit.fitHeight,
                )),
    );
  }
}
