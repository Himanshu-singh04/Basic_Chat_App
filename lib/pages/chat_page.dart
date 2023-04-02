import 'package:flutter/material.dart';

class chat_page extends StatefulWidget {
  final String groupid;
  final String groupname;
  final String username;
  const chat_page(
      {Key? key,
      required this.groupid,
      required this.groupname,
      required this.username})
      : super(key: key);

  @override
  State<chat_page> createState() => _chat_pageState();
}

class _chat_pageState extends State<chat_page> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Hola")),
    );
  }
}
