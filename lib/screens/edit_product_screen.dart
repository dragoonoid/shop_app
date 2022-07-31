import 'package:flutter/material.dart';
import 'package:shop/models/product.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/provider_prod.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit_product_screen';

  const EditProductScreen({Key? key}) : super(key: key);
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final focusDesc = FocusNode();
  final focusPrice = FocusNode();
  final focusImage = FocusNode();
  final _imageController = TextEditingController();
  final key = GlobalKey<FormState>();
  var showLoading = false;
  var newProduct = Product(
    id: '',
    title: 'title',
    desc: 'desc',
    price: 0,
    imageUrl: 'imageUrl',
  );
  var initialVal = {
    'id': '',
    'title': 'Test',
    'desc': ' ',
    'price': 0,
    'imageUrl': 'imageUrl',
  };
  bool isTrue = true;
  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    if (isTrue) {
      final id = ModalRoute.of(context)?.settings.arguments as String;
      if (id.length!=2) {
        newProduct =
            Provider.of<ProviderProd>(context, listen: false).findId(id);
        initialVal = {
          'id': newProduct.id,
          'title': newProduct.title,
          'desc': newProduct.desc,
          'price': newProduct.price,
          'imageUrl': newProduct.imageUrl,
        };
        _imageController.text = newProduct.imageUrl;
      }
    }
    isTrue = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    focusImage.removeListener(listner);
    focusDesc.dispose();
    focusPrice.dispose();
    focusImage.dispose();
    _imageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    focusImage.addListener(listner);
    super.initState();
  }

  void listner() {
    if (!focusImage.hasFocus) {
      setState(() {});
    }
  }

  void saveState() async {
    print('1');
    bool? x = key.currentState?.validate();
    if (x == false) {
      return;
    }
    setState(() {
      showLoading = true;
    });
    key.currentState?.save();
    if (newProduct.id != '') {
      await Provider.of<ProviderProd>(context, listen: false).update(newProduct);
      // print('hi');
      // print(newProduct.desc);
      setState(() {
        showLoading = false;
      });
      Navigator.of(context).pop();
      return;
    }
    try {
      await Provider.of<ProviderProd>(context, listen: false)
          .addProd(newProduct);
    } catch (error) {
      print(error);
      await showDialog<Null>(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: const Text('An Error has Occured'),
              content: const Text('Please try again later!'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: const Text(
                    'Back',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            );
          });
    } finally {
      setState(() {
        showLoading = false;
      });
      print('pop');
      Navigator.of(context).pop();
      // print(newProduct.title);
      // print(newProduct.imageUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Products'),
        actions: [
          IconButton(
            onPressed: () => saveState(),
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: showLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.yellow,
              ),
            )
          : Form(
              key: key,
              child: ListView(
                children: [
                  TextFormField(
                    initialValue: initialVal['title'].toString(),
                    decoration: const InputDecoration(
                      label: Text('Title'),
                    ),
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (val) {
                      FocusScope.of(context).requestFocus(focusPrice);
                    },
                    onSaved: (newValue) {
                      newProduct = Product(
                        id: newProduct.id,
                        title: newValue!,
                        desc: newProduct.desc,
                        price: newProduct.price,
                        imageUrl: newProduct.imageUrl,
                        isFav: newProduct.isFav,
                      );
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please Enter a Valid Title';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    initialValue: initialVal['price'].toString(),
                    focusNode: focusPrice,
                    decoration: const InputDecoration(
                      label: Text('Price'),
                    ),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (val) {
                      FocusScope.of(context).requestFocus(focusDesc);
                    },
                    onSaved: (newValue) {
                      newProduct = Product(
                        id: newProduct.id,
                        title: newProduct.title,
                        desc: newProduct.desc,
                        price: double.parse(newValue!),
                        imageUrl: newProduct.imageUrl,
                        isFav: newProduct.isFav,
                      );
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please Enter a Number';
                      } else if (double.parse(value) < 0) {
                        return 'Please Enter a Number > 0';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    initialValue: initialVal['desc'].toString(),
                    focusNode: focusDesc,
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(
                      label: Text('Descreption'),
                    ),
                    maxLines: 3,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (val) {
                      FocusScope.of(context).requestFocus(focusImage);
                    },
                    onSaved: (newValue) {
                      newProduct = Product(
                        id: newProduct.id,
                        title: newProduct.title,
                        desc: newValue!,
                        price: newProduct.price,
                        imageUrl: newProduct.imageUrl,
                        isFav: newProduct.isFav,
                      );
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please Enter a VDescreption';
                      } else if (value.length < 10) {
                        return 'Description too short (Atleast 10 letters)';
                      }
                      return null;
                    },
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.2,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                            width: 1,
                          ),
                        ),
                        child: _imageController.text.isEmpty
                            ? const Text('')
                            : Image.network(_imageController.text),
                      ),
                      const SizedBox(
                        width: 6,
                      ),
                      Expanded(
                        child: TextFormField(
                          focusNode: focusImage,
                          keyboardType: TextInputType.url,
                          decoration: const InputDecoration(
                            label: Text('Enter Image URL'),
                          ),
                          textInputAction: TextInputAction.done,
                          controller: _imageController,
                          onFieldSubmitted: (value) => saveState(),
                          onSaved: (newValue) {
                            newProduct = Product(
                              id: newProduct.id,
                              title: newProduct.title,
                              desc: newProduct.desc,
                              price: newProduct.price,
                              imageUrl: newValue!,
                              isFav: newProduct.isFav,
                            );
                          },
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                !value.startsWith('https') ||
                                !value.startsWith('http')) {
                              return 'Please Enter a Valid URL';
                            }
                            return null;
                          },
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
