import 'package:flutter/material.dart';
import 'package:shop/providers/card_item.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/order.dart';
import 'package:shop/providers/payments.dart';
import 'package:shop/screens/product_load_screen.dart';
import 'package:shop/widgit/rating_dialog.dart';
import 'package:flutter/services.dart';
//import 'package:paytm_allinonesdk/paytm_allinonesdk.dart';
import 'package:shop/widgit/edit_text.dart';
import 'package:animated_button/animated_button.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);
  static const routeName = '/cartpage';

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // payment items------------------------
  // String mid = "", orderId = "", amount = "", txnToken = "";
  // String result = "";
  // bool isStaging = false;
  // bool isApiCallInprogress = false;
  // String callbackUrl = "";
  // bool restrictAppInvoke = false;
  // bool enableAssist = true;

  //Payments payment=Payments();
  //-----------------------------------------

  TextEditingController address = TextEditingController();
  TextEditingController phoneNo = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  bool showProd = true;
  Icon iconProd = const Icon(Icons.arrow_downward);
  Icon iconUser = const Icon(Icons.arrow_upward);
  var x = 0;
  @override
  void initState() {
    super.initState();
    Provider.of<Cart>(context, listen: false).updatePage(0);
  }

  togglePage(BuildContext context, int s) {
    if (s <= x) {
      return;
    }
    if (s - x >= 2 || x - s >= 2) {
      return;
    }
    if (s == 2) {
      // before moving to review
      if (!_formKey.currentState!.validate()) {
        return;
      }
    }
    Provider.of<Cart>(context, listen: false).updatePage(s);
    setState(() {
      s = x;
    });
  }

  finalSubmit(final cartObj) async {
    {
      final sc = ScaffoldMessenger.of(context);
      await Provider.of<Order>(context, listen: false)
          .addOrder(
        cartObj.mp.values.toList(),
        cartObj.totalPrice,
        name.text,
        email.text,
        phoneNo.text,
        address.text,
      )
          .then((value) async {
        List<CardItem> t = cartObj.mp.values.toList();
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const ProductLoadingScreen(),
            ),
            (route) => false);
        showDialog(
          context: context,
          builder: (_) => RatingDialog(
            pos: 0,
            mp: t,
          ),
        ).then((value) async {
          await cartObj.clear();
          sc.removeCurrentSnackBar();
          sc.showSnackBar(
            const SnackBar(
              content: Text('Order Placed'),
            ),
          );
        });
      }).catchError(
        (error) {
          sc.removeCurrentSnackBar();
          sc.showSnackBar(
            const SnackBar(
              content: Text('Unable to order'),
            ),
          );
        },
      );
    }
  }

  final _formKey = GlobalKey<FormState>();
  @override
  void dispose() {
    address.dispose();
    phoneNo.dispose();
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartObj = Provider.of<Cart>(context);
    x = cartObj.currentPage;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: GestureDetector(
        onTap: () {
          if (x == 3) {
            return;
          } else {
            togglePage(context, (x + 1));
          }
        },
        child: x == 3
            ? const SizedBox(
                height: 1,
                width: 1,
              )
            : Container(
                margin: const EdgeInsets.all(15),
                height: 50,
                width: MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                  color: x != 3
                      ? const Color.fromRGBO(143, 148, 251, 1)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Center(
                  child: Text(
                    'Submit ->',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
      ),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(143, 148, 251, 1),
        title: const Text('Cart'),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
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
                  // order button app bar
                  onPressed: (cartObj.totalPrice <= 0 || x != 3)
                      ? null
                      : () => finalSubmit(cartObj),
                  child: const Text(
                    'Order Now',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () => togglePage(context, 0),
                child: topBarGestureDetector(Icons.verified, 0, 'Product'),
              ),
              GestureDetector(
                onTap: () => togglePage(context, 1),
                child: topBarGestureDetector(Icons.verified, 1, 'Address'),
              ),
              GestureDetector(
                onTap: () => togglePage(context, 2),
                child: topBarGestureDetector(Icons.verified, 2, 'Preview'),
              ),
              GestureDetector(
                onTap: () => togglePage(context, 3),
                child: topBarGestureDetector(Icons.verified, 3, 'Payment'),
              ),
            ],
          ),
          x == 0
              ? Flexible(
                  child: productWidget(cartObj),
                )
              : (x == 1
                  ? addressScreen()
                  : (x == 2
                      ? SizedBox(
                          height: MediaQuery.of(context).size.height * 0.60,
                          //child: Container(color: Colors.pink),
                          child: finalPreviewListForItems(cartObj),
                        )
                      : paymentScreen()))
        ],
      ),
    );
  }

  // TODO payment screen and part-----------------------------
  Widget paymentScreen() {
    return Container(
      child: ElevatedButton(
        child: const Text('Pay'),
        onPressed: () async {
          //await payment.makePayment();
        },
      ),
    );
  }

