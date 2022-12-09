import 'package:flutter/material.dart';

import '../../api/models/configuracao/app_system.dart';
import '../../api/models/configuracao/app_theme.dart';
import 'login/login_screen.dart';

class LoginFoundation extends StatefulWidget {
  const LoginFoundation({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoginFoundationState();
}

class _LoginFoundationState extends State<LoginFoundation> {
  final primaryColor = Colors.cyan;
  final Color secondaryColor = const Color.fromARGB(255, 200, 225, 200);

  @override
  Widget build(BuildContext context) {
    final appSystem = AppSystem.of(context);
    appSystem.setTheme(AppThemeOld.fromDefault());

    final appTheme = appSystem.appTheme;

    return MaterialApp(
      debugShowCheckedModeBanner: true,
      title: "Forca de vendas",
      theme: ThemeData(
        primaryColor: appTheme.primaryColor,
        scaffoldBackgroundColor: appTheme.secondaryColor,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        primaryIconTheme:
            const IconThemeData(color: Colors.black, opacity: 255),
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: primaryColor,
          // iconTheme: const IconThemeData(color: Colors.black),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            primary: Colors.white,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ElevatedButton.styleFrom(
            primary: Colors.white,
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
