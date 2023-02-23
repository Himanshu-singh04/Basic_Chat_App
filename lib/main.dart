import 'package:chatapp/helper/helper.dart';
import 'package:chatapp/pages/home_page.dart';
import 'package:chatapp/pages/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'constant/contants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: Constants.apikey,
            appId: Constants.appid,
            messagingSenderId: Constants.messagingsendingid,
            projectId: Constants.projectId));
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _is_signed_in = false;
  @override
  void initState() {
    super.initState();
    get_user_logged_in_status();
  }

  get_user_logged_in_status() async {
    await Helper_functions.get_user_logged_in_status().then((value) {
      if (value != null) {
        _is_signed_in = value;
      }
      ;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _is_signed_in ? home_page() : login_page(),
    );
  }
}
