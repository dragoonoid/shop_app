import 'dart:math';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:shop/models/http_exception.dart';
import 'package:shop/providers/auth.dart';

enum AuthMode { Signup, Login }

class AuthScreen extends StatefulWidget {
  static const routeName = '/auth';

  AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  AuthMode _authMode = AuthMode.Login;

  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };

  var _isLoading = false;

  final _passwordController = TextEditingController();

  void errorMessage(String msg, BuildContext context) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text('Unable to Proceed'),
              content: Text(msg),
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.of(ctx, rootNavigator: true).pop();
                  },
                  icon: const Icon(Icons.exit_to_app),
                )
              ],
            ));
  }

  Future _submit() async {
    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.Login) {
        await Provider.of<Auth>(context, listen: false)
            .signin(_authData['email']!, _authData['password']!);
      } else {
        await Provider.of<Auth>(context, listen: false)
            .signup(_authData['email']!, _authData['password']!);
      }
    } on HttpException catch (e) {
      var msg = 'Authentication Failed';
      if (e.toString().contains('EMAIL_EXISTS')) {
        msg = 'Email is already registered';
      } else if (e.toString().contains('TOO_MANY_ATTEMPTS')) {
        msg = 'Too Many Attempts..';
      } else if (e.toString().contains('EMAIL_NOT_FOUND')) {
        msg = 'Email Id not registered';
      } else if (e.toString().contains('INVALID_PASSWORD')) {
        msg = 'Invalid Password';
      } else if (e.toString().contains('USER_DISABLED')) {
        msg = 'User has been diasbled temporarely';
      }
      if (mounted) {
        errorMessage(msg, context);
      }
    } catch (error) {
      if (mounted) {
        errorMessage('Unable to connect to the server', context);
      }
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Container(
                height: s.height * 0.45,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('images/login.png'),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 30,
                      width: 80,
                      height: 200,
                      child: Container(
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('images/light-1.png'),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 140,
                      width: 80,
                      height: 150,
                      child: Container(
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('images/light-2.png'),
                          ),
                        ),
                      ),
                    ),
                    // Positioned(
                    //   top: 40,
                    //   right: 40,
                    //   width: 80,
                    //   height: 150,
                    //   child: Container(
                    //     decoration: const BoxDecoration(
                    //       image: DecorationImage(
                    //         image: AssetImage('images/cart2.png'),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    Positioned(
                      child: Container(
                        margin: const EdgeInsets.only(top: 50),
                        child: Center(
                          child: Text(
                            _authMode == AuthMode.Signup ? 'Signup' : 'Login',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(143, 148, 251, 2),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Container(
                              height: s.height * 0.1,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey[100] ?? Colors.grey,
                                  ),
                                ),
                              ),
                              child: TextFormField(
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Email',
                                  hintStyle: TextStyle(color: Colors.grey[400]),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value!.isEmpty || !value.contains('@')) {
                                    return 'Invalid email!';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _authData['email'] = value!;
                                },
                              ),
                            ),
                            Container(
                              height: s.height * 0.1,
                              padding: const EdgeInsets.all(8),
                              child: TextFormField(
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Password',
                                  hintStyle: TextStyle(color: Colors.grey[400]),
                                ),
                                obscureText: true,
                                controller: _passwordController,
                                validator: (value) {
                                  if (value!.isEmpty || value.length < 5) {
                                    return 'Password is too short!';
                                  }
                                },
                                onSaved: (value) {
                                  _authData['password'] = value!;
                                },
                              ),
                            ),
                            if (_authMode == AuthMode.Signup)
                              Container(
                                height: s.height * 0.1,
                                padding: const EdgeInsets.all(8),
                                child: TextFormField(
                                  enabled: _authMode == AuthMode.Signup,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Confirm Password',
                                    hintStyle:
                                        TextStyle(color: Colors.grey[400]),
                                  ),
                                  obscureText: true,
                                  controller: _passwordController,
                                  validator: _authMode == AuthMode.Signup
                                      ? (value) {
                                          if (value !=
                                              _passwordController.text) {
                                            return 'Passwords do not match!';
                                          }
                                        }
                                      : null,
                                  onSaved: (value) {
                                    _authData['password'] = value!;
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    GestureDetector(
                      onTap: _submit,
                      child: Container(
                        height: s.height * 0.08,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: const LinearGradient(colors: [
                            Color.fromRGBO(143, 148, 251, 1),
                            Color.fromRGBO(143, 148, 251, 6),
                          ]),
                        ),
                        child: Center(
                          child: Text(
                            _authMode == AuthMode.Signup ? 'Signup' : 'Login',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    GestureDetector(
                      onTap: _switchAuthMode,
                      child: Text(
                        _authMode == AuthMode.Login ? 'Signup' : 'Login',
                        style: const TextStyle(
                          color: Color.fromRGBO(143, 148, 251, 1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}






// import 'dart:math';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:provider/provider.dart';
// import 'package:flutter/material.dart';
// import 'package:shop/models/http_exception.dart';
// import 'package:shop/providers/auth.dart';

// enum AuthMode { Signup, Login }

// class AuthScreen extends StatelessWidget {
//   static const routeName = '/auth';

//   const AuthScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final deviceSize = MediaQuery.of(context).size;
//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       body: Stack(
//         children: <Widget>[
//           Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   const Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
//                   const Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
//                 ],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 stops: const [0, 1],
//               ),
//             ),
//           ),
//           SingleChildScrollView(
//             child: SizedBox(
//               height: deviceSize.height,
//               width: deviceSize.width,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: <Widget>[
//                   Flexible(
//                     child: Container(
//                       margin: const EdgeInsets.only(bottom: 20.0),
//                       padding:
//                           const EdgeInsets.symmetric(vertical: 8.0, horizontal: 94.0),
//                       // transform: Matrix4.rotationZ(-8 * pi / 180)
//                       //   ..translate(-10.0),
//                       // ..translate(-10.0),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(20),
//                         color: Colors.deepOrange.shade900,
//                         boxShadow: const [
//                           BoxShadow(
//                             blurRadius: 8,
//                             color: Colors.black26,
//                             offset: Offset(0, 2),
//                           )
//                         ],
//                       ),
//                       child: const Text(
//                         'MyShop',
//                         style: TextStyle(
//                           color: Colors.deepPurple,
//                           fontSize: 50,
//                           fontFamily: 'Anton',
//                           fontWeight: FontWeight.normal,
//                         ),
//                       ),
//                     ),
//                   ),
//                   Flexible(
//                     flex: deviceSize.width > 600 ? 2 : 1,
//                     child: const AuthCard(),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class AuthCard extends StatefulWidget {
//   const AuthCard({Key? key}) : super(key: key);

//   // const AuthCard({
//   //   Key key,
//   // }) : super(key: key);

//   @override
//   _AuthCardState createState() => _AuthCardState();
// }

// class _AuthCardState extends State<AuthCard>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<Size> _heightAnimation;
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 2),
//     );
//     _heightAnimation = Tween<Size>(
//       begin: const Size(double.infinity, 270),
//       end: const Size(double.infinity, 500),
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   final GlobalKey<FormState> _formKey = GlobalKey();
//   AuthMode _authMode = AuthMode.Login;
//   Map<String, String> _authData = {
//     'email': '',
//     'password': '',
//   };
//   var _isLoading = false;
//   final _passwordController = TextEditingController();
//   void errorMessage(String msg, BuildContext context) {
//     showDialog(
//         context: context,
//         builder: (ctx) => AlertDialog(
//               title: const Text('Unable to Proceed'),
//               content: Text(msg),
//               actions: [
//                 IconButton(
//                   onPressed: () {
//                     Navigator.of(ctx, rootNavigator: true).pop();
//                   },
//                   icon: const Icon(Icons.exit_to_app),
//                 )
//               ],
//             ));
//   }

//   Future _submit() async {
//     if (!_formKey.currentState!.validate()) {
//       // Invalid!
//       return;
//     }
//     _formKey.currentState!.save();
//     setState(() {
//       _isLoading = true;
//     });
//     try {
//       if (_authMode == AuthMode.Login) {
//         await Provider.of<Auth>(context, listen: false)
//             .signin(_authData['email']!, _authData['password']!);
//       } else {
//         await Provider.of<Auth>(context, listen: false)
//             .signup(_authData['email']!, _authData['password']!);
//       }
//     } on HttpException catch (e) {
//       var msg = 'Authentication Failed';
//       if (e.toString().contains('EMAIL_EXISTS')) {
//         msg = 'Email is already registered';
//       } else if (e.toString().contains('TOO_MANY_ATTEMPTS')) {
//         msg = 'Too Many Attempts..';
//       } else if (e.toString().contains('EMAIL_NOT_FOUND')) {
//         msg = 'Email Id not registered';
//       } else if (e.toString().contains('INVALID_PASSWORD')) {
//         msg = 'Invalid Password';
//       } else if (e.toString().contains('USER_DISABLED')) {
//         msg = 'User has been diasbled temporarely';
//       }
//       if (mounted) {
//         errorMessage(msg, context);
//       }
//     } catch (error) {
//       if (mounted) {
//         errorMessage('Unable to connect to the server', context);
//       }
//     }
//     if (mounted) {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   void _switchAuthMode() {
//     if (_authMode == AuthMode.Login) {
//       _controller.forward();
//       setState(() {
//         _authMode = AuthMode.Signup;
//       });
//     } else {
//       _controller.reverse();
//       setState(() {
//         _authMode = AuthMode.Login;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final deviceSize = MediaQuery.of(context).size;
//     return Card(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(10.0),
//       ),
//       elevation: 8.0,
//       child: AnimatedContainer(
//         duration: const Duration(seconds: 2),
//         curve: Curves.linear,
//         height: _authMode==AuthMode.Signup ?500:270 ,
//         // constraints: BoxConstraints(minHeight: _heightAnimation.value.height),
//         width: deviceSize.width * 0.75,
//         padding: EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: SingleChildScrollView(
//             child: Column(
//               children: <Widget>[
//                 TextFormField(
//                   decoration: InputDecoration(labelText: 'E-Mail'),
//                   keyboardType: TextInputType.emailAddress,
//                   validator: (value) {
//                     if (value!.isEmpty || !value.contains('@')) {
//                       return 'Invalid email!';
//                     }
//                     return null;
//                   },
//                   onSaved: (value) {
//                     _authData['email'] = value!;
//                   },
//                 ),
//                 TextFormField(
//                   decoration: InputDecoration(labelText: 'Password'),
//                   obscureText: true,
//                   controller: _passwordController,
//                   validator: (value) {
//                     if (value!.isEmpty || value.length < 5) {
//                       return 'Password is too short!';
//                     }
//                   },
//                   onSaved: (value) {
//                     _authData['password'] = value!;
//                   },
//                 ),
//                 if (_authMode == AuthMode.Signup)
//                   TextFormField(
//                     enabled: _authMode == AuthMode.Signup,
//                     decoration: InputDecoration(labelText: 'Confirm Password'),
//                     obscureText: true,
//                     validator: _authMode == AuthMode.Signup
//                         ? (value) {
//                             if (value != _passwordController.text) {
//                               return 'Passwords do not match!';
//                             }
//                           }
//                         : null,
//                   ),
//                 const SizedBox(
//                   height: 20,
//                 ),
//                 if (_isLoading)
//                   const SpinKitWave(
//                     color: Colors.yellow,
//                   )
//                 else
//                   Container(
//                     height: MediaQuery.of(context).size.height * 0.07,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(10),
//                       color: Theme.of(context).primaryColor,
//                     ),
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 30.0, vertical: 8.0),
//                     child: TextButton(
//                       //style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor)),
//                       child: Text(
//                         _authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP',
//                         style: const TextStyle(color: Colors.white),
//                       ),
//                       onPressed: _submit,
//                     ),
//                   ),
//                 Padding(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
//                   child: OutlinedButton(
//                     child: Text(
//                       '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD',
//                       style: const TextStyle(color: Colors.black),
//                     ),
//                     onPressed: _switchAuthMode,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
