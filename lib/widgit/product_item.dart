import 'package:flutter/material.dart';
import 'package:shop/providers/auth.dart';
import 'package:shop/providers/card_item.dart';
import 'package:shop/screens/product_overview_screen.dart';
import 'package:provider/provider.dart';
import 'package:shop/models/product.dart';

class ProductItem extends StatelessWidget {
  const ProductItem({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    final list = Provider.of<Product>(context);
    final authObj=Provider.of<Auth>(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: GridTile(
          child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ProductOverview(
                          id: list.id,
                        )));
              },
              child: Image.network(
                list.imageUrl,
                fit: BoxFit.cover,
              )),
          footer: GridTileBar(
            title: Text(
              list.title,
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.black54,
            leading: IconButton(
              icon: Icon(
                  list.isFav == true ? Icons.favorite : Icons.favorite_border),
              onPressed: () async {
                await list.changeFav(authObj.token,authObj.userId).catchError((error) {
                  scaffold.showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Unable to add favourate',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                });
              },
              color: Colors.redAccent,
            ),
            trailing: Consumer<Cart>(
              builder: (_, cart, ch) => IconButton(
                icon: const Icon(Icons.shopping_bag_outlined),
                onPressed: () {
                  cart.add(list.id, list.price.toString(), list.title);
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
                },
                color: Colors.redAccent,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
