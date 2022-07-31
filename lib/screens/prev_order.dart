import 'package:flutter/material.dart';
import 'package:shop/providers/order.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shop/widgit/app_drawer.dart';

class PreviousOrder extends StatefulWidget {
  const PreviousOrder({Key? key}) : super(key: key);
  static const orderKey = '/orderKey';

  @override
  State<PreviousOrder> createState() => _PreviousOrderState();
}

class _PreviousOrderState extends State<PreviousOrder> {
  bool loading = false;
  bool first = true;
  @override
  void didChangeDependencies() {
    if (first) {
      setState(() {
        loading = true;
      });
      Provider.of<Order>(context, listen: false)
          .getOrderFirebase()
          .then((value) {
        setState(() {
          loading = false;
        });
        first=false;
      });
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final prevOrder = Provider.of<Order>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Previous Orders'),
      ),
      body: loading
          ? const CircularProgressIndicator(
              color: Colors.red,
            )
          : ListView.builder(
              itemCount: prevOrder.orderList.length,
              itemBuilder: (context, i) =>
                  PreviousOrderBuilder(lst: prevOrder.orderList[i], pos: i + 1),
            ),
      drawer: const AppDrawer(),
    );
  }
}

class PreviousOrderBuilder extends StatefulWidget {
  final OrderItem lst;
  final int pos;
  const PreviousOrderBuilder({Key? key, required this.lst, required this.pos})
      : super(key: key);

  @override
  State<PreviousOrderBuilder> createState() => _PreviousOrderBuilderState();
}

class _PreviousOrderBuilderState extends State<PreviousOrderBuilder> {
  bool expand = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(
            '${widget.pos}) ₹ ${widget.lst.amount}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(DateFormat.yMEd().add_jms().format(widget.lst.date)),
          trailing: IconButton(
            icon: Icon(
              expand == true ? Icons.expand_less : Icons.expand_more,
              color: Colors.black,
            ),
            onPressed: () {
              setState(() {
                expand = !expand;
              });
            },
          ),
        ),
        if (expand)
          Container(
            padding: const EdgeInsets.all(8),
            height: widget.lst.product.length * 10 + 50,
            child: SingleChildScrollView(
              child: Column(
                children: widget.lst.product
                    .map((e) => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              e.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text('${e.quantity}x${e.price}'),
                          ],
                        ))
                    .toList(),
              ),
            ),
          ),
      ],
    );
  }
}
