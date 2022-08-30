import 'package:flutter/material.dart';
import 'package:shop/providers/card_item.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/order.dart';
import 'package:shop/widgit/rating_dialog.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);
  static const routeName = '/cartpage';

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    final cartObj = Provider.of<Cart>(context);
    final sc = ScaffoldMessenger.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(10),
            child: Row(
              children: [
                const Text(
                  'Total Amount:',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(
                  width: 10,
                ),
                Chip(
                  label: Text(
                    '₹${cartObj.totalPrice}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.teal,
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: cartObj.totalPrice <= 0
                      ? null
                      : () async {
                          await Provider.of<Order>(context, listen: false)
                              .addOrder(
                            cartObj.mp.values.toList(),
                            cartObj.totalPrice,
                          )
                              .then((value) async{
                            List<CardItem> t = cartObj.mp.values.toList();
                            showDialog(
                              context: context,
                              builder: (_) => RatingDialog(
                                pos: 0,
                                mp: t,
                              ),
                            );
                            await cartObj.clear();
                            sc.removeCurrentSnackBar();
                            sc.showSnackBar(
                              const SnackBar(
                                content: Text('Order Placed'),
                              ),
                            );
                          }).catchError(
                            (error) {
                              print(error);
                              sc.removeCurrentSnackBar();
                              sc.showSnackBar(
                                const SnackBar(
                                  content: Text('Unable to order'),
                                ),
                              );
                            },
                          );
                        },
                  child: const Text(
                    'Order Now',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                )
              ],
            ),
          ),
          Expanded(
              child: ListView.builder(
            itemCount: cartObj.mpLength,
            itemBuilder: (context, i) => EachCardItem(
                q: cartObj.mp.values.toList()[i].quantity,
                title: cartObj.mp.values.toList()[i].title,
                id: cartObj.mp.values.toList()[i].id,
                eachPrice: double.parse(cartObj.mp.values.toList()[i].price)),
          ))
        ],
      ),
    );
  }
}

class EachCardItem extends StatelessWidget {
  final String title, id;
  final double eachPrice;
  final int q;
  const EachCardItem(
      {Key? key,
      required this.q,
      required this.title,
      required this.id,
      required this.eachPrice})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final cartObj = Provider.of<Cart>(context);
    double totSum = q * eachPrice;
    return Dismissible(
      key: ValueKey(id),
      background: Container(
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white, size: 40),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Are You Sure?'),
              content: const Text('You want to delete this item?'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Yes'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('No'),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) async {
        // delete all quantty
        await cartObj.removeEle(id).then(
          (value) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Item Deleted',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        padding: const EdgeInsets.all(3),
        child: Row(
          children: [
            Column(
              children: [
                Text(title, style: const TextStyle(fontSize: 16)),
                Text(
                  'Price/item: ₹$eachPrice',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            const Spacer(),
            IconButton(
              onPressed: () async {
                await cartObj.deleteEle(id);
              }, // reduce quantity
              icon: const Icon(
                Icons.minimize,
                color: Colors.grey,
              ),
            ),
            Text(
              'Qty: $q',
              style: const TextStyle(fontSize: 16),
            ),
            IconButton(
              onPressed: () async {
                await cartObj.add(id, (eachPrice * q).toString(), title);
              }, // reduce quantity
              icon: const Icon(
                Icons.add,
                color: Colors.red,
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            Flexible(
              child: Text(
                '₹$totSum',
                style: const TextStyle(fontSize: 12),
              ),
            )
          ],
        ),
      ),
    );
  }
}
