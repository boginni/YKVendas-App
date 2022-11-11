import 'package:flutter/material.dart';
import 'package:forca_de_vendas/testes/tela_vazia.dart';

import '../api/models/configuracao/app_system.dart';
import '../api/models/configuracao/app_theme.dart';

class EmptyScreen extends StatelessWidget {
  const EmptyScreen({Key? key}) : super(key: key);

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
          backgroundColor: appTheme.primaryColor,
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
      onGenerateRoute: (settings) {
        return MaterialPageRoute(builder: (_) => const TelaVazia());
      },
    );
  }
}
