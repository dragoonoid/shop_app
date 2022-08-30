import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/category_prod.dart';
import 'package:shop/providers/provider_prod.dart';
import 'package:shop/screens/edit_product_screen.dart';
import 'package:shop/widgit/app_drawer.dart';

class UserProductScreen extends StatelessWidget {
  static const routeName = '/user_prod';
  Future onRefresh(BuildContext context) async {
    await Provider.of<ProviderProd>(context, listen: false)
        .getItemsFirebase(true);
  }

  const UserProductScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(EditProductScreen.routeName, arguments: '-1');
              },
              icon: const Icon(Icons.add)),
        ],
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder(
        future: onRefresh(context),
        builder: (ctx, snapshot) => snapshot.connectionState ==
                ConnectionState.waiting
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () => onRefresh(context),
                child: Consumer<ProviderProd>(
                  builder: (ctx, list, _) => Padding(
                    padding: const EdgeInsets.all(4),
                    child: ListView.builder(
                      itemBuilder: (context, i) {
                        return Column(
                          children: [
                            ListTile(
                              title: Text(list.items[i].title),
                              leading: CircleAvatar(
                                backgroundImage:
                                    NetworkImage(list.items[i].imageUrl),
                              ),
                              trailing: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.3,
                                child: Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        Navigator.of(context).pushNamed(
                                            EditProductScreen.routeName,
                                            arguments: list.items[i].id);
                                      },
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.deepPurpleAccent,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        String id = list.items[i].id;
                                        await list.deleteProd(id).catchError(
                                            (error) {
                                          scaffold.showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Failed to delete',
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          );
                                        }).then((value) =>
                                            Provider.of<CategoryProd>(context,
                                                    listen: false)
                                                .removeElement(id));
                                      },
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.redAccent,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            const Divider(
                              thickness: 3,
                            )
                          ],
                        );
                      },
                      itemCount: list.items.length,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
