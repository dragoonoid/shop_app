import 'package:flutter/material.dart';
import 'package:shop/screens/auth_screen.dart';
import 'package:animated_button/animated_button.dart';

class AppFrontPage extends StatelessWidget {
  const AppFrontPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            height: w.height * 0.6,
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
                color: Colors.blue),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
              child: Image.asset(
                'images/shop2.jpg',
                fit: BoxFit.contain,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(30,0,15,0),
            height: w.height * 0.25,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Your Appearence Shows Your Quality',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Shop with us with wathever you need',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                ),
              ],
            ),
          ),
          AnimatedButton(
            width:w.width * 0.8,
            height: w.height * 0.1,
            color: Colors.white,
            child: Container(
              child: const Center(
                child: Text(
                  'Login / SignUp',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              decoration: BoxDecoration(
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 30.0,
                  ),
                ],
                borderRadius: BorderRadius.circular(30),
                color: Colors.black,
              ),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AuthScreen(),
                ),
              );
            },
          ),
          // Center(
          //   child: GestureDetector(
          //     onTap: () {
          //       Navigator.of(context).push(
          //         MaterialPageRoute(
          //           builder: (context) => const AuthScreen(),
          //         ),
          //       );
          //     },
          //     child: Container(
          //       width: w.width * 0.8,
          //       height: w.height * 0.1,
          //       child: const Center(
          //         child: Text(
          //           'Login / SignUp',
          //           style: TextStyle(color: Colors.white),
          //         ),
          //       ),
          //       decoration: BoxDecoration(
          //           boxShadow: const [
          //             BoxShadow(
          //               color: Colors.grey,
          //               blurRadius: 30.0,
          //             ),
          //           ],
          //           borderRadius: BorderRadius.circular(30),
          //           color: Colors.black),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