//---------------------------------------------------------------------------
  Widget addressScreen() {
    return Expanded(
      //height: MediaQuery.of(context).size.height * 0.6,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              validator: (_) {
                if (_ == null || _.isEmpty) {
                  return 'Please enter the field';
                }
                return null;
              },
              controller: name,
              decoration: const InputDecoration(
                hintText: 'XYZ',
                label: Text('Name'),
              ),
            ),
            TextFormField(
                validator: (_) {
                  if (_ == null || _.isEmpty) {
                    return 'Please enter the field';
                  }
                  return null;
                },
                controller: email,
                decoration: const InputDecoration(
                  hintText: 'xyz@gmail.com',
                  label: Text('Email'),
                )),
            TextFormField(
                validator: (_) {
                  if (_ == null || _.isEmpty || _.length != 11) {
                    return 'Please enter the field';
                  }
                  return null;
                },
                controller: phoneNo,
                keyboardType: TextInputType.number,
                maxLength: 11,
                decoration: const InputDecoration(
                  hintText: '0xxxxxxxxxx',
                  label: Text('Phone number (Starting with 0)'),
                )),
            TextFormField(
                validator: (_) {
                  if (_ == null || _.isEmpty) {
                    return 'Please enter the field';
                  }
                  return null;
                },
                controller: address,
                decoration: const InputDecoration(
                  hintText: 'xyx, Jabalpur, MP-482005',
                  label: Text('Address'),
                )),
          ],
        ),
      ),
    );
  }

  Widget topBarGestureDetector(var icon, int p, String content) {
    return SizedBox(
      child: Row(
        children: [
          Icon(
            icon,
            color: x == p ? Colors.green : Colors.grey,
          ),
          Text(
            content,
            style: TextStyle(
              color: x == p ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
      width: MediaQuery.of(context).size.width * 0.2,
    );
  }

  Widget productWidget(final cartObj) {
    return ListView.builder(
      //physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: cartObj.mpLength,
      itemBuilder: (context, i) => EachCardItem(
          q: cartObj.mp.values.toList()[i].quantity,
          title: cartObj.mp.values.toList()[i].title,
          id: cartObj.mp.values.toList()[i].id,
          eachPrice: double.parse(cartObj.mp.values.toList()[i].price)),
    );
  }

  Widget finalPreviewListForItems(final cartObj) {
    // 3rd page
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 20,
          child: Divider(),
        ),
        const Text(
          'Products',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
        Flexible(child: productWidget(cartObj)),
        const SizedBox(child: Divider(),),
        const Text(
          'Address',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
        Text(
          address.text,
          style: const TextStyle(
            fontSize: 20,
          ),
        ),
        const SizedBox(
          height: 20,
          child: Divider(thickness: 0.8,),
        ),
        Text(
          'Final Amount: ₹${cartObj.totalPrice}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
      ],
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
