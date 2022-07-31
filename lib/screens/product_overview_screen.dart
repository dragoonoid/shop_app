import 'package:flutter/material.dart';
import 'package:shop/providers/provider_prod.dart';
import 'package:provider/provider.dart';

class ProductOverview extends StatelessWidget {
  final String id;
  const ProductOverview({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final list = Provider.of<ProviderProd>(context).findId(id);
    return Scaffold(
      appBar: AppBar(
        title: Text(list.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
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
            const SizedBox(height: 10,),
            Text(
              list.title,
              style: const TextStyle(fontSize: 30),
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 5,),
            Text(
              list.desc,
              style:const TextStyle(fontSize: 20),
            )
          ],
        ),
      ),
    );
  }
}
