import 'package:flutter/material.dart';

class Badge extends StatelessWidget {
  final Widget icon;
  final Color color;
  final String count;
  const Badge({Key? key , required this.color , required this.count , required this.icon}) : super(key: key);

  @override
  
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.center,
    children: [
      icon,
      Positioned(
        right: 8,
        top: 8,
        child: Container(
          padding:const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color:color
             ),
             constraints: const BoxConstraints(minHeight: 16,minWidth: 16),
          child: Text(count,style:const  TextStyle(fontSize: 10),)))
    ],);
  }
}