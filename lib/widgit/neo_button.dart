import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  Color bgColor;
  MyWidget({Key? key, required this.bgColor}) : super(key: key);
  // bgColor=const Color(0xFFE7ECEF);
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            blurRadius: 30,
            offset: Offset(
              -28,
              -28,
            ),
            color: Colors.white,
          ),
          BoxShadow(
            blurRadius: 30,
            offset: Offset(
              28,
              28,
            ),
            color: Color(0xFFA7A9AF),
          ),
        ],
      ),
    );
  }
}
