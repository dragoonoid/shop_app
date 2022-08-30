import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/models/product.dart';
import 'package:shop/providers/provider_prod.dart';
import 'package:shop/screens/product_load_screen.dart';
import 'package:shop/widgit/product_item.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController cont = TextEditingController();
  List<Product> list=[];
  bool isLoading = false;
  void submit(String s) {
    if (s.isEmpty) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    list=Provider.of<ProviderProd>(context,listen: false).getSearchItems(s);
    setState(() {
      isLoading=false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CupertinoSearchTextField(
          controller: cont,
          onSubmitted: (_) => submit(_),
          onChanged: (_) => submit(_),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: ((context) => const ProductLoadingScreen())),
                (route) => false);
          },
        ),
      ),
      body: isLoading? const Center(child: CircularProgressIndicator()):GridView.builder(
        // physics: NeverScrollableScrollPhysics(),
        // shrinkWrap: true,
        //scrollDirection: Axis.horizontal,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          //mainAxisSpacing: 10,
          //crossAxisSpacing: 10,
          childAspectRatio: 2/3,
        ),
        itemCount: list.length,
        itemBuilder: (context, i) => ChangeNotifierProvider.value(
            value: list[i], child: const ProductItem()),
      ),
    );
  }
}
